`import Ember from 'ember'`

ModalsFoulController = Ember.Controller.extend
  needs: ["game"]
  actions:
    cancel: ->
      @send('closeModal')
    setType: (t) ->
      @set('model.subType', t)
      $(".type-button").removeClass('selected')
      $(".type-button.#{t}").addClass('selected')
    continue: ->
      @get('controllers.game').send('submitFoul', @get('model'))
      @send('closeModal')

`export default ModalsFoulController`
