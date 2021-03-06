`import DS from 'ember-data'`

Player = DS.Model.extend
  firstName: DS.attr('string')
  lastName: DS.attr('string')
  number: DS.attr('string')
  position: DS.attr('string')
  year: DS.attr('string')
  height: DS.attr('string')
  team: DS.belongsTo('team', async: true)
  games: DS.hasMany('game', async: true)
  stats: DS.hasMany('stat', {async: true, inverse: 'player'})
  fullName: (->
    return "#{@get('firstName')} #{@get('lastName')}"
  ).property('firstName', 'lastName')
  firstInitial: (->
    if @get('firstName')
      @get('firstName')[0]
    else
      ""
  ).property('firstName')

`export default Player`
