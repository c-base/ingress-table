noflo = require "noflo"

class SetPortalColor extends noflo.Component
  icon: 'lightbulb-o'
  
  constructor: () ->

    @inPorts = new noflo.InPorts
      in:
        datatype: 'array'
        description: 'array of arrays pf rgb values [[r, g, b], [r, g, b], [r, g, b], ... ]'

    @inPorts.in.on 'data', (data) ->
      # Read DOM
      portals = document.getElementsByClassName 'led'

      for color, idx in data
        portal = portals[idx]

        continue unless (portal and color)

        portal.style.backgroundColor = "rgb(#{color.join(',')})"

exports.getComponent = -> new SetPortalColor