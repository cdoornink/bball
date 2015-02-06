`import Ember from 'ember'`

ModalsReboundController = Ember.Controller.extend
  needs: ["game"]
  actions:
    cancel: ->
      @send('closeModal')
    setType: (t) ->
      @set('model.subType', t)
      $(".type-button").removeClass('selected')
      $(".type-button.#{t}").addClass('selected')
    continue: ->
      @get('controllers.game').send('submitRebound', @get('model'))
      @send('closeModal')

`export default ModalsReboundController`
