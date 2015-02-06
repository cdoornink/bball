`import Ember from 'ember'`

TeamOpponentController = Ember.Controller.extend
  needs: ["team"]
  init: ->
    this.set('player', Ember.Object.create())
  actions:
    createPlayer: ->
      team = this.get('model')
      newPlayer = this.store.createRecord('player', {
        firstName: this.get('player.firstName'),
        lastName: this.get('player.lastName'),
        number: this.get('player.number'),
        position: this.get('player.position'),
        year: this.get('player.year'),
        height: this.get('player.height'),
        timestamp: new Date() })
      team.get('players').then (players) =>
        players.addObject(newPlayer)
        team.save().then ->
          newPlayer.save()

`export default TeamOpponentController`
