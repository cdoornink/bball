`import Ember from 'ember'`

GameView = Ember.View.extend
  didInsertElement: ->
    console.log "do it"
    @controller.getStats()

`export default GameView`
