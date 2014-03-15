noflo = require 'noflo'

class CalculateState extends noflo.Component
  icon: 'eye'
  description: 'Determine the table state of a portal based on state changes in Ingress'

  constructor: ->
    # Previous seen state of the portals, keyed by GUID
    @previousStates = {}

    @inPorts = new noflo.InPorts
      state:
        type: 'http://ingress.com/ns#portal'
        datatype: 'object'
        # { guid: 'a6301120831b46f1be00fa2cb0bce195.16',
        #   health: 100,
        #   team: 'RESISTANCE',
        #   level: 4 }
        description: 'Current state of a portal in Ingress'
        required: yes
    @outPorts = new noflo.OutPorts
      state:
        datatype: 'object'
        description: 'Calculated state of the portal, e.g. under attack but blue'
        required: yes

    @inPorts.state.on 'data', (newState) =>
      return unless newState.guid
      @outPorts.state.send @calculateState newState, @previousStates
      @previousStates[newState.guid] = newState
    @inPorts.state.on 'disconnect', =>
      @outPorts.state.disconnect()

  calculateState: (newState, previousStates) ->
    state =
      guid: newState.guid
      team: newstate.team
      state: 'stable'

    previous = previousState[newState.guid]
    return state unless previous

    # We have a previous state to compare with

    if newState.team isnt previous.team
      state.state = 'ownerchange'
      return state

    if newState.level > previous.level and newState.level isnt 8
      state.state = 'upgraded'
      return state

    if newState.level < previous.level or newState.health < previous.health
      state.state = 'attack'
      return state

    if newState.level is 8 newState.team is 'RESISTANCE'
      state.state = 'awesome'
      return state

    if newState.level is 8 and newState.team is 'ALIENS'
      state.state = 'bad'
      return state

    if newState.level is 8 and newState.team is 'NEUTRAL'
      state.state = 'disco'
      return state

    if newState.level > 8
      state.state = 'calvinball'
      return state

    return state

exports.getComponent = -> new CalculateState
    return state

exports.getComponent = -> new CalculateState
