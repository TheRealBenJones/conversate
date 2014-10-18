{updateMostRecentViewed} = Structural.Api.Conversations
{Conversations, CurrentUser} = Structural.Stores

MarkRead = new Hippodrome.SideEffect
  action: Structural.Actions.MarkRead
  effect: (payload) ->
    convo = Conversations.byId(payload.conversation.id)
    user = CurrentUser.getUser()

    # This api endpoint returns the user, which we don't really want to do
    # anything with.
    success = ->
    error = ->
    updateMostRecentViewed(convo, user, success, error)

Structural.SideEffects.MarkRead = MarkRead
