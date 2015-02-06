`import Ember from 'ember';`
`import ENV from '../config/environment';`

ref = new window.Firebase(ENV.firebaseURL)

initialize = (container, app) ->
  session = Ember.Object.extend
    authed: false

    app.store = container.lookup('store:main')
    init: ->
      ref.onAuth ((authData) ->
        console.log authData
        unless authData
          @set "authed", false
          @set "authData", null
          @set "user", null
          return false
        @set "authed", true
        @set "authData", authData
        @afterAuthentication authData.uid
        return
      ).bind(this)

    login: (email, password, successCallback, errorCallback) ->
      console.log email
      console.log "login..."
      ref.authWithPassword
        email    : email
        password : password
      , (error, authData) ->
        if error
          console.log error, "fjidso"
          errorCallback(error.message)
        else
          successCallback(authData) #put this uid into localstorage to use on site load

    logout: ->
      ref.unauth()
      location.reload()

    createUser: (email, password) ->
      ref.createUser
        email    : email
        password : password
      , (error) ->
        unless error
          console.log("User created successfully")
        else
          console.log("Error creating user:", error)

    afterAuthentication: (userId) ->
      _this = this;

      ref.child('users').child(userId).once 'value', (snapshot) ->
        exists = (snapshot.val() isnt null)
        userExistsCallback(userId, exists)
        console.log "exists? ", exists

      userExistsCallback = (userId, exists) ->
        if (exists)
          _this.existingUser(userId)
        else
          _this.createUserModel(userId)

    existingUser: (userId) ->
      app.store.find("user", userId).then ((user) ->
        @set "user", user
        return
      ).bind(this)

    createUserModel: (userId) ->
      _this = this;
      console.log 'fuck?'
      console.log this.get('authData'), userId
      console.log "-----------"
      app.get('store').createRecord('user',
        id: userId
        provider: @get('authData.provider')
        name: @get('authData.password.email') || @get('authData.facebook.displayName') || @get('authData.google.displayName')
        email: @get('authData.password.email') || @get('authData.facebook.email') || @get('authData.google.email')
        created: new Date().getTime()
      ).save().then( (user) ->
        console.log "saved?", user
        _this.set('user', user)
      )

    afterUser: (user) ->
      this.set('user', user)

  app.register('session:main', session)
  app.inject('route', 'session', 'session:main')
  app.inject('controller', 'session', 'session:main')
  app.inject('model', 'session', 'session:main')

SessionInitializer =
  name: 'session'
  after: 'store'
  initialize: initialize

`export {initialize}`
`export default SessionInitializer`
