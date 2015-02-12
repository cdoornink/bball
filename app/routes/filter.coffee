`import Ember from 'ember'`

FilterRoute = Ember.Route.extend
  redirect: ->
    unless @session.get('authData')
      document.location = document.location.origin + "/login/"
    # console.log @session.login("chrisdoornink@gmail.com", "carvin84")


`export default FilterRoute`
