`import Ember from 'ember'`

TeamNewGameView = Ember.View.extend
  didInsertElement: ->
    $(".team-page-header").hide()
  willDestroyElement: ->
    $(".team-page-header").show()

`export default TeamNewGameView`
