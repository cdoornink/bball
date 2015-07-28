`import Ember from 'ember'`

ModalsAssistedController = Ember.Controller.extend
  needs: ["game"]
  actions:
    cancel: ->
      @send('closeModal')
      if @get('model.shooting')
        Ember.run.later (=>
          if this.get('controllers.game.model.ignoredTeam.id')
            @send('openModal', 'modals/freethrow', {shooting: @get('model.shooting'), refresh: true})
          else
            @send('openModal', 'modals/fouled', {shooting: @get('model.shooting')})
        ), 100
    submit: (ops) ->
      @set('model.player', ops.player)
      @get('controllers.game').send('submitAssist', @get('model'))
      @send('closeModal')

`export default ModalsAssistedController`
