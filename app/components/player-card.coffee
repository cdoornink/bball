`import Ember from 'ember'`

PlayerCardComponent = Ember.Component.extend
  classNames: ["player-card"]
  click: ->
    @sendAction('action', {player: @get('player'), el: @.$()})

`export default PlayerCardComponent`
