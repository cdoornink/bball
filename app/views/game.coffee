`import Ember from 'ember'`

GameView = Ember.View.extend
  didInsertElement: ->
    @get('controller').getStats()

`export default GameView`
