`import Ember from 'ember'`

ModalsConfirmationController = Ember.Controller.extend
  actions:
    cancel: ->
      if @get('model').cancel
        @get('model').confirmationCancel()
      @send('closeModal')
    continue: ->
      if @get('model').continue
        @get('model').continue()
      @send('closeModal')

`export default ModalsConfirmationController`
