`import Ember from 'ember'`

ModalsTurnoverController = Ember.Controller.extend
  needs: ["game"]
  actions:
    cancel: ->
      @send('closeModal')
    setStealer: (ops) ->
      @set('model.stealer', ops.player)
      $('.stealer .player-card').removeClass('selected')
      ops.el.addClass('selected')
    continue: ->
      @get('controllers.game').send('submitTurnover', @get('model'))
      @send('closeModal')

`export default ModalsTurnoverController`
