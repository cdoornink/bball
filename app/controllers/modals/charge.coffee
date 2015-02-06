`import Ember from 'ember'`

ModalsChargeController = Ember.Controller.extend
  needs: ["game"]
  actions:
    cancel: ->
      @send('closeModal')
    continue: ->
      @get('controllers.game').send('submitDrawnCharge')
      @send('closeModal')

`export default ModalsChargeController`
