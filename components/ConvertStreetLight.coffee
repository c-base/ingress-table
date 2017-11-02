noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'road'
  c.description = 'Convert street light RGB values so we can send them to PWM'
  c.inPorts.add 'colors',
    datatype: 'array'
    description: 'Street light values'
  c.outPorts.add 'street1',
    datatype: 'int'
    addressable: true
  c.outPorts.add 'street2',
    datatype: 'int'
    addressable: true
  c.outPorts.add 'street3',
    datatype: 'int'
    addressable: true
  c.outPorts.add 'street4',
    datatype: 'int'
    addressable: true
  c.process (input, output) ->
    return unless input.hasData 'colors'
    data = input.getData 'colors'
    unless data.length is 4
      output.done()
      return
    for light, target in data
      for color, idx in light
        light = target + 1
        result = {}
        result["street#{light}"] = new noflo.IP 'data', color,
          index: idx
        output.send result
    output.done()
