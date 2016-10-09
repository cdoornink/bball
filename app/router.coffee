`import Ember from 'ember';`
`import config from './config/environment';`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->
  @route 'login'
  @route 'register'
  @route 'team', {path: "team/:id"}, ->
    @route 'new-game'
    @route 'stats', ->
      @route 'index'
      @route 'graphs'
      @route 'charts'
    @route 'games'
  @route 'player'

  @route 'game', {path: "game/:id"}, ->
    @route 'index', {path: '/'}
    @route 'box-score', {path: '/box-score'}
    @route 'play-by-play', {path: "/play-by-play"}, ->
      @route 'index', {path: '/1'}
      @route '2'
      @route '3'
      @route '4'
      @route 'ot'

`export default Router;`
