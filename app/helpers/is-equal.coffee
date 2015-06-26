`import Ember from 'ember'`

isEqual = (leftSide, rightSide) ->
  if leftSide.get('id') and rightSide.get('id')
    return leftSide.get('id') is rightSide.get('id')
  else
    return leftSide is rightSide

IsEqualHelper = Ember.Handlebars.makeBoundHelper isEqual

`export { isEqual }`

`export default IsEqualHelper`
