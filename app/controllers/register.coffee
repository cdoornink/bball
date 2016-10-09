`import Ember from 'ember'`

RegisterController = Ember.Controller.extend
  init: ->
    @set('register', Ember.Object.create())
  actions:
    register: ->
      if @get('register.password') is @get('register.passwordConfirm')
        @session.createUser(@get('register.email'), @get('register.password'), =>

          @set('register.spinny', true)

          Ember.run.later (=>
            @session.login(@get('register.email'), @get('register.password'), ->
              Ember.run.later (=>
                document.location = document.location.origin
              ), 1500
            , (error) =>
              @set 'login.error', error
            )
          ), 1500

        , (error) =>
          @set 'register.error', error
        )
      else
        @set 'register.error', "Your passwords do not match"
        
`export default RegisterController`
