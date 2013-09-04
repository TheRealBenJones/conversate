# Methods in this module will get automatically executed for the site admin
# page.  Each method should follow some basic rules for best results:
#   - The method name should describe the problem it finds using a singular
#     reference to the model it finds it on.
#   - The method should return an array of hashes with two keys:
#       :model should be the model object that exhibits the error.
#       :notes should be a string with any additionaly information useful in
#              fixing the problem.
module Health

  # User health checkts

  def Health.user_with_nil_default_topic
    User.where(:default_topic_id => nil).map do |u|
      {
        :model => u,
        :notes => u.topics.map{|t| t.debug_s}.join(', ')
      }
    end
  end

  def Health.user_with_no_topics
    User.all.keep_if {|u| u.topics.empty? }.map do |u|
      {
        :model => u,
        :notes => ''
      }
    end
  end

  def Health.user_with_no_groups
    User.all.keep_if {|u| u.groups.empty? }.map do |u|
      {
        :model => u,
        :notes => ''
      }
    end
  end

  # Topic health checks

  def Health.topic_with_no_users
    Topic.all.keep_if {|t| t.users.empty? }.map do |t|
      {
        :model => t,
        :notes => ''
      }
    end
  end

  # Conversation health checks

  def Health.conversation_with_no_users
    Conversation.all.keep_if {|c| c.users.empty? }.map do |c|
      {
        :model => c,
        :notes => ''
      }
    end
  end

  def Health.conversation_with_duplicate_users
    Conversation.all.keep_if {|c| c.users.length != c.users.uniq.length }.map do |c|
      {
        :model => c,
        :notes => c.users.keep_if {|u| c.users.index(u) != c.users.rindex(u) }.uniq.map {|u| u.debug_s }.join(', ')
      }
    end
  end

  def Health.conversation_with_no_topics
    Conversation.all.keep_if {|c| c.topics.empty? }.map do |c|
      {
        :model => c,
        :notes => ''
      }
    end
  end

  def Health.conversation_hidden_from_users
    hidden_users = []
    Conversation.all.keep_if do |c|
      c_topics = Set.new(c.topics)
      hidden_from = c.users.keep_if do |u|
        Set.new(u.topics).intersection(c_topics).empty?
      end
      hidden_users += hidden_from
      hidden_from.length > 0
    end.map do |c|
      {
        :model => c,
        :notes => hidden_users.map {|u| u.debug_s }.join(', ')
      }
    end
  end

  # Group health checks

  def Health.group_with_no_admins
    Group.all.keep_if {|g| g.admins.empty? }.map do |g|
      {
        :model => g,
        :notes => g.users.map {|u| u.debug_s }.join(', ')
      }
    end
  end

  def Health.group_with_no_users
    Group.all.keep_if {|g| g.users.empty? }.map do |g|
      {
        :model => g,
        :notes => ''
      }
    end
  end
end
