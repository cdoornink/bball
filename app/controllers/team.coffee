`import Ember from 'ember'`

TeamController = Ember.ObjectController.extend
  colorChanged: (->
    console.log "changed color"
    return if @get('primaryColor') is undefined
    @get('model').save()
  ).observes('primaryColor', 'secondaryColor')

`export default TeamController`
