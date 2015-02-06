`import Ember from 'ember'`

ModalCardRowComponent = Ember.Component.extend
  classNames: ["modal-card-row"]
  actions:
    setPlayer: (params) ->
      @sendAction('action', params)

`export default ModalCardRowComponent`
