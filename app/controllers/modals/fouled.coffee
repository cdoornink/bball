`import Ember from 'ember'`

ModalsFouledController = Ember.Controller.extend
  needs: ["game"]
  actions:
    cancel: ->
      @send('closeModal')
    submit: (ops) ->
      console.log @get('model.shooting')
      @set('model.fouler', ops.player)
      @get('controllers.game').send('submitFoul', @get('model'))
      @send('closeModal')

`export default ModalsFouledController`
