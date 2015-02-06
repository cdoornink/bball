`import Route from './filter'`

IndexRoute = Route.extend
  model: ->
    if @session.authed
      user = jQuery.parseJSON(localStorage.getItem("firebase:session::blistering-fire-5623"))
      @store.find('user', user.uid)

`export default IndexRoute`
