`import Ember from 'ember'`

UtilsService = Ember.Service.extend
  test: ->
    return "hi tester"
  statLine: {points:0,ftm:0,fta:0,fgm:0,fga:0,threepta:0,threeptm:0,assists:0,fouls:0,steals:0,minutes:0,reb:0,oreb:0,dreb:0,blocks:0,turnovers:0,plusminus:0,scoreByPeriod:{}}
  statByPlayer: (sbp, player, ts, side) ->
    ps = _.clone(@statLine)
    ps.scoreByPeriod = {}
    inGame = null
    totalMin = 0
    if sbp[player.get('id')]
      sbp[player.get('id')].forEach (stat) =>
        t = stat.get 'type'
        r = stat.get 'result'
        if t is "shot"
          if stat.get('subType') is 'freeThrow'
            @add1('fta', ps, ts)
            if stat.get('result') is 'make'
              @add1('points', ps, ts, 1, stat.get('period'))
              @add1('ftm', ps, ts)
          else if stat.get('result') isnt 'foul'
            @plotShot(side, stat)
            @add1('fga', ps, ts)
            if stat.get('value') is 3 then @add1('threepta', ps, ts)
            if stat.get('result') is 'make' or stat.get('result') is 'and1'
              @add1('points', ps, ts, stat.get('value'), stat.get('period'))
              @add1('fgm', ps, ts)
              if stat.get('value') is 3 then @add1('threeptm', ps, ts)
        if t is "assist" then @add1('assists', ps, ts)
        if t is "foul" then @add1('fouls', ps, ts)
        if t is "rebound"
          @add1('reb', ps, ts)
          if stat.get('subType') is "offensive"
            @add1('oreb', ps, ts)
          else
            @add1('dreb', ps, ts)
        if t is "steal" then @add1('steals', ps, ts)
        if t is "block" then @add1('blocks', ps, ts)
        if t is "turnover" then @add1('turnovers', ps, ts)
        if t is "subbedIn"
          inGame = ((((stat.get('period') - @get('periods')) * -1) * @get('periodLength')) + stat.get('timeLeft'))
        if t is "subbedOut"
          totalMin += inGame - ((((stat.get('period') - @get('periods')) * -1) * @get('periodLength')) + stat.get('timeLeft'))
          inGame = null
    if inGame
      totalMin += inGame
      #will need seperate logic here for in game situations
      #will also need completely separate logic for overtime shit
    ps['minutes'] = totalMin
    player.set('gameStats', ps)
  add1: (stat, ps, ts, value = 1, period) ->
    console.log ts
    ps[stat] = ps[stat] + value
    ts[stat] = ts[stat] + value
    if stat is 'points'
      if period is 1 then p = 'one' else if period is 2 then p = 'two' else if period is 3 then p = "three" else if period is 4 then p = "four"
      if ts.scoreByPeriod[p] is undefined
        ts.scoreByPeriod[p] = value
      else
        ts.scoreByPeriod[p] = ts.scoreByPeriod[p] + value
  plotShot: (side, shot) ->
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

`export default UtilsService`
