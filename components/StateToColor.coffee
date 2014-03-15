noflo = require 'noflo'

# { guid: 'a6301120831b46f1be00fa2cb0bce195.16',
#   health: 100,
#   team: 'RESISTANCE',
#   level: 4 }
class StateToColor extends noflo.Component
  icon: 'adjust'
  description: 'Convert portal state information to a RGB value'

  constructor: ->
    @portals = []
    @states = []
    @inPorts = new noflo.InPorts
      portals:
        datatype: 'array'
        description: 'Array of portal IDs'
        required: yes
      state:
        datatype: 'object'
        description: 'Portal state object'
        required: yes

    @outPorts = new noflo.OutPorts
      colors:
        datatype: 'array'
        required: yes

    @inPorts.portals.on 'data', (@portals) =>

    @inPorts.state.on 'data', (state) =>
      return unless state.guid
      idx = @portals.indexOf state.guid
      return if idx is -1

      @states[idx] = @stateToRgb state
      @outPorts.colors.send @states

    @inPorts.state.on 'disconnect', =>
      @outPorts.colors.disconnect()

  stateToRgb: (state) ->
    if state.team is 'RESISTANCE'
      return [0, 0, 255]
    if state.team is 'ALIENS'
      return [0, 255, 0]

    # Neutral or third faction?
    return [255, 255, 255]

exports.getComponent = -> new StateToColor
