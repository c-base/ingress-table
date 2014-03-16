noflo = require 'noflo'

class ConvertStreetLight extends noflo.Component
  icon: 'filter'
  description: 'Convert street light RGB values so we can send them to PWM'

  constructor: ->
    @inPorts = new noflo.InPorts
      colors:
        datatype: 'array'
        description: 'Street light values'
    @outPorts = new noflo.OutPorts
      street1:
        datatype: 'int'
        addressable: true
      street2:
        datatype: 'int'
        addressable: true
      street3:
        datatype: 'int'
        addressable: true
      street4:
        datatype: 'int'
        addressable: true

    @inPorts.colors.on 'data', (data) =>
      @convert data

  convertLight: (light, colors) ->
    for color, idx in colors
      @outPorts.ports["street#{light}"].send color, idx

  convert: (data) ->
    return unless data.length is 4
    for light, idx in data
      @convertLight idx+1, light

exports.getComponent = -> new ConvertStreetLight
