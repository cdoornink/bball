`import Ember from 'ember'`

ApplicationRoute = Ember.Route.extend
  actions:
    logout: ->
      @session.logout()
    openModal: (modalName, model) ->
      console.log modalName
      @controllerFor(modalName).set('model', model or {})
      @render modalName,
        into: 'application'
        outlet: 'modal'
    closeModal: ->
      @disconnectOutlet
        parentView: 'application'
        outlet: 'modal'


`export default ApplicationRoute`
