`import Ember from 'ember'`
`import ENV from '../config/environment';`

ref = new window.Firebase(ENV.firebaseURL)

SessionService = Ember.Service.extend
  authed: false

  init: ->
    ref.onAuth ((authData) ->
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
    ref.authWithPassword
      email    : email
      password : password
    , (error, authData) ->
      if error
        errorCallback(error.message)
      else
        successCallback(authData) #put this uid into localstorage to use on site load

  logout: ->
    ref.unauth()
    location.reload()

  createUser: (email, password, successCallback, errorCallback) ->
    ref.createUser
      email    : email
      password : password
    , (error, authData) =>
      unless error
        successCallback(authData)
      else
        errorCallback(error.message)

  afterAuthentication: (userId) ->
    _this = this;

    ref.child('users').child(userId).once 'value', (snapshot) ->
      exists = (snapshot.val() isnt null)
      userExistsCallback(userId, exists)
      # console.log "exists? ", exists

    userExistsCallback = (userId, exists) ->
      if (exists)
        _this.existingUser(userId)
      else
        _this.createUserModel(userId)

  existingUser: (userId) ->
    this.container.lookup('store:main').find("user", userId).then ((user) ->
      @set "user", user
      return
    ).bind(this)

  createUserModel: (userId) ->
    _this = this;
    this.container.lookup('store:main').createRecord('user',
      id: userId
      provider: @get('authData.provider')
      name: @get('authData.password.email') || @get('authData.facebook.displayName') || @get('authData.google.displayName')
      email: @get('authData.password.email') || @get('authData.facebook.email') || @get('authData.google.email')
      created: new Date().getTime()
    ).save().then( (user) ->
      _this.set('user', user)
    )

  afterUser: (user) ->
    this.set('user', user)

`export default SessionService`
