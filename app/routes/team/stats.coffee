`import Ember from 'ember'`

TeamStatsRoute = Ember.Route.extend
  model: ->
    @modelFor('team')

`export default TeamStatsRoute`
