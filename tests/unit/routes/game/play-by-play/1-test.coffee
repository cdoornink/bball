`import { test, moduleFor } from 'ember-qunit'`

moduleFor 'route:game/play-by-play/1', 'GamePlayByPlay1Route', {
  # Specify the other units that are required for this test.
  # needs: ['controller:foo']
}

test 'it exists', ->
  route = @subject()
  ok route
