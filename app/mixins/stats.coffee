`import Ember from 'ember'`

StatsMixin = Ember.Mixin.create
  statLine: {points:0,ftm:0,fta:0,fgm:0,fga:0,threepta:0,threeptm:0,assists:0,fouls:0,steals:0,minutes:0,reb:0,oreb:0,dreb:0,blocks:0,turnovers:0,plusminus:0,scoreByPeriod:{}}
  inGameAdvancedPlayerStats: (stats) ->
    stats.fgp = @percentage(stats.fgm, stats.fga)
    stats.threeptp = @percentage(stats.threeptm, stats.threepta)
    stats.ftp = @percentage(stats.ftm, stats.fta)
  advancedPlayerStats: (player) ->
    stats = player.get('gameStats')
    player.set 'gameStats.eff', @eff(stats)
    player.set 'gameStats.tsp', @tsp(stats)
    player.set 'gameStats.threePAp', @threePAp(stats) #three point attempt %
    player.set 'gameStats.ftAp', @ftAp(stats) #free throw attempt %
    player.set 'gameStats.oRebp', @oRebp(stats) #offensive rebound %
    player.set 'gameStats.dRebp', @dRebp(stats) #defensive rebound %
    player.set 'gameStats.tRebp', @tRebp(stats) #total rebound %
    player.set 'gameStats.assistp', @assistp(stats) #assist %
    player.set 'gameStats.stealp', @stealp(stats) #steal %
    player.set 'gameStats.blockp', @blockp(stats) #block %
    player.set 'gameStats.turnoverp', @turnoverp(stats) #assist %
    player.set 'gameStats.usagep', @usagep(stats) #assist %
    # console.log stats.fgp
  advancedTeamStats: (team, opponent) ->
    l = team.get('teamStats')
    r = opponent.get('teamStats')
    team.set 'teamStats.fgp', @percentage(l.fgm, l.fga)
    team.set 'teamStats.threeptp', @percentage(l.threeptm, l.threepta)
    team.set 'teamStats.ftpercentage', @percentage(l.ftm, l.fta)
    opponent.set 'teamStats.fgp', @percentage(r.fgm, r.fga)
    opponent.set 'teamStats.threeptp', @percentage(r.threeptm, r.threepta)
    opponent.set 'teamStats.ftpercentage', @percentage(r.ftm, r.fta)
    # 4 factors
    team.set 'teamStats.efg', @efg(l.fgm, l.threeptm, l.fga)
    opponent.set 'teamStats.efg', @efg(r.fgm, r.threeptm, r.fga)
    team.set 'teamStats.tov', @tov(l.turnovers, l.fga, l.fta)
    opponent.set 'teamStats.tov', @tov(r.turnovers, r.fga, r.fta)
    team.set 'teamStats.orb', @orb(l.oreb, r.reb, r.oreb)
    opponent.set 'teamStats.orb', @orb(r.oreb, l.reb, l.oreb)
    team.set 'teamStats.ftp', @ftp(l.ftm, l.fga)
    opponent.set 'teamStats.ftp', @ftp(r.ftm, r.fga)
    # pace, offensive and defensive ratings
    team.set 'teamStats.poss', @poss(l, r)
    opponent.set 'teamStats.poss', @poss(r, l)
    team.set 'teamStats.ortg', @ortg(l)
    opponent.set 'teamStats.ortg', @ortg(r)

  lineMultiplier: (stats, multiplier) ->
    _.mapObject stats, (value, stat) -> Math.round((value * multiplier)*10) / 10

  lineDiffs: (stats, diffStats) ->
    _.mapObject stats, (value, stat) -> Math.round((value - diffStats[stat])*10) / 10

  percentage: (x,y) ->
    if y is 0
      "-"
    else
      Math.round((x / y) * 1000) / 10

  efg: (fgm, tpm, fga) ->
    x = (fgm + 0.5 * tpm) / fga
    Math.round(x*1000) / 10
  tov: (to, fga, fta) ->
    x = to / (fga + (0.44 * fta) + to)
    Math.round(x*1000) / 10
  orb: (orb, oppReb, oppOReb) ->
    oppDrb = oppReb - oppOReb
    x = orb / (orb + oppDrb)
    Math.round(x*1000) / 10
  ftp: (ft, fga) ->
    x = ft / fga
    Math.round(x*1000) / 10
  poss: (tm, opp) ->
    oppDrb = opp.reb - opp.oreb
    tmDrb = tm.reb - tm.oreb
    p = 0.5 * ((tm.fga + 0.4 * tm.fta - 1.07 * (tm.oreb / (tm.oreb + oppDrb)) * (tm.fga - tm.fgm) + tm.turnovers) + (opp.fga + 0.4 * opp.fta - 1.07 * (opp.oreb / (opp.oreb + tmDrb)) * (opp.fga - opp.fgm) + opp.turnovers))
    Math.round(p*10) / 10
  ortg: (tm) ->
    x = (tm.points / tm.poss) * 100
    Math.round(x*10) / 10

  teamMP: ->
    5 * (@get("model.preference.periods") * @get("model.preference.periodLength") * @get("model.games.content.length"))

  eff: (stats) ->
    Math.round((stats.points + stats.reb + stats.assists + stats.steals + stats.blocks - (stats.fga - stats.fgm) - (stats.fta - stats.ftm) - stats.turnovers) / ((stats.minutes / 60) / 36) * 10) / 10
  tsp: (stats) ->
    Math.round((stats.points / (2 * (stats.fga + (.44 * stats.fta)))) * 1000) / 10
  threePAp: (stats) ->
    @percentage(stats.threepta, stats.fga)
  ftAp: (stats) ->
    @percentage(stats.fta, stats.fga)
  oRebp: (stats) ->
    Math.round(100 * (stats.oreb * (@teamMP() / 5)) / ((stats.minutes / 60) * (@get('model.teamStats.oreb') + @get('opponent.teamStats.dreb'))) * 10) / 10
  dRebp: (stats) ->
    Math.round(100 * (stats.dreb * (@teamMP() / 5)) / ((stats.minutes / 60) * (@get('model.teamStats.dreb') + @get('opponent.teamStats.oreb'))) * 10) / 10
  tRebp: (stats) ->
    Math.round(100 * (stats.reb * (@teamMP() / 5)) / ((stats.minutes / 60) * (@get('model.teamStats.reb') + @get('opponent.teamStats.reb'))) * 10) / 10
  assistp: (stats) ->
    Math.round(100 * stats.assists / ((((stats.minutes / 60) / (@teamMP() / 5)) * @get('model.teamStats.fgm')) - stats.fgm) * 10) / 10
  stealp: (stats) ->
    Math.round(100 * (stats.steals * (@teamMP() / 5)) / ((stats.minutes / 60) * @get('model.teamStats.poss')) * 10) / 10
  blockp: (stats) ->
    Math.round(100 * (stats.blocks * (@teamMP() / 5)) / ((stats.minutes / 60) * (@get('opponent.teamStats.fga') - @get('opponent.teamStats.threepta'))) * 10) / 10
  turnoverp: (stats) ->
    Math.round(100 * stats.turnovers / (stats.fga + 0.44 * stats.fta + stats.turnovers) * 10) / 10
  usagep: (stats) ->
    Math.round(100 * ((stats.fga + 0.44 * stats.fta + stats.turnovers) * (@teamMP() / 5)) / ((stats.minutes / 60) * (@get('model.teamStats.fga') + 0.44 * @get('model.teamStats.fta') + @get('model.teamStats.turnovers'))) * 10) / 10

  compareGameId: (stat, lastStat) ->
    stat.get('game.id') isnt lastStat.get('game.id')

  statByPlayer: (sbp, player, ts, side) ->
    ps = _.clone(@statLine)
    ps.scoreByPeriod = {}
    inGame = null
    tempDiff = 0
    plusminus = 0
    lastStat = null
    totalMin = 0
    if sbp[player.get('id')]
      sbp[player.get('id')].forEach (stat) =>
        if lastStat
          newGame = @compareGameId(stat, lastStat)
          if newGame and inGame
            homeDiff = lastStat.get('game.homeScore') - lastStat.get('game.awayScore')
            currentDiff = if lastStat.get('player.team.id') is lastStat.get('game.homeTeam.id') then homeDiff else -homeDiff
            plusminus += (currentDiff - tempDiff)
            totalMin += inGame - ((((lastStat.get('game.period') - @get('periods')) * -1) * @get('periodLength')) + lastStat.get('game.timeLeft'))
        @parseStat(stat, ts, side, ps)
        if stat.get('type') is "subbedIn"
          ps['played'] = true
          tempDiff = stat.get('scoreDiff')
          inGame = ((((stat.get('period') - @get('periods')) * -1) * @get('periodLength')) + (stat.get('timeLeft') || @get('periodLength')))
        if stat.get('type') is "subbedOut"
          plusminus += (stat.get('scoreDiff') - tempDiff)
          totalMin += inGame - ((((stat.get('period') - @get('periods')) * -1) * @get('periodLength')) + (stat.get('timeLeft') || @get('periodLength')))
          inGame = null
        # This part of the two above equations: (stat.get('timeLeft') || @get('periodLength')) is a Hack. If minutes are looking weird, try taking this out. It was to fix a bug where the timeLEft wasn't getting saved to the database for the first subbedIn instances of a game. Trying to fix it at the source instead of here.
        lastStat = stat
      if inGame
        homeDiff = lastStat.get('game.homeScore') - lastStat.get('game.awayScore')
        currentDiff = if lastStat.get('player.team.id') is lastStat.get('game.homeTeam.id') then homeDiff else -homeDiff
        plusminus += (currentDiff - tempDiff)
        totalMin += inGame - ((((lastStat.get('game.period') - @get('periods')) * -1) * @get('periodLength')) + lastStat.get('game.timeLeft'))
        #will also need completely separate logic for overtime shit
    ps['minutes'] = totalMin
    ps['plusminus'] = plusminus
    @inGameAdvancedPlayerStats(ps)
    player.set('gameStats', ps)
  parseStat: (stat, ts, side, player) ->
    t = stat.get 'type'
    r = stat.get 'result'
    if t is "shot"
      if stat.get('subType') is 'freeThrow'
        @add1('fta', ts, player)
        if stat.get('result') is 'make'
          @add1('points', ts, player, 1, stat.get('period'))
          @add1('ftm', ts, player)
      else if stat.get('result') isnt 'foul'
        @plotShot(side, stat)
        @add1('fga', ts, player)
        if stat.get('value') is 3 then @add1('threepta', ts, player)
        if stat.get('result') is 'make' or stat.get('result') is 'and1'
          @add1('points', ts, player, stat.get('value'), stat.get('period'))
          @add1('fgm', ts, player)
          if stat.get('value') is 3 then @add1('threeptm', ts, player)
    if t is "assist" then @add1('assists', ts, player)
    if t is "foul" then @add1('fouls', ts, player)
    if t is "rebound"
      @add1('reb', ts, player)
      if stat.get('subType') is "offensive"
        @add1('oreb', ts, player)
      else
        @add1('dreb', ts, player)
    if t is "steal" then @add1('steals', ts, player)
    if t is "block" then @add1('blocks', ts, player)
    if t is "turnover" then @add1('turnovers', ts, player)
  add1: (stat, ts, ps, value = 1, period) ->
    if ps then ps[stat] = ps[stat] + value
    ts[stat] = ts[stat] + value
    if stat is 'points' and period
      if period is 1 then p = 'one' else if period is 2 then p = 'two' else if period is 3 then p = "three" else if period is 4 then p = "four"
      if ts.scoreByPeriod[p] is undefined
        ts.scoreByPeriod[p] = value
      else
        ts.scoreByPeriod[p] = ts.scoreByPeriod[p] + value
  plotShot: (side, shot) ->
    return unless @get('court')
    r = shot.get('result')
    result = if r is "make" or r is "and1" then "made-shot" else "missed-shot"
    if side is "left"
      top = shot.get('y') * @get('court.height')
      left = shot.get('x') * @get('court.width')
    else
      top = (.96 - shot.get('y')) * @get('court.height')
      left = (.99 - shot.get('x')) * @get('court.width')
    shotDot = "<div class='shot-dot #{result} #{shot.get("player.id")} #{shot.get("period")}' style='top:#{top}px; left:#{left}px;'>x<div>"
    @get('court.el').append(shotDot)

`export default StatsMixin`
