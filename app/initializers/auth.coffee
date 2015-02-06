ref = new window.Firebase("https://blistering-fire-5623.firebaseio.com/");

# Takes two parameters: container and app
initialize = () ->
  # app.register 'route', 'foo', 'service:foo'

AuthInitializer =
  name: 'auth'
  initialize: initialize

`export {initialize}`
`export default AuthInitializer`
