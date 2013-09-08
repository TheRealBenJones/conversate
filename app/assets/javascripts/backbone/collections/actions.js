Structural.Collections.Actions = Backbone.Collection.extend({
  model: Structural.Models.Action,
  url: function() {
    return Structural.apiPrefix + '/conversations/' + this.conversationId + '/actions';
  },
  initialize: function(data, options) {
    options = options || {};
    this.conversationId = options.conversation;
    this.userId = options.user;
    this.on('reset', this._findMyMessages, this);
    this.on('add', this.setStateOnNewAction, this);
    this.on('add', function(model, collection, options) {
      console.log('add');
      this.trigger('unreadCountChanged');
    });
    this.on('add', this.triggerNewMessage, this);
  },
  comparator: 'timestamp',

  _findMyMessages: function() {
    console.log('reset');
    this.forEach(function(action) {
      if (action.get('user').id === this.userId) {
        action.isMine();
      }
    }, this);
  },

  focus: function(id) {
    // findWhere is coming in backbone 1.0.0.
    var action = this.get(id);
    if(action) {
      action.focus();
    }

    this.filter(function(act) { return act.id != id; }).forEach(function(act) {
      act.unfocus();
    });
  },

  createRetitleAction: function(title, user) {
    this._newAction({
      type: 'retitle',
      title: title,
      user: {
        name: user.get('name'),
        id: user.id
      }
    });
  },
  createUpdateUserAction: function(added, removed, user) {
    this._newAction({
      type: 'update_users',
      user: {
        name: user.get('name'),
        id: user.id
      },
      added: new Structural.Collections.Participants(added).toJSON(),
      removed: new Structural.Collections.Participants(removed).toJSON()
    });
  },
  createMessageAction: function(text, user) {
    var model = this._newAction({
      type: 'message',
      text: text,
      user: {
        name: user.get('name'),
        id: user.id
      },
      timestamp: Date.now()
    });
  },
  createDeleteAction: function(action, user) {
    var model = new Structural.Models.Action({
      type: 'deletion',
      msg_id: action.id,
      user: {
        name: user.get('name'),
        id: user.id
      }
    });
    model.url = this.url();
    model.save();
    action.delete(user);
  },
  createMoveConversationAction: function(topic, user) {
    this._newAction({
      type: 'move_conversation',
      user: {
        name: user.get('name'),
        id: user.id
      },
      conversation_id: this.conversationId,
      to: {
        name: topic.get('name'),
        id: topic.id
      }
    });
  },

  // This actions collection's conversation is being viewed.
  viewActions: function() {
    console.log('viewActions');
    var options = {}
    if (this.length === 0) {
      options.reset = true
      //options.add = false
      console.log('first viewing');
    }
    this.fetch(options);
  },

  // TODO: Remove & remove references to it.
  clearConversation: function() {},

  setStateOnNewAction: function(model, collection) {
    if (model.get('user').id === this.userId) {
      model.isMine();
    }
  },
  triggerNewMessage: function(model) {
    if (model.get('type') === 'message' &&
        model.get('user').id !== this.userId) {
      this.trigger('addedSomeoneElsesMessage')
    }
  },

  _newAction: function(data) {
    var model = new Structural.Models.Action(data);
    model.set('timestamp', (new Date()).valueOf());
    this.add(model);
    model.save();
    return model;
  },

  unreadCount: function(mostRecentEventViewed) {
    var count = 0;
    this.forEach(function(action) {
      count += action.isUnread(mostRecentEventViewed) ? 1 : 0;
    });
    return count;
  }
});
