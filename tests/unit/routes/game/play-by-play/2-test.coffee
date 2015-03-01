`import { test, moduleFor } from 'ember-qunit'`

moduleFor 'route:game/play-by-play/2', 'GamePlayByPlay2Route', {
  # Specify the other units that are required for this test.
  # needs: ['controller:foo']
}

test 'it exists', ->
  route = @subject()
  ok route
