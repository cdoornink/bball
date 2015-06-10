`import DS from 'ember-data'`

User = DS.Model.extend
  provider: DS.attr()
  name: DS.attr()
  email: DS.attr()
  created: DS.attr()
  teams: DS.hasMany('team', async: true, inverse: 'owners')
  gamePreferences: DS.hasMany('gamePreference', async: true)

`export default User`
