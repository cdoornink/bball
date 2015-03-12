`import Ember from 'ember'`
`import StatsMixin from 'bball/mixins/stats'`

module 'StatsMixin'

# Replace this with your real tests.
test 'it works', ->
  StatsObject = Ember.Object.extend StatsMixin
  subject = StatsObject.create()
  ok subject
