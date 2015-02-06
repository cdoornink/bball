`import DS from 'ember-data'`

GamePreference = DS.Model.extend {
  default: DS.attr('boolean')
  name: DS.attr('string')
  periodLength: DS.attr('number')
  periods: DS.attr('number')
  personalFouls: DS.attr('number')
  user: DS.belongsTo('user', async: true)
  game: DS.hasMany('game', async: true)
}

`export default GamePreference`
