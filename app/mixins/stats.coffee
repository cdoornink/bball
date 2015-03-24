`import Ember from 'ember'`

StatsMixin = Ember.Mixin.create
  statLine: {points:0,ftm:0,fta:0,fgm:0,fga:0,threepta:0,threeptm:0,assists:0,fouls:0,steals:0,minutes:0,reb:0,oreb:0,dreb:0,blocks:0,turnovers:0,plusminus:0,scoreByPeriod:{}}
  advancedPlayerStats: (stats) ->
    stats.fgp = @percentage(stats.fgm, stats.fga)
    stats.threeptp = @percentage(stats.threeptm, stats.threepta)
    stats.ftp = @percentage(stats.ftm, stats.fta)
    # console.log stats.fgp
  advancedTeamStats: (team, opponent) ->
    l = team.get('teamStats')
    r = opponent.get('teamStats')
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
        @parseStat(stat, ts, side, ps)
        if stat.get('type') is "subbedIn"
          ps['played'] = true
          tempDiff = stat.get('scoreDiff')
          inGame = ((((stat.get('period') - @get('periods')) * -1) * @get('periodLength')) + stat.get('timeLeft'))
        if stat.get('type') is "subbedOut"
          plusminus += (stat.get('scoreDiff') - tempDiff)
          totalMin += inGame - ((((stat.get('period') - @get('periods')) * -1) * @get('periodLength')) + stat.get('timeLeft'))
          inGame = null
        lastStat = stat
      if inGame
        homeDiff = @get('homeScore') - @get('awayScore')
        currentDiff = if lastStat.get('player.team.id') is @get('homeTeam.id') then homeDiff else -homeDiff
        plusminus += (currentDiff - tempDiff)
        totalMin += inGame - ((((@get('period') - @get('periods')) * -1) * @get('periodLength')) + @get('timeLeft'))
      #will also need completely separate logic for overtime shit
    ps['minutes'] = totalMin
    ps['plusminus'] = plusminus
    # console.log ps
    @advancedPlayerStats(ps)
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
