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
  court: {}
  statLine: {points: 0,ftm: 0,fta: 0,fgm: 0,fga: 0,threepta: 0,threeptm: 0,assists: 0,fouls: 0,steals: 0,minutes: 0,reb: 0,oreb: 0,dreb: 0,blocks: 0,turnovers: 0,plusminus: 0,scoreByPeriod:{}}
  getStats: ->
    console.time("compile stats")
    @get('preference').then (p) =>
      if p.get('periods') is 4
        @set('quarters', true)
    @get('stats').then (stats) =>
      #lineups
      loc = []
      roc = []
      #all shots
      rshots = []
      lshots = []
      #stats by player
      sbp = {}

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
        @newGameMessage()

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
    console.timeEnd("recompileStats")

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
          else if stat.get('subType') isnt 'fouled'
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
    player.set('gameStats', ps)

  saveGame: ->
    console.count('save game')
    @get('model').save()
    @getStats()
  actions:

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
      turnover.set('game', @get('model'))
      turnover.save().then =>
        @store.find('player', @get('selectedPlayer.id')).then (player) =>
          player.save()
        @saveGame()
      if model.stealer
        steal = this.store.createRecord 'stat',
          type: "turnover"
          period: @get('period')
          timeLeft: @get('timeLeft')
        steal.set('team', model.stealer.get('team'))
        steal.set('player', model.stealer)
        steal.set('game', @get('model'))
        steal.save().then =>
          @store.find('player', model.stealer.get('id')).then (player) =>
            player.save()
          @saveGame()

    stealButton: ->
      @send('openModal', 'modals/steal', {})
    submitSteal: (model) ->
      steal = this.store.createRecord 'stat',
        type: "turnover"
        period: @get('period')
        timeLeft: @get('timeLeft')
      steal.set('team', @get('selectedPlayer.team'))
      steal.set('player', @get('selectedPlayer'))
      steal.set('game', @get('model'))
      steal.save().then =>
        @store.find('player', @get('selectedPlayer.id')).then (player) =>
          player.save()
        @saveGame()
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

    endPeriod: ->
      period = @get('period')
      @get('preference').then (p) =>
        if period is p.get('periods')
          debugger
          console.log "overtime or end game (check score)"
          @set('period', "OT")
          @set('timeLeft', 300)
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
