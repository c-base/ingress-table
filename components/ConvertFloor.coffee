noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'tint'
  c.description = 'Convert floor light colors to values sent to microcontroller'
  c.inPorts.add 'colors',
    datatype: 'array'
  c.outPorts.add 'floor',
    datatype: 'int'
    addressable: true
  c.previous = null
  c.tearDown = (callback) ->
    c.previous = null
    callback()
  c.process (input, output) ->
    return unless input.hasData 'colors'
    colors = input.getData 'colors'
    return output.done() unless colors.length
    if c.previous and colors[0] is c.previous[0] and colors[1] is c.previous[1] and colors[2] is c.previous[2]
      # No state change
      return output.done()
    c.previous = colors
    [r, g, b] = colors
    output.send
      floor: new noflo.IP 'data', r,
        index: 0
    output.send
      floor: new noflo.IP 'data', g,
        index: 1
    output.send
      floor: new noflo.IP 'data', b,
        index: 2
    output.done()
