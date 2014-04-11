noflo = require 'noflo'

class StateToColor extends noflo.Component
  icon: 'adjust'
  description: 'Convert portal state information to a RGB value'

  constructor: ->
    @portals = []
    @states = []
    @previousStates = {}
    @blinking = null
    @blink = 500
    @inPorts = new noflo.InPorts
      portals:
        datatype: 'array'
        description: 'Array of portal IDs'
        required: yes
      state:
        datatype: 'object'
        description: 'Portal state object'
        required: yes
      blink:
        datatype: 'int'
        description: 'Interval of lights blinking'
        required: no

    @outPorts = new noflo.OutPorts
      colors:
        datatype: 'array'
        required: no
      color:
        datatype: 'string'
        required: no
      states:
        datatype: 'object'
        required: no

    @inPorts.portals.on 'data', (@portals) =>
    @inPorts.blink.on 'data', (@blink) =>
      clearInterval @blinking if @blinking
      @blinking = null

    @inPorts.state.on 'data', (state) =>
      return unless state.guid
      idx = @portals.indexOf state.guid
      return if idx is -1

      @states[idx] = @stateToRgb state
      @outPorts.color.send "[#{idx}, \"#{@rgb2hex(@states[idx])}\"]"
      @outPorts.colors.send @states

      @previousStates[state.guid] = state

      @outPorts.states.send @previousStates

    @inPorts.state.on 'disconnect', =>
      @outPorts.colors.disconnect()
      @outPorts.color.disconnect()
      @outPorts.states.disconnect()

  teamToRgb: (state) ->
    if state.team is 'RESISTANCE'
      return [0, 0, 64]
    if state.team is 'ALIENS'
      return [0, 64, 0]

    # Neutral or third faction?
    return [64, 48, 0]

  stateToRgb: (state) ->
    base = @teamToRgb state
    return base if state is 'stable'
    do @startBlinking unless @blinking
    base

  calculateBlink: (state, idx) ->
    base = @teamToRgb state
    unless @states[idx]
      @states[idx] = base
    other = base.slice()
    random = -> Math.floor(Math.random() * 64) + 1
    switch state.state
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

    if @states[idx].join(',') is other.join(',')
      @states[idx] = base
      return
    @states[idx] = other

  blinkStep: =>
    changed = false
    for guid, state of @previousStates
      continue if state.state is 'stable'
      idx = @portals.indexOf state.guid
      continue if idx is -1
      @calculateBlink state, idx
      @outPorts.color.send "[#{idx}, \"#{@rgb2hex(@states[idx])}\"]"
      changed = true

    @outPorts.colors.send @states if changed

  startBlinking: ->
    @blinking = setInterval @blinkStep, @blink

  rgb2hex: ([red, green, blue]) ->
    rgb = blue | (green << 8) | (red << 16)
    '0x' + (0x1000000 + rgb).toString(16).slice(1).toUpperCase()

  shutdown: ->
    clearInterval @blinking if @blinking
    @blinking = null

exports.getComponent = -> new StateToColor
