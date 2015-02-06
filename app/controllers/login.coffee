`import Ember from 'ember'`

LoginController = Ember.Controller.extend
  init: ->
    @set('login', Ember.Object.create())
  actions:
    login: ->
      @session.login(@get('login.email'), @get('login.password'), ->
        document.location = document.location.origin
      , (error) =>
        @set 'login.error', error
      )

`export default LoginController`
