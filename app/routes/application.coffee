`import Ember from 'ember'`
`import ENV from '../config/environment';`

beforeUnloadFunction = (event) ->
  event.returnValue = "You are currently offline. Reloading right now will cause all your recent data to be lost."

ApplicationRoute = Ember.Route.extend
  freeThrowsQueued: false
  setupController: (controller, model) ->
    @_super(controller, model)
    connectedRef = new Firebase(ENV.firebaseURL + ".info/connected")
    connectedRef.on "value", (snap) ->
      if (snap.val() is true)
        window.removeEventListener "beforeunload", beforeUnloadFunction
      else
        window.addEventListener "beforeunload", beforeUnloadFunction
  actions:
    logout: ->
      @session.logout()
    openModal: (modalName, model) ->
      if $('.modal-dialog').length
        @freeThrowsQueued = true
      @controllerFor(modalName).set('model', model or {})
      @render modalName,
        into: 'application'
        outlet: 'modal'
    closeModal: ->
      if @freeThrowsQueued
        @freeThrowsQueued = false
        @controllerFor('modals/freethrow').set('model.refresh', true)
        @render 'modals/freethrow',
          into: 'application'
          outlet: 'modal'
      else
        @disconnectOutlet
          parentView: 'application'
          outlet: 'modal'


`export default ApplicationRoute`
