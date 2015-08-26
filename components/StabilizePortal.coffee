noflo = require 'noflo'

class StabilizePortal extends noflo.Component
  icon: 'fire-extinguisher'
  description: 'Resets a volatile portal to stable after a given time'

  constructor: ->
    @canDisconnect = true
    @timers = []
    @wait = 5000
    @inPorts = new noflo.InPorts
      state:
        datatype: 'object'
        description: 'Calculated state of the portal, e.g. under attack but blue'
        required: yes
      wait:
        datatype: 'int'
        description: 'How long to keep a portal volatile before stabilizing'
        required: no
    @outPorts = new noflo.OutPorts
      state:
        datatype: 'object'
        description: 'Calculated state of the portal, e.g. under attack but blue'
        required: yes

    @inPorts.state.on 'connect', =>
      @canDisconnect = false
    @inPorts.state.on 'data', (state) =>
      # Pass the current state through
      @outPorts.state.send state
      # Set a stabilization timer
      @stabilize state

    @inPorts.state.on 'disconnect', =>
      @canDisconnect = true
      do @checkDisconnect

    @inPorts.wait.on 'data', (@wait) =>

  stabilize: (state) =>
    return if state.state in [
      'stable'
      'awesome'
      'bad'
      'disco'
      ]

    timer = setTimeout =>
      state.state = 'stable'
      @outPorts.state.send state
      @timers.splice @timers.indexOf(timer), 1
      do @checkDisconnect
    , @wait

    @timers.push timer

  checkDisconnect: ->
    return unless @canDisconnect
    return if @timers.length
    @outPorts.state.disconnect()

  shutdown: ->
    while @timers.length
      timer = @timers.shift()
      clearTimeout timer
    do @checkDisconnect

exports.getComponent = -> new StabilizePortal
