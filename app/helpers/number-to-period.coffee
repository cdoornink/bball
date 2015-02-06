`import Ember from 'ember'`

numberToPeriod = (value) ->
  if value is undefined
    return
  if value is 1
    return '1st'
  if value is 2
    return '2nd'
  if value is 3
    return '3rd'
  if value is 4
    return '4th'
  if value >= 11
    return 'OT'
  if value >= 12
    return '2OT'
  if value >= 13
    return '3OT'
  if value >= 14
    return '4OT'
  if value >= 15
    return '5OT'
  if value >= 16
    return '6OT'
  if value >= 17
    return '7OT'
  if value >= 18
    return '8OT'
  if value >= 19
    return '9OT'

NumberToPeriodHelper = Ember.Handlebars.makeBoundHelper numberToPeriod

`export { numberToPeriod }`

`export default NumberToPeriodHelper`
