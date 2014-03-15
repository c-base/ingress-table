noflo = require "noflo"

class SetLEDColor extends noflo.Component
  icon: 'lightbulb-o'
  constructor: () ->
    @selector = null

    @inPorts = new noflo.InPorts
      in:
        datatype: 'array'
        description: 'array of arrays pf rgb values [[r, g, b], [r, g, b], [r, g, b], ... ]'
      selector:
        datatype: 'string'
        description: 'The class name of the LEDs that should be controlled via this component.'

    @inPorts.in.on 'data', (data) =>
      return unless @selector
      leds = document.getElementsByClassName @selector

      for color, idx in data
        led = leds[idx]

        continue unless (led and color)

        led.style.backgroundColor = "rgb(#{color.join(',')})"

    @inPorts.selector.on 'data', (@selector) =>

exports.getComponent = -> new SetLEDColor