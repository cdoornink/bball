`import Ember from 'ember'`

ApplicationRoute = Ember.Route.extend
  freeThrowsQueued: false
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
