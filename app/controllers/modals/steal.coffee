`import Ember from 'ember'`

ModalsStealController = Ember.Controller.extend
  needs: ["game"]
  actions:
    cancel: ->
      @send('closeModal')
    setTurnoverer: (ops) ->
      @set('model.turnoverer', ops.player)
      $('.turnoverer .player-card').removeClass('selected')
      ops.el.addClass('selected')
    continue: ->
      @get('controllers.game').send('submitSteal', @get('model'))
      @send('closeModal')

`export default ModalsStealController`


#was just doing steals and turnovers - steals be broken, fix it