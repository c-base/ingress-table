noflo = require 'noflo'

random = -> Math.floor(Math.random() * 64) + 1

rgb2hex = ([red, green, blue]) ->
  rgb = blue | (green << 8) | (red << 16)
  '0x' + (0x1000000 + rgb).toString(16).slice(1).toUpperCase()

teamToRgb = (state) ->
  if state.team is 'RESISTANCE'
    return [0, 0, 64]
  if state.team is 'ALIENS'
    return [0, 64, 0]
  # Neutral or third faction?
  return [0, 0, 0]

stateToArray = (idx, state) ->
  base = teamToRgb state
  period = 1000
  dutycycle = 50
  offset = 0 # TODO: See how this would feel randomized
  duration = 10000

  switch state.state
    when 'stable'
      other = base
      duration = 0
    when 'ownerchange'
      other = [64,64,64]
    when 'attack'
      other = [96, 0, 0]
    when 'disco'
      other = [random(), random(), random()]
    else
      other = []
      for val, index in base
        unless val
          other[index] = 0
          continue
        other[index] = 200

  # Level 8 portals just keep blinking
  duration = -1 if state.state in ['awesome', 'bad']

  # Return the proper array
  [idx, rgb2hex(other), rgb2hex(base), period, dutycycle, offset, duration]

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'adjust'
  c.description = 'Convert portal state information to an array'

  c.inPorts.add 'portals',
    datatype: 'array'
    description: 'Array of portal IDs indexed by the light in chain'
    required: yes
  c.inPorts.add 'state',
    datatype: 'object'
    description: 'Portal state object from Ingress API'
    required: yes
  c.outPorts.add 'light',
    datatype: 'array'
    required: no
  c.outPorts.add 'states',
    datatype: 'array'
    required: no
  c.outPorts.add 'error',
    datatype: 'object'
    required: no

  noflo.helpers.WirePattern c,
    in: 'state'
    params: ['portals']
    out: ['light', 'states']
    forwardGroups: no
  , (data, groups, out) ->
    c.previousStates = {} unless c.previousStates

    unless data.guid
      c.error new Error 'Portal data is missing GUID'
      return
    unless c.params.portals
      c.error new Error 'Portal list not available'
      return
    idx = c.params.portals.indexOf data.guid
    if idx is -1
      c.error new Error "Portal #{data.guid} is not in portals list"
      return

    out.light.send stateToArray idx, data
    c.previousStates[data.guid] = data
    out.states.send c.previousStates

  c
