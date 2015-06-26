`import Ember from 'ember'`

MySelectComponent = Ember.Component.extend
  currentValue: null

  actions:
    changed: (event) ->
      index = event.target.selectedIndex
      options = this.get('options')
      item = if options then options[index] else null
      this.set('currentValue', item)

`export default MySelectComponent`
