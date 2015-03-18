`import Ember from 'ember'`

GameView = Ember.View.extend
  didInsertElement: ->
    # @get('controller').getStats()
    console.log "not compiling on view insert"

`export default GameView`
