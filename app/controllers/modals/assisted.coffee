`import Ember from 'ember'`

ModalsAssistedController = Ember.Controller.extend
  needs: ["game"]
  actions:
    cancel: ->
      @send('closeModal')
      if @get('model.shooting')
        @send('openModal', 'modals/fouled', {shooting: @get('model.shooting')})
    submit: (ops) ->
      @set('model.player', ops.player)
      @get('controllers.game').send('submitAssist', @get('model'))
      @send('closeModal')

`export default ModalsAssistedController`
