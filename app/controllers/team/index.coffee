`import Ember from 'ember'`

TeamIndexController = Ember.Controller.extend
  needs: ["team"]
  init: ->
    this.set('player', Ember.Object.create())
  actions:
    createPlayer: ->
      return unless this.get('player.lastName') and this.get('player.number')
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
        newPlayer.save().then =>
          team.save()
          @set('player', Ember.Object.create())
          $('.add-player-form .first-field').focus()

`export default TeamIndexController`
