`import Ember from 'ember'`

PointAdjusterComponent = Ember.Component.extend
  classNames: ['point-adjuster']
  actions:
    clickPlus: ->
      @sendAction('adjustScore', @get('team'), 1)
      @.$().find('.difference').css('visibility', 'visible')
      Ember.run.later (=>
        @.$().find('.difference').css('visibility', 'hidden')
      ), 1000
    clickMinus: ->
      @sendAction('adjustScore', @get('team'), -1)
      @.$().find('.difference').css('visibility', 'visible')
      Ember.run.later (=>
        @.$().find('.difference').css('visibility', 'hidden')
      ), 1000

`export default PointAdjusterComponent`
