`import Ember from 'ember'`

ModalsConfirmationController = Ember.Controller.extend
  actions:
    cancel: ->
      console.log 'cancel conf'
      if @get('model').cancel
        console.log @get('model').confirmationCancel()
      @send('closeModal')
    continue: ->
      console.log 'continue conf'
      if @get('model').continue
        console.log @get('model').continue()
      @send('closeModal')

`export default ModalsConfirmationController`
