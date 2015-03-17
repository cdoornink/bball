`import Ember from 'ember'`

ModalsReboundedController = Ember.Controller.extend
  needs: ["game"]
  actions:
    cancel: ->
      @send('closeModal')
    submit: (ops) ->
      @set('model.player', ops.player)
      @get('controllers.game').send('submitRebound', @get('model'))
      @send('closeModal')
    submitTeam: (team) ->
      @set('model.team', team)
      @get('controllers.game').send('submitTeamRebound', @get('model'))
      @send('closeModal')

`export default ModalsReboundedController`
