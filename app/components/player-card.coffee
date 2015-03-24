`import Ember from 'ember'`

PlayerCardComponent = Ember.Component.extend
  classNames: ["player-card"]
  didInsertElement: ->
    return unless @get('exclude')
    if @get('player') is @get('exclude') then @.$().addClass('disabled')
  click: ->
    if @get('player') is @get('exclude') then return
    @sendAction('action', {player: @get('player'), el: @.$()})

`export default PlayerCardComponent`
