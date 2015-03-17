`import Ember from 'ember'`

ModalsBlockController = Ember.Controller.extend
  needs: ["game"]
  actions:
    cancel: ->
      @send('closeModal')
    setRebounder: (ops) ->
      @set('model.player', ops.player)
      $('.rebounder .player-card').removeClass('selected')
      ops.el.addClass('selected')
    continue: ->
      @get('controllers.game').send('submitBlock', @get('model'))
      @send('closeModal')

`export default ModalsBlockController`
