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

  @route 'game', {path: "game/:id"}, ->
    @route 'index', {path: '/box-score'}
    @route 'play-by-play', {path: "/play-by-play"}, ->
      @route 'index', {path: '/1'}
      @route '2'
      @route '3'
      @route '4'
      @route 'ot'

`export default Router;`
