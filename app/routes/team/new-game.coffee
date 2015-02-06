`import Ember from 'ember'`

TeamNewGameRoute = Ember.Route.extend
  setupController: (controller, model) ->
    @_super(controller, model)
    controller.set('defaultPreferences', @store.find('gamePreference'))

`export default TeamNewGameRoute`
