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
  c.second = false
  c.tearDown = (callback) ->
    c.state = {}
    c.second = false
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
      if c.second
        value = state[1]
      else
        value = state[2]
      output.send
        pixel: [portal, value]
    if c.second
      c.second = false
    else
      c.second = true
    output.done()