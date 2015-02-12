`import DS from 'ember-data'`

Team = DS.Model.extend
  organization: DS.attr('string')
  mascot: DS.attr('string')
  season: DS.attr('string')
  type: DS.attr('string')
  logo: DS.attr('string')
  primaryColor: DS.attr('string')
  secondaryColor: DS.attr('string')
  active: DS.attr('boolean')
  location: DS.attr('string')
  players: DS.hasMany('player', async: true)
  owners: DS.hasMany('user', {async: true, inverse: 'teams'})
  opponents: DS.hasMany('team', {async: true})
  games: DS.hasMany('game', {async: true, inverse: 'teams'})
  homeGames: DS.hasMany('game', {async: true, inverse: 'homeTeam'})
  awayGames: DS.hasMany('game', {async: true, inverse: 'awayTeam'})
  stats: DS.hasMany('stat', {async: true, inverse: 'team'})
  gamesNum: (->
    @get('games.content.content').length
  ).property('games.@each')
  playersNum: (->
    @get('players.content.content').length
  ).property('players.@each')
  myTeam: (->
    owners = @get('owners.content')
    user = jQuery.parseJSON(localStorage.getItem("firebase:session::blistering-fire-5623"))
    myTeam = false
    @get('owners').forEach (owner) ->
      if owner.id is user.uid
        console.log "this is my team"
        myTeam = true
    myTeam
  ).property('owners.@each')
  owned: (->
    owners = @get('owners.content')
    if owners.toArray().length
      owned = true
    owned
  ).property('myTeam')
  editable: (->
    if @get('myTeam') or !@get('owned')
      editable = true
    editable
  ).property('owned', 'myTeam')

`export default Team`
