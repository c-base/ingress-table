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
    followed = colors[0]
    if c.previous and followed[0] is c.previous[0] and followed[1] is c.previous[1] and followed[2] is c.previous[2]
      # No state change
      return output.done()
    c.previous = followed
    [r, g, b] = followed
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
