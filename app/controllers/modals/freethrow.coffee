`import Ember from 'ember'`

ModalsFreethrowController = Ember.Controller.extend
  needs: ["game"]
  shooting2: false
  shooting3: false
  setShootingButtons: (->
    num = @get('model.shooting')
    if num is 1 then el = 'one' else if num is 2 then el = "two" else if num is 3 then el = 'three'
    $(".shooting-button").removeClass('selected')
    $(".shooting-button.#{el}").addClass('selected')
  ).observes('model.shooting')
  actions:
    cancel: ->
      @send('closeModal')
      @set('shooting2', false)
      @set('shooting3', false)
    setShooting: (num) ->
      @set('model.shooting', num)
    setResult1: (result) ->
      $(".result1-button").removeClass('selected')
      $(".result1-button.#{result}").addClass('selected')
      @set('model.result1', result)
      if @get('model.shooting') > 1
        @set('shooting2', true)
    setResult2: (result) ->
      $(".result2-button").removeClass('selected')
      $(".result2-button.#{result}").addClass('selected')
      @set('model.result2', result)
      if @get('model.shooting') > 2
        @set('shooting3', true)
    setResult3: (result) ->
      $(".result3-button").removeClass('selected')
      $(".result3-button.#{result}").addClass('selected')
      @set('model.result3', result)
    continue: ->
      @get('controllers.game').send('submitFreeThrows', @get('model'))
      @send('closeModal')
      @set('shooting2', false)
      @set('shooting3', false)


`export default ModalsFreethrowController`
