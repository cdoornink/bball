`import Ember from 'ember'`

ModalsEditorController = Ember.Controller.extend
  needs: ["game"]
  modelChanged: Ember.observer 'model.id', ->
    if @get('model.subType') is 'freeThrow' then @set('freeThrow', true) else @set('freeThrow', false)
    if @get('model.type') is 'shot' then @set('shot', true) else @set('shot', false)
    if @get('model.type') is 'rebound' then @set('rebound', true) else @set('rebound', false)
    if @get('model.type') is 'foul' then @set('foul', true) else @set('foul', false)

    if @get('shot')
      Ember.run.later (=>
        tstring = if @get('model.value') is 2 then 'two' else 'three'
        $(".type-button.#{@get('model.result')}").addClass('selected')
        $(".value-button.#{tstring}").addClass('selected')
      ), 100

    if @get('rebound') or @get('foul')
      Ember.run.later (=>
        $(".type-button.#{@get('model.subType')}").addClass('selected')
      ), 100


  actions:
    cancel: ->
      @send('closeModal')
    setType: (t) ->
      @set('model.subType', t)
      $(".type-button").removeClass('selected')
      $(".type-button.#{t}").addClass('selected')
    setResult: (t) ->
      @set('model.result', t)
      $(".type-button").removeClass('selected')
      $(".type-button.#{t}").addClass('selected')
    setValue: (t) ->
      @set('model.value', t)
      tstring = if t is 2 then 'two' else 'three'
      $(".value-button").removeClass('selected')
      $(".value-button.#{tstring}").addClass('selected')
    continue: ->
      @get('controllers.game').send('submitEditStat', @get('model'))
    deleteStat: ->
      @get('controllers.game').send('submitDeleteStat', @get('model'))

`export default ModalsEditorController`
