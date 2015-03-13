`import Ember from 'ember'`
`import StatsMixin from '../mixins/stats'`

GameController = Ember.ObjectController.extend(StatsMixin,
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
        @set('quarters', false)
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
        @advancedTeamStats(@get('left'), @get('right'))
        console.timeEnd("compile stats w/ advanced")


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




  getOpponent: (team) ->
    if @get('left.id') is team.get('id') then @get('right') else @get('left')

  savePlayerandTeam: (player) ->
    @store.find('player', player.get('id')).then (player) =>
      player.save()


  saveGame: ->
    console.count('save game')
    @get('model').save().then =>
      @getStats()
    @store.find('team', @get('left.id')).then (team) =>
      team.save()
    @store.find('team', @get('right.id')).then (team) ->
      team.save()

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

    selectPlayer: (ops) ->
      @set('selectedPlayer', ops.player)
      if ops.player.get('team.id') is @get('left.id')
        @set('leftPlayerSelected', true)
        @set('rightPlayerSelected', false)
      else
        @set('leftPlayerSelected', false)
        @set('rightPlayerSelected', true)
      $('.on-court .player-card').removeClass('selected')
      if ops.el
        ops.el.addClass('selected')
      else
        name = ops.player.get('lastName')
        number = ops.player.get('number')
        $(".on-court .player-card:contains(#{name}):contains(#{number})").addClass('selected')

#for play by play, will have to check after a made shot if an assist was recorded next
# on a blocked shot if a block was recorded next
# on a fouled shot if a foul was recorded next etc.
# if a block is there without a corresponding blocked shot, print it out just as a block in the play by play
    shot: (ops) ->
      @send('openModal', 'modals/shot', ops)
    submitShot: (model) ->
      console.log model.result
      shot = this.store.createRecord 'stat',
        type: "shot"
        period: @get('period')
        timeLeft: @get('timeLeft')
        subType: model.subType or 'jumper'
        x: model.x
        y: model.y
        result: model.result
        value: model.value
      shot.set('team', @get('selectedPlayer.team'))
      shot.set('opponent', @getOpponent(@get('selectedPlayer.team')))
      shot.set('player', @get('selectedPlayer'))
      shot.set('game', @get('model'))
      shot.save().then =>
        @savePlayerandTeam(@get('selectedPlayer'))
        @saveGame()
      Ember.run.later (=>
        if (model.result is 'block')
          @send('openModal', 'modals/blocked')
        if (model.result is 'make')
          @send('openModal', 'modals/assisted')
        if (model.result is 'foul')
          @send('openModal', 'modals/fouled', {shooting: model.value})
        if model.result is 'and1'
          @send('openModal', 'modals/assisted', {shooting: 1})
        if model.result is 'miss'
          @send('openModal', 'modals/rebounded', {defensive: @getOpponent(@get('selectedPlayer.team'))})
      ), 100

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
      shot.set('opponent', @getOpponent(@get('selectedPlayer.team')))
      shot.set('player', @get('selectedPlayer'))
      if model.shooting is 1 and model.result1 is "miss"
        rebound = true
      shot.set('game', @get('model'))
      shot.save().then =>
        if model.shooting is 1
          @savePlayerandTeam(@get('selectedPlayer'))
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
        shot2.set('opponent', @getOpponent(@get('selectedPlayer.team')))
        shot2.set('player', @get('selectedPlayer'))
        if model.shooting is 2 and model.result2 is "miss"
          rebound = true
        shot2.set('game', @get('model'))
        shot2.save().then =>
          if model.shooting is 2
            @savePlayerandTeam(@get('selectedPlayer'))
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
        shot3.set('opponent', @getOpponent(@get('selectedPlayer.team')))
        shot3.set('player', @get('selectedPlayer'))
        if model.shooting is 3 and model.result3 is "miss"
          rebound = true
        shot3.set('game', @get('model'))
        shot3.save().then =>
          if model.shooting is 3
            @savePlayerandTeam(@get('selectedPlayer'))
            @saveGame()
      if rebound
        Ember.run.later (=>
          @send('openModal', 'modals/rebounded', {defensive: @getOpponent(@get('selectedPlayer.team'))})
        ), 100


    submitAssist: (model) ->
      assist = this.store.createRecord 'stat',
        type: "assist"
        period: @get('period')
        timeLeft: @get('timeLeft')
      assist.set('team', model.assister.get('team'))
      assist.set('opponent', @getOpponent(model.assister.get('team')))
      assist.set('player', model.assister)
      assist.set('recipient', model.recipient)
      assist.set('game', @get('model'))
      assist.save().then =>
        @savePlayerandTeam(model.assister)
        @saveGame()
        if model.shooting
          @send('openModal', 'modals/fouled', {shooting: model.shooting})


    foulButton: ->
      @send('openModal', 'modals/foul', {fouler: @get('selectedPlayer')})
    submitFoul: (model) ->
      foul = this.store.createRecord 'stat',
        type: "foul"
        period: @get('period')
        timeLeft: @get('timeLeft')
        subType: model.subType or "defensive"
      foul.set('team', model.fouler.get('team'))
      foul.set('opponent', @getOpponent(model.fouler.get('team')))
      foul.set('player', model.fouler)
      foul.set('game', @get('model'))
      foul.save().then =>
        @savePlayerandTeam(model.fouler)
        if model.subType is "offensive"
          @send('submitTurnover', {turnoverer: model.fouler})
        else
          @saveGame()
      if model.shooting
        Ember.run.later (=>
          @send('openModal', 'modals/freethrow', {shooting: model.shooting})
        ), 100


    reboundButton: ->
      @send('openModal', 'modals/rebound', {rebounder: @get('selectedPlayer'), subType: 'defensive'})
    submitRebound: (model) ->
      if model.subType
        subType = model.subType
      else
        if model.defensive and model.defensive.get('id') isnt model.rebounder.get('team.id')
          subType = 'offensive'
        else
          subType = 'defensive'
      rebound = this.store.createRecord 'stat',
        type: "rebound"
        period: @get('period')
        timeLeft: @get('timeLeft')
        subType: subType
      rebound.set('team', model.rebounder.get('team'))
      rebound.set('opponent', @getOpponent(model.rebounder.get('team')))
      rebound.set('player', model.rebounder)
      rebound.set('game', @get('model'))
      rebound.save().then =>
        @send('selectPlayer', {player:model.rebounder})
        @savePlayerandTeam(model.rebounder)
        @saveGame()

    blockButton: ->
      @send('submitBlock', {blocker: @get('selectedPlayer')})
    submitBlock: (model) ->
      block = this.store.createRecord 'stat',
        type: "block"
        period: @get('period')
        timeLeft: @get('timeLeft')
      block.set('team', model.blocker.get('team'))
      block.set('opponent', @getOpponent(model.blocker.get('team')))
      block.set('player', model.blocker)
      block.set('game', @get('model'))
      block.save().then =>
        @savePlayerandTeam(model.blocker)
        @saveGame()
      Ember.run.later (=>
        @send('openModal', 'modals/rebounded', {defensive: model.blocker.get('team')})
      ), 100

    drawChargeButton: ->
      @send('openModal', 'modals/charge', {})
    submitDrawnCharge: ->
      c = this.store.createRecord 'stat',
        type: "drawnCharge"
        period: @get('period')
        timeLeft: @get('timeLeft')
      c.set('team', @get('selectedPlayer.team'))
      c.set('opponent', @getOpponent(@get('selectedPlayer.team')))
      c.set('player', @get('selectedPlayer'))
      c.set('game', @get('model'))
      c.save().then =>
        @savePlayerandTeam(@get('selectedPlayer'))
        @saveGame()

    turnoverButton: ->
      @send('openModal', 'modals/turnover', {turnoverer: @get('selectedPlayer')})
    submitTurnover: (model) ->
      turnover = this.store.createRecord 'stat',
        type: "turnover"
        period: @get('period')
        timeLeft: @get('timeLeft')
      turnover.set('team', model.turnoverer.get('team'))
      turnover.set('opponent', @getOpponent(model.turnoverer.get('team')))
      turnover.set('player', model.turnoverer)
      turnover.set('game', @get('model'))
      turnover.save().then =>
        @savePlayerandTeam(model.turnoverer)
        if model.stealer
          @send('submitSteal', {stealer: model.stealer})
        else
          @saveGame()

    stealButton: ->
      @send('openModal', 'modals/steal', {stealer: @get('selectedPlayer')})
    submitSteal: (model) ->
      steal = this.store.createRecord 'stat',
        type: "steal"
        period: @get('period')
        timeLeft: @get('timeLeft')
      steal.set('team', model.stealer.get('team'))
      steal.set('opponent', @getOpponent(model.stealer.get('team')))
      steal.set('player', model.stealer)
      steal.set('game', @get('model'))
      steal.save().then =>
        @send('selectPlayer', {player:model.stealer})
        @savePlayerandTeam(model.stealer)
        if model.turnoverer
          @send('submitTurnover', {turnoverer: model.turnoverer})
        else
          @saveGame()


    endPeriod: ->
      period = @get('period')
      @get('preference').then (p) =>
        if period is p.get('periods')
          r = @get('right.teamStats.points')
          l = @get('left.teamStats.points')
          if r is l
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
      console.log @get('status')
      if @get('status') is "created"
        @send('submitSubstitute', player, ops)
      else
        @send('openModal', 'modals/time', {continue: => @send('submitSubstitute', player, ops)})

    submitSubstitute: (player, ops) ->
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
)

`export default GameController`
