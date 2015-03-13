`import Ember from 'ember'`

ModalsShotController = Ember.Controller.extend
  needs: ["game"]
  actions:
    cancel: ->
      @send('closeModal')
    setType: (type) ->
      @set('model.subType', type)
      $(".shot-type-button").removeClass('selected')
      $(".shot-type-button.#{type}").addClass('selected')
    setResult: (result) ->
      $(".result-button").removeClass('selected')
      $(".result-button.#{result}").addClass('selected')
      @set('model.result', result)
      @get('controllers.game').send('submitShot', @get('model'))
      @send('closeModal')

    setRebounder: (ops) ->
      @set('model.rebounder', ops.player)
      $('.rebounder .player-card').removeClass('selected')
      ops.el.addClass('selected')
    setAssister: (ops) ->
      @set('model.assister', ops.player)
      $('.assister .player-card').removeClass('selected')
      ops.el.addClass('selected')
    setBlocker: (ops) ->
      @set('model.blocker', ops.player)
      $('.blocker .player-card').removeClass('selected')
      ops.el.addClass('selected')
    setFouler: (ops) ->
      @set('model.fouler', ops.player)
      $('.fouler .player-card').removeClass('selected')
      ops.el.addClass('selected')

`export default ModalsShotController`
