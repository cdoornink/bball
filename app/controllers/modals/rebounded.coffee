`import Ember from 'ember'`

ModalsReboundedController = Ember.Controller.extend
  needs: ["game"]
  actions:
    cancel: ->
      @send('closeModal')
    submit: (ops) ->
      @set('model.rebounder', ops.player)
      @get('controllers.game').send('submitRebound', @get('model'))
      @send('closeModal')

`export default ModalsReboundedController`
