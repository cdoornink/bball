`import Ember from 'ember'`

ModalsTimeController = Ember.Controller.extend
  needs: ['game']
  actions:
    cancel: ->
      if @get('model').cancel
        @get('model').confirmationCancel()
      @send('closeModal')
    continue: ->
      timeLeft = parseInt((@get('controllers.game.minutesLeft') * 60)) + parseInt(@get('controllers.game.secondsLeft'))
      @set('controllers.game.model.timeLeft', timeLeft)
      if @get('model').continue
        @get('model').continue()
      @send('closeModal')

`export default ModalsTimeController`
