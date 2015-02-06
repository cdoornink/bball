`import Ember from 'ember'`

RadioButtonComponent = Ember.Component.extend
  classNames: ["switch-input"]
  tagName: "input"
  type: "radio"
  attributeBindings: [ "name", "type", "value", "checked:checked:" ]
  click: ->
    @set("selection", this.$().val())
  checked: (->
    @get("value") is this.get("selection")
  ).property()

`export default RadioButtonComponent`
