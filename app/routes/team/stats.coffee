`import Ember from 'ember'`

TeamStatsRoute = Ember.Route.extend
  model: ->
    @modelFor('team')
  setupController: (controller, model) ->
    @_super(controller, model)
    controller.getStats()

`export default TeamStatsRoute`
