`import { test, moduleFor } from 'ember-qunit'`

moduleFor 'route:game/box-score', 'GameBoxScoreRoute', {
  # Specify the other units that are required for this test.
  # needs: ['controller:foo']
}

test 'it exists', ->
  route = @subject()
  ok route
