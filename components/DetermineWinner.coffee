noflo = require 'noflo'

class DetermineWinner extends noflo.Component
  icon: 'trophy'
  decription: 'Determine which faction is winning'

  constructor: ->
    @inPorts = new noflo.InPorts
      states:
        datatype: 'object'
        required: yes
    @outPorts = new noflo.OutPorts
      colors:
        datatype: 'array'
        required: yes
      blue:
        datatype: 'int'
        required: no
      green:
        datatype: 'int'
        required: no

    @inPorts.states.on 'data', (states) =>
      @outPorts.colors.send @determine states
    @inPorts.states.on 'disconnect', =>
      @outPorts.colors.disconnect()
      @outPorts.blue.disconnect()
      @outPorts.green.disconnect()

  determine: (states) ->
    us = 0
    them = 0

    for guid, state of states
      if state.team is 'ALIENS'
        them++
        continue
      if state.team is 'RESISTANCE'
        us++
        continue

    if them > us
      @outPorts.green.send 255
      @outPorts.blue.send 0
      return [[0, 255, 0]]
    if us > them
      @outPorts.green.send 0
      @outPorts.blue.send 255
      return [[0, 0, 255]]
    return [[0, 0, 0]]

exports.getComponent = -> new DetermineWinner
