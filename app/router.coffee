`import Ember from 'ember';`
`import config from './config/environment';`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->
  @route 'login'
  @route 'team', {path: "team/:id"}, ->
    @route 'new-game'
    @route 'opponent', {path: "opponent/:id"}
  @route 'player'

  @route 'game', {path: "game/:id"}

`export default Router;`
