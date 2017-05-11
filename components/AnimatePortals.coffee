noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'filter'
  c.description = 'Animate portals on the microcontroller'
  c.inPorts.add 'light',
    datatype: 'array'
  c.inPorts.add 'step',
    datatype: 'bang'
  c.outPorts.add 'pixel',
    datatype: 'array'
  c.state = {}
  c.sent = {}
  c.tearDown = (callback) ->
    c.state = {}
    c.sent = {}
    callback()
  c.process (input, output) ->
    if input.hasData 'light'
      light = input.getData 'light'
      c.state[light[0]] = light
      output.done()
      return
    return unless input.hasData 'step'
    input.getData 'step'
    for portal, state of c.state
      # Start with first color
      value = state[1]
      if value is c.sent[portal]
        # If previous sent was first, go with second color
        value = state[2]
      # Don't send if color isn't changing
      continue if value is c.sent[portal]
      output.send
        pixel: [portal, value]
      # Store sent value
      c.sent[portal] = value
    output.done()
