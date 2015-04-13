`import Ember from 'ember'`
`import StatsMixin from '../../mixins/stats'`

TeamStatsController = Ember.Controller.extend(StatsMixin,
  opponent: {}
  quarters: false
  periods: 4
  periodLength: 720
  totalLength: 2880
  perNumber: 2120
  getStats: ->
    sbp = {}
    @get('model.preference').then (p) =>
      if p.get('periods') is 4
        @set('quarters', true)
        @set('periods', 4)
      else
        @set('quarters', false)
        @set('periods', 2)
      @set('periodLength', (p.get('periodLength') * 60))
      @set('totalLength', (p.get('periods') * (p.get('periodLength') * 60)))
      @set('perNumber', ((@get('totalLength') / 60) * (3 / 4)))
    @get('model.compiledStats').then (stats) =>
      stats.forEach (stat) ->
        if sbp[stat.get('player.id')] is undefined
          sbp[stat.get('player.id')] = [stat]
        else
          sbp[stat.get('player.id')].push stat

      #player stats
      ts = _.clone(@statLine)
      ts.scoreByPeriod = {}
      @get('model.players').forEach (player) =>
        @statByPlayer(sbp, player, ts, "left")
        player.set('perGameStats', @lineMultiplier(player.get('gameStats'), (1 / @get('model.games.content.length'))))
        player.set('perMinuteStats', @lineMultiplier(player.get('gameStats'), (1 / ((player.get('gameStats.minutes') / 60) / @get('perNumber')))))
        console.log player
      @set('model.teamStats', ts)

      @get('model.opponentStats').then (stats) =>
        ts = _.clone(@statLine)
        ts.scoreByPeriod = {}
        stats.forEach (stat) =>
          @parseStat(stat, ts)
        @set('model.oppStats', ts)
        @set 'opponent', Ember.Object.create({teamStats: ts})

        @advancedTeamStats(@get('model'), @get('opponent'))
        @get('model.players').forEach (player) =>
          @advancedPlayerStats(player)
          console.log player
        #team and opponent per game stats
        @set('model.teamStats.perGame', @lineMultiplier(@get('model.teamStats'), (1 / @get('model.games.content.length'))))
        @set('opponent.teamStats.perGame', @lineMultiplier(@get('opponent.teamStats'), (1 / @get('model.games.content.length'))))
        @set('model.teamStats.diffs', @lineDiffs(@get('model.teamStats'), @get('opponent.teamStats')))
        @set('model.teamStats.perGame.diffs', @lineDiffs(@get('model.teamStats.perGame'), @get('opponent.teamStats.perGame')))
        console.log @get('opponent.teamStats')
        console.log @get('model.teamStats')
)

`export default TeamStatsController`
