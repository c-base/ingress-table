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
  c.process (input, output) ->
    return unless input.hasData 'colors'
    colors = input.getData 'colors'
    return output.done() unless colors.length
    [r, g, b] = colors[0]
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