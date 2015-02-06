`import DS from 'ember-data'`

User = DS.Model.extend
  provider: DS.attr('string')
  name: DS.attr('string')
  email: DS.attr('string')
  created: DS.attr('string')
  teams: DS.hasMany('team', async: true, inverse: 'owners')
  gamePreferences: DS.hasMany('gamePreference', async: true)

`export default User`
