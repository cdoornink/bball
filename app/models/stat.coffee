`import DS from 'ember-data'`

Stat = DS.Model.extend
  game: DS.belongsTo('game', async: true)
  team: DS.belongsTo('team', async: true)
  opponent: DS.belongsTo('team', async: true)
  player: DS.belongsTo('player', async: true)
  type: DS.attr('string')
  period: DS.attr('number')
  clutch: DS.attr('string')
  subType: DS.attr('string')
  fouler: DS.belongsTo('player', async: true)
  x: DS.attr('number')
  y: DS.attr('number')
  result: DS.attr('string')
  timeLeft: DS.attr('number')
  value: DS.attr('number')
  scoreDiff: DS.attr('number')

`export default Stat`
