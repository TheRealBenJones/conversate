Structural.Models.Conversation = Backbone.Model.extend({
  initialize: function(attributes, options) {
    if (this.get('participants')) {
      this.set('participants', new Structural.Collections.Participants(this.get('participants')));
    }
  },
  parse: function (response, options) {

    // This gets used later in a template so we need real models from our response.
    response.participants = _.map(response.participants, function (p) {
      return new Structural.Models.Participant(p);
    });
    return response;
  },

  focus: function() {
    this.set('is_current', true);
  },
  unfocus: function() {
    this.set('is_current', false);
  },

  changeTitle: function(title) {
    this.set('title', title);
  },

  unreadCount: function() {
    // TODO: Change this so that each conversation actually has its own actions collection.
    return Structural._actions.unreadCount();
  }
});

_.extend(Structural.Models.Conversation.prototype,
         Support.HumanizedTimestamp('most_recent_event'));
