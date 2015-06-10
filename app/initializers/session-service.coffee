SessionInitializer =
  name: 'session-service'
  after: 'store'
  initialize: (registry, app) ->
    app.inject 'route', 'session', 'service:session'
    app.inject 'controller', 'session', 'service:session'
    app.inject 'model', 'session', 'service:session'

`export default SessionInitializer`
