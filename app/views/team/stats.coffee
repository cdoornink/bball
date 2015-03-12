`import Ember from 'ember'`

TeamStatsView = Ember.View.extend
  didInsertElement: ->
    console.log "hello?"
    @get('controller').getStats()

`export default TeamStatsView`
