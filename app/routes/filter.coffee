`import Ember from 'ember'`

FilterRoute = Ember.Route.extend
  redirect: ->
    console.log @session.get('authData')
    unless @session.get('authData')
      console.log "to go login"
      document.location = document.location.origin + "/login/"
    # console.log @session.login("chrisdoornink@gmail.com", "carvin84")


`export default FilterRoute`
