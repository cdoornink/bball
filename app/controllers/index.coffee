`import Ember from 'ember'`

IndexController = Ember.Controller.extend
  selectedPreferences: null
  selectedPeriod: 4
  selectedPeriodLength: 8
  selectedFouls: 5
  periodOptions: [2,4]
  periodLengthOptions: [4,5,6,7,8,9,10,11,12,15,20,24]
  foulOptions: [4,5,6,7,8,9,10]
  init: ->
    this.set('team', Ember.Object.create({primaryColor:"#000000", secondaryColor: "#FFFFFF"}))
    this.set('pref', Ember.Object.create())
  actions:
    createTeam: ->
      user = @session.get('user')
      prefs = this.get('selectedPreferences')
      if !prefs
        alert "no prefs set!"
        return
      newTeam = @store.createRecord 'team',
        organization: @get('team.organization')
        mascot: @get('team.mascot')
        season: @get('team.season')
        primaryColor: @get('team.primaryColor')
        secondaryColor: @get('team.secondaryColor')
        active: true
      newTeam.set('preference', prefs)
      newTeam.get('owners').then (owners) =>
        owners.addObject(user)
        newTeam.save().then ->
          user.save()

    selectPreferences: (pref) ->
      @set('selectedPreferences', pref)
      $(".preference-grid-item").removeClass('selected')
      $(".preference-grid-item.#{pref.id}").addClass('selected')

    createPreference: ->
      user = @session.get('user')
      newPref = this.store.createRecord 'gamePreference',
        name: this.get('pref.name')
        periodLength: this.get('selectedPeriodLength')
        periods: this.get('selectedPeriod')
        personalFouls: this.get('selectedFouls')
      newPref.set('user', user)
      newPref.save().then ->
        user.save()
      @set('selectedPreferences', newPref)

`export default IndexController`
