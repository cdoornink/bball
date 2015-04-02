`import Route from './filter'`

IndexRoute = Route.extend
  model: ->
    if @session.authed
      user = jQuery.parseJSON(localStorage.getItem("firebase:session::blistering-fire-5623"))
      @store.find('user', user.uid)
  setupController: (controller, model) ->
    @_super(controller, model)
    controller.set('defaultPreferences', @store.find('gamePreference', {orderBy: "default", equalTo: true}))

`export default IndexRoute`
