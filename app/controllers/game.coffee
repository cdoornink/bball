`import Ember from 'ember'`
`import StatsMixin from '../mixins/stats'`

GameController = Ember.Controller.extend(StatsMixin,
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
    return if @get('model.right.primaryColor') is undefined
    @addTeamColorStyle()
    @get('model.right').save()
  ).observes('model.right.primaryColor', 'model.right.secondaryColor')
  leftColorChanged: (->
    return if @get('model.left.primaryColor') is undefined
    @addTeamColorStyle()
    @get('model.left').save()
  ).observes('model.left.primaryColor', 'model.left.secondaryColor')
  addTeamColorStyle: ->
    if $('html > head > style').length
      $('html > head > style').last().remove();
    $('html > head')
      .append("<style>
                .right-primary, .right-team .player-card {
                  background: #{@get('model.right.primaryColor')};
                }
                .right-secondary, .right-team .player-card {
                  color: #{@get('model.right.secondaryColor')};
                }
                .left-primary, .left-team .player-card {
                  background: #{@get('model.left.primaryColor')};
                }
                .left-secondary, .left-team .player-card {
                  color: #{@get('model.left.secondaryColor')};
                }
              </style>");
  statsUpdated: (->
    Ember.run.debounce(@, @getStats, 300)
  ).observes("model.stats")
  getStats: ->
      @get('model.preference').then (p) =>
        if p.get('periods') is 4
          @set('quarters', true)
          @set('periods', 4)
        else
          @set('quarters', false)
          @set('periods', 2)
        @set('periodLength', (p.get('periodLength') * 60))
        @set('totalLength', (p.get('periods') * (p.get('periodLength') * 60)))
      @get('model.stats').then (stats) =>
        # console.log stats
        console.time("compile stats")
        console.time("compile stats w/ advanced")

        if stats.length is 0 or stats.length is undefined
          @newGameMessage()

        #lineups and all shots
        loc = []
        roc = []
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
            if stat.get('team.id') is @get('model.left.id')
              loc.push(stat)
            #this was failing after half a game with the clippers, team.id was undefined, just for the one team, even if I switched sides
            else if stat.get('team.id') is @get('model.right.id')
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
        @get('model.left.players').forEach (player) ->
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
        @get('model.right.players').forEach (player) ->
          if _.indexOf(rocArray, player.id) is -1
            rb.push player
        @set('rightBench', rb)

        #scoreboard
        unless @get('model.timeLeft')
          @set('model.timeLeft', @get('model.preference.periodLength') * 60)

        #player stats
        @get('court.el').empty()
        ts = _.clone(@statLine)
        ts.scoreByPeriod = {}
        @get('model.left.players').forEach (player) =>
          @statByPlayer(sbp, player, ts, "left", )
        @set('model.left.teamStats', ts)

        ts = _.clone(@statLine)
        ts.scoreByPeriod = {}
        @get('model.right.players').forEach (player) =>
          @statByPlayer(sbp, player, ts, "right")
        @set('model.right.teamStats', ts)
        console.timeEnd("compile stats")
        if @get('model.status', "Final")
          @advancedTeamStats(@get('model.left'), @get('model.right'))
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
    left = p.get('team.id') is @get('model.left.id')
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
      if sT is "freeThrow"
        sT = "free throw"
      play["shotType"] = sT or "jumper"
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
    else if t is "teamRebound"
      offensive = p.get('subType') is "offensive"
      play = {left: left, teamRebound: true, team: p.get('team'), offensive: offensive}
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

  getScoreDiff: (team) ->
    team.get('teamStats.points') - @getOpponent(team).get('teamStats.points')

  getOpponent: (team) ->
    if @get('model.left.id') is team.get('id') then @get('model.right') else @get('model.left')

  savePlayer: (player) ->
    @store.find('player', player.get('id')).then (player) =>
      player.save()

  saveGame: ->
    console.count('save game')
    @submitGameScore()
    @get('model').save()
    @store.find('team', @get('model.left.id')).then (team) =>
      team.save()
    @store.find('team', @get('model.right.id')).then (team) ->
      team.save()

  newGameMessage: ->
    conf = {
      message: "Drag and drop players into the starting lineup. Once you have them set, you will be ready to start the game."
      header: "Set your lineups"
    }
    @send('openModal', 'modals/confirmation', conf)

  endGame: ->
    conf = {
      message: "Do you want to end this game now? Stats can still be edited in the box score after the game has ended."
      header: "Game Over?"
      continue: =>
        @send('submitEndGame')
    }
    @send('openModal', 'modals/confirmation', conf)

  submitGameScore: ->
    if @get('model.homeTeam.id') is @get('model.left.id')
      home = @get('model.left')
      away = @get('model.right')
    else
      home = @get('model.right')
      away = @get('model.left')
    @set('model.homeScore', home.teamStats.points)
    @set('model.awayScore', away.teamStats.points)

  createStat: (type, model, callback) ->
    stat = this.store.createRecord 'stat',
      type: type
      period: @get('model.period')
      timeLeft: @get('model.timeLeft')
      scoreDiff: @getScoreDiff(model.player.get('team'))
    stat.set('team', model.player.get('team'))
    stat.set('opponent', @getOpponent(model.player.get('team')))
    stat.set('player', model.player)
    stat.set('game', @get('model'))
    if model.subType
      stat.set('subType', model.subType)
    if type is "shot"
      stat.set('value', model.value)
      stat.set('result', model.result)
    if model.x
      stat.set('x', model.x)
      stat.set('y', model.y)
    stat.save().then =>
      if model.player
        @savePlayer(model.player)
      if callback
        callback()
      else
        @saveGame()

  actions:

    submitEndGame: ->
      @submitGameScore()
      @set('model.status', "Final")
      @set('model.timeLeft', 0)
      @set('model.period', "Final")
      @saveGame()

    jumpBall: (team) ->
      @set('model.possession', team)
      @set('model.status', "active")
      @saveGame()

    selectPlayer: (ops) ->
      @set('selectedPlayer', ops.player)
      if ops.player.get('team.id') is @get('model.left.id')
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
      model.player = @get('selectedPlayer')
      @createStat 'shot', model
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
          @send('openModal', 'modals/rebounded', {defensive: @getOpponent(model.player.get('team'))})
      ), 100

    freeThrowButton: ->
      @send('openModal', 'modals/freethrow', {shooting: 2})
    submitFreeThrows: (model) ->
      if (model.shooting is 1 and model.result1 is "miss") or
        (model.shooting is 2 and model.result2 is "miss") or
        (model.shooting is 3 and model.result3 is "miss")
          rebound = true
      model.subType = "freeThrow"
      model.player = @get('selectedPlayer')
      model.result = model.result1
      model.value = 1
      @createStat 'shot', model, =>
        if model.shooting is 1
          @savePlayer(@get('selectedPlayer'))
          @saveGame()
      if model.shooting > 1
        model.result = model.result2
        @createStat 'shot', model, =>
          if model.shooting is 2
            @savePlayer(@get('selectedPlayer'))
            @saveGame()
      if model.shooting > 2
        model.result = model.result3
        @createStat 'shot', model
      if rebound
        Ember.run.later (=>
          @send('openModal', 'modals/rebounded', {defensive: @getOpponent(@get('selectedPlayer.team'))})
        ), 100

    submitAssist: (model) ->
      model.type = "assist"
      @createStat 'assist', model, =>
        @saveGame()
        if model.shooting
          @send('openModal', 'modals/fouled', {shooting: model.shooting})

    foulButton: ->
      @send('openModal', 'modals/foul', {player: @get('selectedPlayer')})
    submitFoul: (model) ->
      console.log model
      model.subType = model.subType or "defensive"
      @createStat 'foul', model, =>
        if model.subType is "offensive"
          @send('submitTurnover', {turnoverer: model.fouler})
        else
          @saveGame()
      if model.shooting
        Ember.run.later (=>
          @send('openModal', 'modals/freethrow', {shooting: model.shooting})
        ), 100

    reboundButton: ->
      @send('openModal', 'modals/rebound', {player: @get('selectedPlayer'), subType: 'defensive'})
    submitRebound: (model) ->
      if !model.subType
        if model.defensive and model.defensive.get('id') isnt model.player.get('team.id')
          model.subType = 'offensive'
        else
          model.subType = 'defensive'
      @createStat 'rebound', model, =>
        @send('selectPlayer', {player:model.player})
        @saveGame()
    submitTeamRebound: (model) ->
      rebound = this.store.createRecord 'stat',
        type: "teamRebound"
        period: @get('model.period')
        timeLeft: @get('model.timeLeft')
        scoreDiff: @getScoreDiff(model.team)
        subType: model.subType
      rebound.set('team', model.team)
      rebound.set('opponent', @getOpponent(model.team))
      rebound.set('game', @get('model'))
      rebound.save().then =>
        @saveGame()

    blockButton: ->
      @send('openModal', 'modals/block', {player: @get('selectedPlayer'), pushedButton: true})
    submitBlock: (model) ->
      console.log model
      @createStat 'block', model, =>
        if model.rebounder
          @send('submitRebound', {player: model.rebounder, defensive: model.player.get('team')})
        else
          unless model.pushedButton
            Ember.run.later (=>
              @send('openModal', 'modals/rebounded', {defensive: model.player.get('team')})
            ), 100
          @saveGame()

    drawChargeButton: ->
      @send('openModal', 'modals/charge', {})
    submitDrawnCharge: ->
      @createStat 'drawnCharge', {player: @get('selectedPlayer')}

    turnoverButton: ->
      @send('openModal', 'modals/turnover', {player: @get('selectedPlayer')})
    submitTurnover: (model) ->
      @createStat 'turnover', model, =>
        if model.stealer
          @send('submitSteal', {player: model.stealer})
        else
          @saveGame()

    stealButton: ->
      @send('openModal', 'modals/steal', {player: @get('selectedPlayer')})
    submitSteal: (model) ->
      @createStat 'steal', model, =>
        @send('selectPlayer', {player:model.player})
        if model.turnoverer
          @send('submitTurnover', {player: model.turnoverer})
        else
          @saveGame()

    substitute: (player, ops) ->
      @get('stats').then (stats) =>
        lastStat = stats.currentState[stats.length-1]
        if @get('status') is "created" or lastStat.get('type') is "subbedOut" or lastStat.get('type') is "played"
          @send('submitSubstitute', player, ops)
        else
          @send('openModal', 'modals/time', {continue: => @send('submitSubstitute', player, ops)})
    submitSubstitute: (player, ops) ->
      if ops.target.current
        subbedOut = ops.target.current.content
      @createStat 'subbedIn', {player: player, subType: ops.target.slot}, =>
        unless player.get('gameStats.played')
          Ember.run.later (=>
            @send('submitPlayed', player)
          ), 200
        if subbedOut
          @send('submitSubbedOut', subbedOut)
        else
          @saveGame()
    submitSubbedOut: (player) ->
      @createStat 'subbedOut', {player: player}
    submitPlayed: (player) ->
      console.log "submit played"
      stat = this.store.createRecord 'stat',
        type: "played"
      stat.set('team', player.get('team'))
      stat.set('player', player)
      stat.set('game', @get('model'))
      stat.save().then =>
        player.save()
        #this breaks as soon as you reload the page. need to save this as an actual stat when compiling
        @saveGame()

    endPeriod: ->
      period = @get('model.period')
      @get('model.preference').then (p) =>
        if period is p.get('periods')
          r = @get('model.right.teamStats.points')
          l = @get('model.left.teamStats.points')
          if r is l
            @set('model.period', "OT")
            @set('model.timeLeft', 300)
          else
            @endGame()
        else
          @set('model.period', (period + 1))
          @set('model.timeLeft', p.get('periodLength')*60)
        @saveGame()

    changeTime: ->
      @send('openModal', 'modals/time', {})
    submitTimeLeft: (s) ->
      @set('model.timeLeft', s)
      @saveGame()

    switchSides: ->
      left = @get('model.left')
      right = @get('model.right')
      @set('model.left', right)
      @set('model.right', left)
      @getStats()
)

`export default GameController`
