`import Ember from 'ember'`

TeamController = Ember.Controller.extend
  colorChanged: (->
    console.log "changed color"
    return if @get('model.primaryColor') is undefined
    @get('model').save()
  ).observes('model.primaryColor', 'model.secondaryColor')

`export default TeamController`
