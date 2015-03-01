`import DS from 'ember-data'`

Stat = DS.Model.extend
  game: DS.belongsTo('game', async: true)
  team: DS.belongsTo('team', async: true)
  player: DS.belongsTo('player', async: true)
  type: DS.attr('string')
  period: DS.attr('number')
  clutch: DS.attr('string')
  subType: DS.attr('string')
  recipient: DS.belongsTo('player', async: true)
  fouler: DS.belongsTo('player', async: true)
  x: DS.attr('number')
  y: DS.attr('number')
  result: DS.attr('string')
  timeLeft: DS.attr('number')
  value: DS.attr('number')

`export default Stat`
  # stats: [
#     {
#       team: blah
#       player: blah
#       type: assist
#       recipient: blah
#       period: int
#       clutch: boolean
#     }
#     {
#       team: blah
#       player: blah
#       type: shot
#       subType: freethrow / layup / dunk / 2pt shot / 3pt shot (only prompt if close shot)
#       position: blah
#       result: make / miss / block / foul / and1
#       value: 0 / 1 / 2 / 3
#       recipient: blah (assister/blocker/fouler)
#       period: int
#       clutch: boolean
#     }
#     {
#       team: blah
#       player: blah
#       type: foul
#       subType: shooting / defensive / offensive / technical / flagrant
#       period: int
#       clutch: boolean
#     }
#     {
#       team: blah
#       player: blah
#       type: rebound
#       subType: defensive / offensive
#       period: int
#       clutch: boolean
#     }
#     {
#       team: blah
#       player: blah
#       type: block
#       subType: layup / dunk / 2pt shot / 3pt shot
#       position: blah
#       recipient: blah
#       period: int
#       clutch: boolean
#     }
#     {
#       team: blah
#       player: blah
#       type: chargeTaken
#       recipient: blah
#       period: int
#       clutch: boolean
#     }
#     {
#       team: blah
#       player: blah
#       type: turnover
#       period: int
#       clutch: boolean
#     }
#     {
#       team: blah
#       player: blah
#       type: steal
#       period: int
#       clutch: boolean
#     }
#     {
#       team: blah
#       player: blah
#       type: subbedIn
#       period: int
#       timeLeft: blah
#     }
#     {
#       team: blah
#       player: blah
#       type: subbedOut
#       period: int
#       timeLeft: blah
#     }
#   ]
