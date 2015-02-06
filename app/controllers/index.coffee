`import Ember from 'ember'`

IndexController = Ember.ObjectController.extend
  init: ->
    this.set('team', Ember.Object.create())
  actions:
    createTeam: ->
      user = @session.get('user')
      console.log "user?", @session.get('user')
      newTeam = this.store.createRecord 'team',
        organization: this.get('team.organization')
        mascot: this.get('team.mascot')
        season: this.get('season')
        location: this.get('location')
        active: true
      newTeam.get('owners').then (owners) =>
        owners.addObject(user)
        newTeam.save().then ->
          user.save()

`export default IndexController`
