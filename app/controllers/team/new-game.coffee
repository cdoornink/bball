`import Ember from 'ember'`

TeamNewGameController = Ember.Controller.extend
  needs: ["team"]
  newOpponent: null
  selectedOpponent: null
  selectedPreferences: null
  selectedPeriod: 4
  selectedPeriodLength: 8
  selectedFouls: 5
  periodOptions: [2,4]
  periodLengthOptions: [4,5,6,7,8,9,10,11,12,15,20,24]
  foulOptions: [4,5,6,7,8,9,10]
  init: ->
    this.set('game', Ember.Object.create())
    this.set('pref', Ember.Object.create())
    this.set('opp', Ember.Object.create())
    this.set('player', Ember.Object.create())
  actions:
    createOpponent: ->
      team = this.get('model')
      newTeam = this.store.createRecord 'team',
        organization: this.get('opp.organization')
        mascot: this.get('opp.mascot')
        season: this.get('opp.season')
        location: this.get('opp.location')
        active: true
      newTeam.get('opponents').then (teams) =>
        teams.addObject(team)
        newTeam.save().then ->
          team.save()
      @set('newOpponent', newTeam)
      @set('selectedOpponent', newTeam)

    createPlayer: ->
      team = this.get('newOpponent')
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

    selectOpponent: (team) ->
      @set('selectedOpponent', team)

    selectPreferences: (pref) ->
      @set('selectedPreferences', pref)

    createPreference: ->
      user = @session.get('user')
      newPref = this.store.createRecord 'gamePreference',
        name: this.get('pref.name')
        periodLength: this.get('selectedPeriodLength')
        periods: this.get('selectedPeriod')
        personalFouls: this.get('selectedFouls')
      newPref.set('user', user)
      newPref.save().then ->
        user.save()
      @set('selectedPreferences', newPref)

    createGame: ->
      team1 = this.get('model')
      team2 = this.get('selectedOpponent')
      prefs = this.get('selectedPreferences')
      if !team2 or !prefs
        alert "no prefs or opponent set!"
        return
      newGame = this.store.createRecord 'game',
        date: this.get('game.date')
        location: this.get('game.location')
        status: "created"
        period: 1
      console.log "before"
      newGame.set('preference', prefs)

      console.log "after", newGame.get('preference')
      newGame.get('teams').then (teams) =>
        teams.addObject(team1)
        teams.addObject(team2)
        if @get('game.courtSelect') is "home"
          home = team1
          away = team2
        else
          home = team2
          away = team1
        newGame.set('homeTeam', home)
        newGame.set('awayTeam', away)
        console.log newGame
        newGame.save().then =>
          team1.save()
          team2.save()
          @transitionToRoute('game', newGame)


`export default TeamNewGameController`
