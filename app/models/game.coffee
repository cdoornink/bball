`import DS from 'ember-data'`

Game = DS.Model.extend
  date: DS.attr('string')
  location: DS.attr('string')
  teams: DS.hasMany('team', async: true)
  homeTeam: DS.belongsTo('team', async: true)
  homeScore: DS.attr('number')
  homePointsAdjustment: DS.attr('number')
  awayTeam: DS.belongsTo('team', async: true)
  awayScore: DS.attr('number')
  awayPointsAdjustment: DS.attr('number')
  status: DS.attr('string')
  period: DS.attr('number')
  timeLeft: DS.attr('number')
  possession: DS.belongsTo('team', async: true)
  leftPossession: (->
    @get('possession.id') is @get('left.id')
  ).property('possession', 'left')
  preference: DS.belongsTo('gamePreference', async: true)
  quarters: (->
    @get('preference.periods') is 4
  ).property('preference')
  stats: DS.hasMany('stat', async: true)
  left: (->
    homeTeam = @get('homeTeam')
    for team in @get('teams').toArray()
      if team.id is homeTeam.get('id')
        left = team
    left
  ).property('teams', 'homeTeam')
  right: (->
   awayTeam = @get('awayTeam')
   for team in @get('teams').toArray()
     if team.id is awayTeam.get('id')
       right = team
   right
  ).property('teams', 'awayTeam')
  notStarted: (->
    @get('status') is "created"
  ).property('status')
  inProgress: (->
    @get('status') is "active"
  ).property('status')
  final: (->
    @get('status') is "Final"
  ).property('status')
  homeWin: (->
    s = @get('status')
    h = @get('homeScore')
    a = @get('awayScore')
    if s isnt "Final"
      w = undefined
    else
      w = if h > a then true else false
    return w
  ).property('homeScore', 'awayScore', 'status')

`export default Game`
