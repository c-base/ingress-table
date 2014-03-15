noflo = require 'noflo'

class StateToColor extends noflo.Component
  icon: 'adjust'
  description: 'Convert portal state information to a RGB value'

  constructor: ->
    @portals = []
    @states = []
    @previousStates = {}
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

      @previousStates[state.guid] = state

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
