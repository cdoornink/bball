`import Ember from 'ember'`

ModalsShotController = Ember.Controller.extend
  needs: ["game"]
  showAssistPrompt: false
  showBlockPrompt: false
  showReboundPrompt: false
  showFoulPrompt: false
  actions:
    cancel: ->
      @send('closeModal')
      @set('showReboundPrompt', false)
      @set('showAssistPrompt', false)
      @set('showFoulPrompt', false)
      @set('showBlockPrompt', false)
    setType: (type) ->
      @set('model.subType', type)
      $(".shot-type-button").removeClass('selected')
      $(".shot-type-button.#{type}").addClass('selected')
    setResult: (result) ->
      $(".result-button").removeClass('selected')
      $(".result-button.#{result}").addClass('selected')
      @set('model.result', result)
      if result is "make" or result is "and1"
        @set('showAssistPrompt', true)
      else
        @set('showAssistPrompt', false)
      if result is "miss" or result is "block"
        @set('showReboundPrompt', true)
      else
        @set('showReboundPrompt', false)
      if result is "block"
        @set('showBlockPrompt', true)
      else
        @set('showBlockPrompt', false)
      if result is "foul" or result is "and1"
        @set('showFoulPrompt', true)
      else
        @set('showFoulPrompt', false)
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
    continue: ->
      @get('controllers.game').send('submitShot', @get('model'))
      @send('closeModal')
      @set('showReboundPrompt', false)
      @set('showAssistPrompt', false)
      @set('showFoulPrompt', false)
      @set('showBlockPrompt', false)

`export default ModalsShotController`
