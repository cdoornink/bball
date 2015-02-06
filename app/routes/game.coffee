`import Route from './filter'`

GameRoute = Route.extend
  model: (params) -> @store.find('game', params.id)

`export default GameRoute`
