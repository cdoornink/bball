`import Ember from 'ember'`

ModalDialogComponent = Ember.Component.extend
  actions:
    clickOverlay: ->
      @sendAction('clickOverlay')

`export default ModalDialogComponent`
