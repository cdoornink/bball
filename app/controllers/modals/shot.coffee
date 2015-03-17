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

`export default ModalsShotController`
