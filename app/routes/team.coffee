`import Route from './filter'`

TeamRoute = Route.extend
  model: (params) -> @store.find('team', params.id)

`export default TeamRoute`
