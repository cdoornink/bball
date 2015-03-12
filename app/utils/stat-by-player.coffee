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