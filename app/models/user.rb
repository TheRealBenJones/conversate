class User < ActiveRecord::Base
  authenticates_with_sorcery!

  has_many :reading_logs
  has_many :conversations, :through => :reading_logs
  has_many :actions, :inverse_of => :user
  has_many :group_participations
  has_many :groups, :through => :group_participations
  has_and_belongs_to_many :folders
  belongs_to :default_folder, class_name: "Folder", foreign_key: "default_folder_id"

  attr_accessible :email, :full_name, :password, :password_confirmation, :external

  validates_confirmation_of :password
  # We have to allow nil passwords or we wouldn't ever be able to change a
  # user record.  The database doesn't actually have a password field (just the
  # encrypted password) so unless we set it explicitly (which would change it)
  # it's always nil.
  validates :password, length: { minimum: 1 }, allow_nil: true
  validates_presence_of :password, :on => :create, :unless => :external
  validates_presence_of :email
  validates_uniqueness_of :email, :case_sensitive => false

  def self.build(params)
    user = User.new(params)
    return false if user.save == false
    # Apparently save will helpfully nil out the password field and then
    # complain that the password confirmation field doesn't match.
    user.password_confirmation = nil

    # External users have no purpose other than to receive mail.
    user.send_me_mail = true if user.external

    new_folder = Folder.new
    new_folder.name = 'Inbox'
    new_folder.users << user
    new_folder.save
    user.default_folder_id = new_folder.id
    user.save

    user
  end

  def self.find_by_email_insensitive(email)
    User.where('lower(email) = ?', email.downcase).first
  end

  def name
    full_name.empty? ? email : full_name
  end

  def update_most_recent_viewed(conversation)
    log = self.reading_logs.where(:conversation_id => conversation.id).first
    log.most_recent_viewed = Time.now.to_datetime
    log.save!
  end

  def unread_count
    self.reading_logs.where("unread_count >0").count
  end

  def unread_conversations
    conversations.find(self.reading_logs.where("unread_count >0").pluck(:conversation_id))
  end

  # Public: returns the users this user knows.
  def address_book
    users = self.groups.map { |g| g.users }.flatten.uniq - [self]

    address_book = Array.new
    users.map do |user|
      addressee = Hash.new
      addressee['id'] = user.id
      addressee['full_name'] = user.full_name
      addressee['email'] = user.email
      addressee['external'] = user.external
      address_book.push(addressee)
    end
    return address_book
  end

  def group_admin?(group)
    self.group_participations.where(group_id: group.id).first.group_admin
  end

  def ensure_cnv_in_at_least_one_folder(conversation)
    if (conversation.folders.to_set & self.folders.to_set).empty?
      conversation.folders << self.default_folder
    end
  end

  def create_welcome_conversation()
    support = User.find(122)
    welcome_convo = self.default_folder.conversations.create(title: 'Hello')
    action_params = [
      { 'type' => 'retitle',
        'title' => 'Hello'
      },
      { 'type' => 'update_users',
        'added' => [{id: support.id, full_name: support.full_name},
                    {id: self.id, full_name: self.full_name, email: self.email}],
        'removed' => nil
      },
      { 'type' => 'message',
        'text' => 'Hey this is support.  Are you supported?'
      }
    ]
    action_params.each do |params|
      action = welcome_convo.actions.create({
        type: params['type'],
        data: Action.data_for_params(params),
        user_id: support.id
      })
      action.save
      welcome_convo.handle(action)
    end
    welcome_convo.most_recent_event = welcome_convo.actions.last.created_at
    welcome_convo.save
  end

  # This avoids us writing out passwords, salts, etc. when rendering json.
  def as_json(options={})
    json = super(:only => [:email, :full_name, :id, :site_admin, :external])
    if options[:include_address_book]
      json['address_book'] = address_book
    end

    if options[:conversation]
      json['most_recent_viewed'] = options[:conversation].most_recent_viewed_for_user(self).msec
    end

    return json
  end

  def debug_s
    "User:#{self.id}:#{self.name}"
  end
end
