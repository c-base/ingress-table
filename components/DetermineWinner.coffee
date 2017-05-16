noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    icon: 'trophy'
    decription: 'Determine which faction is winning'
    inPorts:
      states:
        datatype: 'object'
        required: yes
    outPorts:
      colors:
        datatype: 'array'
        required: no
      blue:
        datatype: 'int'
        required: no
      green:
        datatype: 'int'
        required: no
  c.process (input, output) ->
    return unless input.hasData 'states'
    states = input.getData 'states'
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
      output.sendDone
        green: 200
        blue: 0
        colors: [0, 255, 0]
      return
    if us > them
      output.sendDone
        green: 0
        blue: 200
        colors: [0, 0, 255]
      return
    output.sendDone
      colors: [255, 255, 0]
