`import DS from 'ember-data'`

Game = DS.Model.extend
  date: DS.attr('string')
  location: DS.attr('string')
  teams: DS.hasMany('team', async: true)
  homeTeam: DS.belongsTo('team', async: true)
  homeScore: DS.attr('number')
  awayTeam: DS.belongsTo('team', async: true)
  awayScore: DS.attr('number')
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
    @get('teams').toArray()[0]
  ).property('teams')
  right: (->
    @get('teams').toArray()[1]
  ).property('teams')
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
    if s isnt "completed"
      w = undefined
    else
      w = h > a
    return w
  ).property('homeScore', 'status')

`export default Game`
