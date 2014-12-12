{Modal} = Structural.Stores
{OpenModal, ReplaceModalContent} = Structural.Actions
{div} = React.DOM

ModalTrigger = React.createClass
  displayName: 'Modal Trigger'
  mixins: [
    Modal.listen('modalUpdate')
  ]
  getInitialState: ->
    active: false
    open: Modal.open()
  modalUpdate: ->
    @setState(open: Modal.open(), active: @state.active and Modal.open())

  componentDidUpdate: (prevProps, prevState) ->
    if @state.active
      _.defer(() => ReplaceModalContent(@props.content, @props.title))
  render: ->
    className = "#{@props.className} #{if @state.active then 'active-trigger' else ''}"
    div {className: className, onClick: @onClick}, @props.children

  onClick: ->
    OpenModal(@props.content, @props.title)
    @setState(active: true)

Structural.Components.ModalTrigger = ModalTrigger