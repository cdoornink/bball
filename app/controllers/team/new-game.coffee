`import Ember from 'ember'`

TeamNewGameController = Ember.Controller.extend
  needs: ["team"]
  selectedOpponent: null
  courtSelect: null
  oneTeamMode: false
  init: ->
    this.set('game', Ember.Object.create())
    this.set('opp', Ember.Object.create())
    this.set('player', Ember.Object.create())
  actions:
    createOpponent: ->
      team = this.get('model')
      prefs = team.get('preference')
      newTeam = this.store.createRecord 'team',
        organization: this.get('opp.organization')
        mascot: this.get('opp.mascot')
        season: this.get('opp.season')
        location: this.get('opp.location')
        active: true
      newTeam.set('preference', prefs)
      newTeam.get('opponents').then (teams) =>
        teams.addObject(team)
        newTeam.save().then =>
          team.save()
          @send('selectOpponent', newTeam)

    selectOpponent: (team) ->
      @set('selectedOpponent', team)
      $(".opponent-grid-item").removeClass('selected')
      $(".opponent-grid-item.#{team.id}").addClass('selected')

    createGame: ->
      team1 = this.get('model')
      team2 = this.get('selectedOpponent')
      prefs = team1.get('preference')
      if !team2
        alert "no opponent set!"
        return
      newGame = this.store.createRecord 'game',
        date: this.get('game.date')
        location: this.get('game.location')
        status: "created"
        period: 1
      newGame.set('preference', prefs)
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
        if @get('game.oneTeamMode') is "true"
          newGame.set('ignoredTeam', team2)
        newGame.save().then =>
          team1.save()
          team2.save()
          @transitionToRoute('game', newGame)


`export default TeamNewGameController`
