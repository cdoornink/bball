`import Ember from 'ember'`

IndexController = Ember.ObjectController.extend
  init: ->
    this.set('team', Ember.Object.create({primaryColor:"#000000", secondaryColor: "#FFFFFF"}))
  actions:
    createTeam: ->
      user = @session.get('user')
      newTeam = this.store.createRecord 'team',
        organization: this.get('team.organization')
        mascot: this.get('team.mascot')
        season: this.get('team.season')
        primaryColor: this.get('team.primaryColor')
        secondaryColor: this.get('team.secondaryColor')
        active: true
      newTeam.get('owners').then (owners) =>
        owners.addObject(user)
        newTeam.save().then ->
          user.save()

`export default IndexController`
