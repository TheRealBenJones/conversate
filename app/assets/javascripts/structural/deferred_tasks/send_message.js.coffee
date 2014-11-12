{Folders, ActiveFolder} = Structural.Stores
{SendMessageSuccess, SendMessageFailed, MarkRead} = Structural.Actions
{newMessage} = Structural.Api.Messages

SendMessage = new Hippodrome.DeferredTask
  action: Structural.Actions.SendMessage
  task: (payload) ->
    activeFolder = Folders.byId(ActiveFolder.id())

    success = (response) ->
      SendMessageSuccess(payload.temporaryId, response, payload.conversation)
    error = (response, status) ->
      SendMessageFailed(payload.temporaryId, payload.conversation)

    newMessage(payload.message, payload.conversation, success, error)
    MarkRead(payload.message, payload.conversation, activeFolder)

Structural.Tasks.SendMessage = SendMessage
