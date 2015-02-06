`import Ember from 'ember'`

secondsToTime = (a) ->
  if a is undefined then return
  b = ""
  c = Math.floor(a / 3600)
  d = Math.floor(a % 3600 / 60)
  e = Math.floor(a % 3600 % 60)
  (if c >= 1 then (b += c + ":"
  b += ((if d > 9 then d else "0" + d)) + ":"
  ) else b += d + ":")
  b += (if e > 9 then e else "0" + e)
  return b

SecondsToTimeHelper = Ember.Handlebars.makeBoundHelper secondsToTime

`export { secondsToTime }`

`export default SecondsToTimeHelper`
