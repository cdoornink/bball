`import Ember from 'ember'`

ModalsBlockedController = Ember.Controller.extend
  needs: ["game"]
  actions:
    cancel: ->
      @send('closeModal')
    submit: (ops) ->
      @set('model.player', ops.player)
      @get('controllers.game').send('submitBlock', @get('model'))
      @send('closeModal')

`export default ModalsBlockedController`
