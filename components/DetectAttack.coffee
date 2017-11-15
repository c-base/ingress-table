noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'eye'
  c.description = 'Detect if portal of interest is attacked'
  c.inPorts.add 'portal',
    datatype: 'string'
    description: 'GUID of the portal of interest'
    required: yes
    control: yes
  c.inPorts.add 'state',
    datatype: 'object'
    description: 'Portal state object'
    required: yes
  c.outPorts.add 'color',
    datatype: 'array'
    required: yes
  c.process (input, output) ->
    return unless input.hasData 'portal', 'state'
    [portal, state] = input.getData 'portal', 'state'
    unless state?.guid is portal
      # Not a portal of interest
      output.done()
      return
    # Default is white
    color = [255, 255, 255]
    if state.state is 'attack'
      console.log 'Main portal under attack, RED floor'
      color = [255, 0, 0]
    if state.state is 'disco'
      color = [0, 255, 255]
    output.sendDone
      color: color
