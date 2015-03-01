`import Ember from 'ember'`

GameController = Ember.ObjectController.extend
  leftOnCourt: {}
  leftOnCourtArray: []
  leftBench: []
  rightOnCourt: {}
  rightOnCourtArray: []
  rightBench: []
  minutesLeft: (->
    Math.floor(@get('timeLeft') % 3600 / 60)
  ).property("model.timeLeft")
  secondsLeft: (->
    Math.floor(@get('timeLeft') % 3600 % 60)
  ).property("model.timeLeft")
  selectedPlayer: null
  leftPlayerSelected: false
  rightPlayerSelected: false
  quarters: false
  periods: 4
  periodLength: 720
  totalLength: 2880
  court: {}
  statLine: {points: 0,ftm: 0,fta: 0,fgm: 0,fga: 0,threepta: 0,threeptm: 0,assists: 0,fouls: 0,steals: 0,minutes: 0,reb: 0,oreb: 0,dreb: 0,blocks: 0,turnovers: 0,plusminus: 0,scoreByPeriod:{}}
  rightColorChanged: (->
    return if @get('right.primaryColor') is undefined
    $('.right-primary').css('background', @get('right.primaryColor'))
    @addTeamColorStyle()
    @get('right').save()
  ).observes('right.primaryColor', 'right.secondaryColor')
  leftColorChanged: (->
    return if @get('left.primaryColor') is undefined
    $('.left-primary').css('background', @get('left.primaryColor'))
    @addTeamColorStyle()
    @get('left').save()
  ).observes('left.primaryColor', 'left.secondaryColor')
  addTeamColorStyle: ->
    if $('html > head > style').length
      $('html > head > style').last().remove();
    $('html > head')
      .append("<style>
                .right-primary, .right-team .player-card {
                  background: #{@get('right.primaryColor')};
                }
                .right-secondary, .right-team .player-card {
                  color: #{@get('right.secondaryColor')};
                }
                .left-primary, .left-team .player-card {
                  background: #{@get('left.primaryColor')};
                }
                .left-secondary, .left-team .player-card {
                  color: #{@get('left.secondaryColor')};
                }
              </style>");

  getStats: ->
    @get('preference').then (p) =>
      if p.get('periods') is 4
        @set('quarters', true)
        @set('periods', 4)
      else
        @set('periods', 2)
      @set('periodLength', (p.get('periodLength') * 60))
      @set('totalLength', (p.get('periods') * (p.get('periodLength') * 60)))
    @get('stats').then (stats) =>
      console.time("compile stats")
      console.time("compile stats w/ advanced")

      if stats.length is 0 or stats.length is undefined
        @newGameMessage()

      #lineups
      loc = []
      roc = []
      #all shots
      rshots = []
      lshots = []
      #stats by player
      sbp = {}

      @set 'playByPlayScoreLeft', 0
      @set 'playByPlayScoreRight', 0
      @set "playByPlay", []

      @set "court.el", $(".full-court")
      @set "court.width", parseInt(@get('court.el').width())
      @set "court.height", parseInt(@get('court.width') / 1.766)

      stats.forEach (stat) =>
        if stat.get('type') is "subbedIn"
          if stat.get('team.id') is @get('left.id')
            loc.push(stat)
          #this was failing after half a game with the clippers, team.id was undefined, just for the one team, even if I switched sides
          else if stat.get('team.id') is @get('right.id')
            roc.push(stat)
        if sbp[stat.get('player.id')] is undefined
          sbp[stat.get('player.id')] = [stat]
        else
          sbp[stat.get('player.id')].push stat
        @addPlayByPlay(stat)

      l = {}
      loc.forEach (sub) ->
        l[sub.get("subType")] = sub.get("player")
      @set('leftOnCourt', l)
      locArray = _.map l, (p) -> p.content.id
      leftOnCourtArray = _.map l, (p) -> p
      @set('leftOnCourtArray', leftOnCourtArray)
      lb = []
      @get('left.players').forEach (player) ->
        if _.indexOf(locArray, player.id) is -1
          lb.push player
      @set('leftBench', lb)
      r = {}
      roc.forEach (sub) ->
        r[sub.get("subType")] = sub.get("player")
      @set('rightOnCourt', r)
      rocArray = _.map r, (p) -> p.content.id
      rightOnCourtArray = _.map r, (p) -> p
      @set('rightOnCourtArray', rightOnCourtArray)
      rb = []
      @get('right.players').forEach (player) ->
        if _.indexOf(rocArray, player.id) is -1
          rb.push player
      @set('rightBench', rb)

      #scoreboard
      unless @get('timeLeft')
        @set('model.timeLeft', @get('preference.periodLength') * 60)

      #player stats
      @get('court.el').empty()
      ts = _.clone(@statLine)
      ts.scoreByPeriod = {}
      @get('left.players').forEach (player) =>
        @statByPlayer(sbp, player, ts, "left")
      @set('left.teamStats', ts)

      ts = _.clone(@statLine)
      ts.scoreByPeriod = {}
      @get('right.players').forEach (player) =>
        @statByPlayer(sbp, player, ts, "right")
      @set('right.teamStats', ts)
      console.timeEnd("compile stats")
      if @get('status', "Final")
        @advancedTeamStats()
        console.timeEnd("compile stats w/ advanced")

  add1: (stat, ps, ts, value = 1, period) ->
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

  playByPlay: []
  playByPlaySubQueue: null
  playByPlayScoreLeft: 0
  playByPlayScoreRight: 0
  lastTimeLeft: null
  addPlayByPlay: (p) ->
    pbp = @get('playByPlay')
    t = p.get('type')
    sT = p.get('subType')
    r = p.get('result')
    play = null
    left = p.get('team.id') is @get('left.id')
    period = p.get('period')
    if period is 1
      period = "first"
    else if period is 2
      period = "second"
    else if period is 3
      period = "third"
    else if period is 4
      period = "fourth"
    else
      period = "overtime"

    if t is "subbedIn"
      @set 'playByPlaySubQueue', p.get('player')
      return
    else if t is "subbedOut"
      play = {left: left, sub: true, in: @get('playByPlaySubQueue'), out: p.get('player')}
      @set 'playByPlaySubQueue', null
    else if t is "shot"
      play = {left: left, shot: true, player: p.get('player'), recipient: p.get('recipient')}
      if r is "make"
        play["make"] = true
      if r is "foul"
        play["shootingFoul"] = true
        play["fouler"] = p.get('fouler')
      if r is "block"
        play["block"] = true
      if r is "and1"
        play["make"] = true
        play["and1"] = true
        play["fouler"] = p.get('fouler')
      if sT is "freethrow"
        play["freethrow"] = true
      if sT is "freeThrow"
        sT = "free throw"
      play["shotType"] = sT
      if p.get('value') is 3
        play["shotType"] = "three pointer"
      if p.get('value') and (r is 'make' or r is 'and1')
        scoreAtMoment = @get('playByPlayScoreLeft')
        if left
          @set('playByPlayScoreLeft', @get('playByPlayScoreLeft') + p.get('value'))
        else
          @set('playByPlayScoreRight', @get('playByPlayScoreRight') + p.get('value'))
        play["scoreAtMoment"] = "#{@get('playByPlayScoreLeft')} - #{@get('playByPlayScoreRight')}"
        play["score#{p.get('value')}"] = true
    else if t is "rebound"
      offensive = p.get('subType') is "offensive"
      play = {left: left, rebound: true, player: p.get('player'), offensive: offensive}
    else if t is "foul" and sT isnt "shooting"
      play = {left: left, foul: true, player: p.get('player'), foulType: sT}
    else if t is "turnover"
      play = {left: left, turnover: true, player: p.get('player'), recipient: p.get('recipient')}

    if play
      tL = p.get('timeLeft')
      unless tL is @get('lastTimeLeft')
        play["timeLeft"] = tL
        @set("lastTimeLeft", tL)
      if pbp[period] is undefined
        pbp[period] = [play]
      else
        pbp[period].push play
      if pbp["recent"] is undefined
        pbp["recent"] = [play]
      else
        pbp["recent"].unshift play
        if pbp["recent"].length > 5 then pbp["recent"].pop()

      @set 'playByPlaySubQueue', null
    @set('playByPlay', pbp)

  advancedTeamStats: ->
    l = @get('left.teamStats')
    r = @get('right.teamStats')
    # 4 factors
    @set 'left.teamStats.efg', @efg(l.fgm, l.threeptm, l.fga)
    @set 'right.teamStats.efg', @efg(r.fgm, r.threeptm, r.fga)
    @set 'left.teamStats.tov', @tov(l.turnovers, l.fga, l.fta)
    @set 'right.teamStats.tov', @tov(r.turnovers, r.fga, r.fta)
    @set 'left.teamStats.orb', @orb(l.oreb, r.reb, r.oreb)
    @set 'right.teamStats.orb', @orb(r.oreb, l.reb, l.oreb)
    @set 'left.teamStats.ftp', @ftp(l.ftm, l.fga)
    @set 'right.teamStats.ftp', @ftp(r.ftm, r.fga)

    @set 'left.teamStats.poss', @poss(l, r)
    @set 'right.teamStats.poss', @poss(r, l)
    @set 'left.teamStats.ortg', @ortg(l)
    @set 'right.teamStats.ortg', @ortg(r)




  efg: (fgm, tpm, fga) ->
    (fgm + 0.5 * tpm) / fga
  tov: (to, fga, fta) ->
    to / (fga + (0.44 * fta) + to)
  orb: (orb, oppReb, oppOReb) ->
    oppDrb = oppReb - oppOReb
    orb / (orb + oppDrb)
  ftp: (ft, fga) ->
    ft / fga
  poss: (tm, opp) ->
    oppDrb = opp.reb - opp.oreb
    tmDrb = tm.reb - tm.oreb
    0.5 * ((tm.fga + 0.4 * tm.fta - 1.07 * (tm.oreb / (tm.oreb + oppDrb)) * (tm.fga - tm.fgm) + tm.turnovers) + (opp.fga + 0.4 * opp.fta - 1.07 * (opp.oreb / (opp.oreb + tmDrb)) * (opp.fga - opp.fgm) + opp.turnovers))
  ortg: (tm) ->
    (tm.points / tm.poss) * 100

  saveGame: ->
    console.count('save game')
    @get('model').save()
    @getStats()

  endGame: ->
    conf = {
      message: "Do you want to end this game now? Stats can still be edited in the box score after the game has ended."
      header: "Game Over?"
      continue: =>
        @send('submitEndGame')
    }
    @send('openModal', 'modals/confirmation', conf)

  actions:

    submitEndGame: ->
      if @get('homeTeam.id') is @get('left.id')
        home = @get('left')
        away = @get('right')
      else
        home = @get('right')
        away = @get('left')
      @set('homeScore', home.teamStats.points)
      @set('awayScore', away.teamStats.points)
      @set('status', "Final")
      @set('timeLeft', 0)
      @set('period', "Final")
      @saveGame()

    jumpBall: (team) ->
      @set('model.possession', team)
      @set('model.status', "active")
      @saveGame()

    #TODO if player gets rebound or steal (ends up with possession, make them the selected player)
    selectPlayer: (ops) ->
      @set('selectedPlayer', ops.player)
      if ops.player.get('team.id') is @get('left.id')
        @set('leftPlayerSelected', true)
        @set('rightPlayerSelected', false)
      else
        @set('leftPlayerSelected', false)
        @set('rightPlayerSelected', true)
      $('.on-court .player-card').removeClass('selected')
      ops.el.addClass('selected')

    shot: (ops) ->
      @send('openModal', 'modals/shot', ops)
    submitShot: (shot) ->
      if (shot.result is 'make' or shot.result is 'and1') and shot.assister
        shot.recipient = shot.assister
        assisted = true
      if (shot.result is 'block') and shot.blocker
        shot.recipient = shot.blocker
        blocked = true
      s = this.store.createRecord 'stat',
        type: "shot"
        period: @get('period')
        timeLeft: @get('timeLeft')
        subType: shot.subType or 'jumper'
        x: shot.x
        y: shot.y
        result: shot.result
        value: shot.value
      s.set('team', @get('selectedPlayer.team'))
      s.set('player', @get('selectedPlayer'))
      s.set('recipient', shot.recipient)
      if shot.fouler
        s.set('fouler', shot.fouler)
      s.set('game', @get('model'))
      s.save().then =>
        @store.find('player', @get('selectedPlayer.id')).then (player) =>
          player.save()
        @saveGame()
        if (shot.result is 'foul' or shot.result is 'and1')
          freeThrowValue = if shot.result is 'and1' then 1 else shot.value
          @send('openModal', 'modals/freethrow', {shooting: freeThrowValue})
      if assisted
        assist = this.store.createRecord 'stat',
          type: "assist"
          period: @get('period')
          timeLeft: @get('timeLeft')
        assist.set('team', shot.assister.get('team'))
        assist.set('player', shot.assister)
        assist.set('recipient', @get('selectedPlayer'))
        assist.set('game', @get('model'))
        assist.save().then =>
          @store.find('player', shot.assister.get('id')).then (player) =>
            player.save()
          @saveGame()
      if blocked
        block = this.store.createRecord 'stat',
          type: "block"
          period: @get('period')
          timeLeft: @get('timeLeft')
        block.set('team', shot.blocker.get('team'))
        block.set('player', shot.blocker)
        block.set('recipient', @get('selectedPlayer'))
        block.set('game', @get('model'))
        block.save().then =>
          @store.find('player', shot.blocker.get('id')).then (player) =>
            player.save()
          @saveGame()
      if (shot.result is 'miss' or shot.result is 'block') and shot.rebounder
        if shot.rebounder.get('team.id') is @get('selectedPlayer.team.id')
          subType = 'offensive'
        else
          subType = 'defensive'
        rebound = this.store.createRecord 'stat',
          type: "rebound"
          period: @get('period')
          timeLeft: @get('timeLeft')
          subType: subType
        rebound.set('team', shot.rebounder.get('team'))
        rebound.set('player', shot.rebounder)
        rebound.set('game', @get('model'))
        rebound.save().then =>
          @store.find('player', shot.rebounder.get('id')).then (player) =>
            player.save()
          @saveGame()
      if (shot.result is 'foul' or shot.result is 'and1') and shot.fouler
        foul = this.store.createRecord 'stat',
          type: "foul"
          period: @get('period')
          timeLeft: @get('timeLeft')
          subType: 'shooting'
        foul.set('team', shot.fouler.get('team'))
        foul.set('player', shot.fouler)
        foul.set('game', @get('model'))
        foul.save().then =>
          @store.find('player', shot.fouler.get('id')).then (player) =>
            player.save()
          @saveGame()

    freeThrowButton: ->
      @send('openModal', 'modals/freethrow', {shooting: 2})
    submitFreeThrows: (model) ->
      shot = this.store.createRecord 'stat',
        type: "shot"
        period: @get('period')
        timeLeft: @get('timeLeft')
        subType: 'freeThrow'
        result: model.result1
        value: 1
      shot.set('team', @get('selectedPlayer.team'))
      shot.set('player', @get('selectedPlayer'))
      if model.shooting is 1 and model.result is "miss"
        shot.set('recipient', model.rebounder)
      shot.set('game', @get('model'))
      shot.save().then =>
        if model.shooting is 1
          @store.find('player', @get('selectedPlayer.id')).then (player) =>
            player.save()
          @saveGame()
      if model.shooting > 1
        shot2 = this.store.createRecord 'stat',
          type: "shot"
          period: @get('period')
          timeLeft: @get('timeLeft')
          subType: 'freeThrow'
          result: model.result2
          value: 1
        shot2.set('team', @get('selectedPlayer.team'))
        shot2.set('player', @get('selectedPlayer'))
        if model.shooting is 2 and model.result is "miss"
          shot.set('recipient', model.rebounder)
        shot2.set('game', @get('model'))
        shot2.save().then =>
          if model.shooting is 2
            @store.find('player', @get('selectedPlayer.id')).then (player) =>
              player.save()
            @saveGame()
      if model.shooting > 2
        shot3 = this.store.createRecord 'stat',
          type: "shot"
          period: @get('period')
          timeLeft: @get('timeLeft')
          subType: 'freeThrow'
          result: model.result3
          value: 1
        shot3.set('team', @get('selectedPlayer.team'))
        shot3.set('player', @get('selectedPlayer'))
        if model.shooting is 3 and model.result is "miss"
          shot.set('recipient', model.rebounder)
        shot3.set('game', @get('model'))
        shot3.save().then =>
          if model.shooting is 3
            @store.find('player', @get('selectedPlayer.id')).then (player) =>
              player.save()
            @saveGame()
      if model.rebounder
        if model.rebounder.get('team.id') is @get('selectedPlayer.team.id')
          subType = 'offensive'
        else
          subType = 'defensive'
        rebound = this.store.createRecord 'stat',
          type: "rebound"
          period: @get('period')
          timeLeft: @get('timeLeft')
          subType: subType
        rebound.set('team', model.rebounder.get('team'))
        rebound.set('player', model.rebounder)
        rebound.set('game', @get('model'))
        rebound.save().then =>
          @store.find('player', model.rebounder.get('id')).then (player) =>
            player.save()
          @saveGame()

    foulButton: ->
      @send('openModal', 'modals/foul', {subType: "defensive"})
    submitFoul: (model) ->
      foul = this.store.createRecord 'stat',
        type: "foul"
        period: @get('period')
        timeLeft: @get('timeLeft')
        subType: model.subType or "defensive"
      foul.set('team', @get('selectedPlayer.team'))
      foul.set('player', @get('selectedPlayer'))
      foul.set('game', @get('model'))
      foul.save().then =>
        @store.find('player', @get('selectedPlayer.id')).then (player) =>
          player.save()
          if model.subType is "offensive"
            @send('submitTurnover', model)
        @saveGame()


    reboundButton: ->
      @send('openModal', 'modals/rebound', {subType: 'defensive'})
    submitRebound: (model) ->
      rebound = this.store.createRecord 'stat',
        type: "rebound"
        period: @get('period')
        timeLeft: @get('timeLeft')
        subType: model.subType
      rebound.set('team', @get('selectedPlayer.team'))
      rebound.set('player', @get('selectedPlayer'))
      rebound.set('game', @get('model'))
      rebound.save().then =>
        @store.find('player', @get('selectedPlayer.id')).then (player) =>
          player.save()
        @saveGame()

    blockButton: ->
      @send('openModal', 'modals/block', {})
    submitBlock: (model) ->
      block = this.store.createRecord 'stat',
        type: "block"
        period: @get('period')
        timeLeft: @get('timeLeft')
      block.set('team', @get('selectedPlayer.team'))
      block.set('player', @get('selectedPlayer'))
      block.set('game', @get('model'))
      block.save().then =>
        @store.find('player', @get('selectedPlayer.id')).then (player) =>
          player.save()
        @saveGame()
      if  model.rebounder
        if model.rebounder.get('team.id') is @get('selectedPlayer.team.id')
          subType = 'defensive'
        else
          subType = 'offensive'
        rebound = this.store.createRecord 'stat',
          type: "rebound"
          period: @get('period')
          timeLeft: @get('timeLeft')
          subType: subType
        rebound.set('team', model.rebounder.get('team'))
        rebound.set('player', model.rebounder)
        rebound.set('game', @get('model'))
        rebound.save().then =>
          @store.find('player', model.rebounder.get('id')).then (player) =>
            player.save()
          @saveGame()

    drawChargeButton: ->
      @send('openModal', 'modals/charge', {})
    submitDrawnCharge: ->
      c = this.store.createRecord 'stat',
        type: "drawnCharge"
        period: @get('period')
        timeLeft: @get('timeLeft')
      c.set('team', @get('selectedPlayer.team'))
      c.set('player', @get('selectedPlayer'))
      c.set('game', @get('model'))
      c.save().then =>
        @store.find('player', @get('selectedPlayer.id')).then (player) =>
          player.save()
        @saveGame()

    turnoverButton: ->
      @send('openModal', 'modals/turnover', {})
    submitTurnover: (model) ->
      turnover = this.store.createRecord 'stat',
        type: "turnover"
        period: @get('period')
        timeLeft: @get('timeLeft')
      turnover.set('team', @get('selectedPlayer.team'))
      turnover.set('player', @get('selectedPlayer'))
      if model.stealer
        turnover.set('recipient', model.stealer)
      turnover.set('game', @get('model'))
      turnover.save().then =>
        @store.find('player', @get('selectedPlayer.id')).then (player) =>
          player.save()
          if model.stealer
            steal = this.store.createRecord 'stat',
              type: "steal"
              period: @get('period')
              timeLeft: @get('timeLeft')
            steal.set('team', model.stealer.get('team'))
            steal.set('player', model.stealer)
            steal.set('game', @get('model'))
            steal.save().then =>
              @store.find('player', model.stealer.get('id')).then (player) =>
                player.save()
              @saveGame()
        @saveGame()


    stealButton: ->
      @send('openModal', 'modals/steal', {})
    submitSteal: (model) ->
      steal = this.store.createRecord 'stat',
        type: "steal"
        period: @get('period')
        timeLeft: @get('timeLeft')
      steal.set('team', @get('selectedPlayer.team'))
      steal.set('player', @get('selectedPlayer'))
      steal.set('game', @get('model'))
      steal.save().then =>
        @store.find('player', @get('selectedPlayer.id')).then (player) =>
          player.save()
          if model.turnoverer
            turnover = this.store.createRecord 'stat',
              type: "turnover"
              period: @get('period')
              timeLeft: @get('timeLeft')
            turnover.set('team', model.turnoverer.get('team'))
            turnover.set('player', model.turnoverer)
            turnover.set('game', @get('model'))
            turnover.save().then =>
              @store.find('player', model.turnoverer.get('id')).then (player) =>
                player.save()
              @saveGame()
        @saveGame()


    endPeriod: ->
      period = @get('period')
      @get('preference').then (p) =>
        if period is p.get('periods')
          r = @get('right.teamStats.score')
          l = @get('left.teamStats.score')
          if r = l
            @set('period', "OT")
            @set('timeLeft', 300)
          else
            @endGame()
        else
          @set('period', (period + 1))
          @set('timeLeft', p.get('periodLength')*60)
        @saveGame()

    changeTime: ->
      @send('openModal', 'modals/time', {})
    submitTimeLeft: (s) ->
      @set('model.timeLeft', s)
      @saveGame()

    substitute: (player, ops) ->
      if @get('status') is "created"
        @send('submitSubstitute', player, ops)
      else
        @send('openModal', 'modals/time', {continue: => @send('submitSubstitute', player, ops)})

    submitSubstitute: (player, ops) ->
      #show time update modal, pass through params and call a sub function from that
      if ops.target.current
        subbedOut = ops.target.current.content
      stat = this.store.createRecord 'stat',
        type: "subbedIn"
        period: @get('period')
        timeLeft: @get('timeLeft')
        subType: ops.target.slot
      stat.set('team', player.get('team'))
      stat.set('player', player)
      stat.set('game', @get('model'))
      stat.save().then =>
        player.save()
        @saveGame()
        if subbedOut
          stat = this.store.createRecord 'stat',
            type: "subbedOut"
            period: @get('period')
            timeLeft: @get('timeLeft')
          stat.set('team', player.get('team'))
          stat.set('player', subbedOut)
          stat.set('game', @get('model'))
          stat.save().then =>
            subbedOut.save()
            @saveGame()

    switchSides: ->
      left = @get('left')
      right = @get('right')
      @set('left', right)
      @set('right', left)
      @getStats()

  newGameMessage: ->
    conf = {
      message: "Drag and drop players into the starting lineup. Once you have them set, you will be ready to start the game."
      header: "Set your lineups"
    }
    @send('openModal', 'modals/confirmation', conf)

`export default GameController`
