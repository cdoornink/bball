`import Ember from 'ember'`

ModalCardRowComponent = Ember.Component.extend
  classNames: ["modal-card-row"]
  classNameBindings: ["colors"]
  didInsertElement: ->
    @.$('.player-card')
      .css("background", @colors.get('primaryColor'))
      .css("color", @colors.get('secondaryColor'))
  actions:
    setPlayer: (params) ->
      @sendAction('action', params)

`export default ModalCardRowComponent`
