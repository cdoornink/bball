`import Ember from 'ember'`
`import StatsMixin from '../../mixins/stats'`

TeamStatsController = Ember.Controller.extend(StatsMixin,
  opponent: {}
  getStats: ->
    sbp = {}
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
      @set('model.teamStats', ts)

      @get('model.opponentStats').then (stats) =>
        ts = _.clone(@statLine)
        ts.scoreByPeriod = {}
        stats.forEach (stat) =>
          @parseStat(stat, ts)
        @set('model.oppStats', ts)
        @set 'opponent', Ember.Object.create({teamStats: ts})

        @advancedTeamStats(@get('model'), @get('opponent'))
        console.log @get('opponent.teamStats')
        console.log @get('model.teamStats')
)

`export default TeamStatsController`
