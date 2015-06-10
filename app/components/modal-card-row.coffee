`import Ember from 'ember'`

ModalCardRowComponent = Ember.Component.extend
  classNames: ["modal-card-row"]
  classNameBindings: ["colors"]
  didInsertElement: ->
    @.$('.player-card')
      .css("background", @get('colors.primaryColor'))
      .css("color", @get('colors.secondaryColor'))
  actions:
    setPlayer: (params) ->
      @sendAction('action', params)

`export default ModalCardRowComponent`
