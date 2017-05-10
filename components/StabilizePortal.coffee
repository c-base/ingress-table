noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'fire-extinguisher'
  c.description = 'Resets a volatile portal to stable after a given time'
  c.inPorts.add 'state',
    datatype: 'object'
    description: 'Calculated state of the portal, e.g. under attack but blue'
    required: yes
  c.inPorts.add 'wait',
    datatype: 'int'
    description: 'How long to keep a portal volatile before stabilizing'
    required: no
    control: true
    default: 5000
  c.outPorts.add 'state',
    datatype: 'object'
    description: 'Calculated state of the portal, e.g. under attack but blue'
    required: yes

  c.setUp = (callback) ->
    c.timers = []
    callback()
  c.tearDown = (callback) ->
    return callback() unless c.timers
    while c.timers.length
      context = c.timers.shift()
      clearTimeout context.timer
      context.timer = null
      context.deactivate()
    callback()

  c.process (input, output, context) ->
    return unless input.hasData 'state', 'wait'
    wait = input.getData 'wait'
    state = input.getData 'state'

    # Pass the current state through
    output.send
      state: state

    # Deactivate in case of stable states
    return output.done() if state.state in [
      'stable'
      'awesome'
      'bad'
      'disco'
    ]

    # Set a stabilization timer
    context.timer = setTimeout ->
      state.state = 'stable'
      output.send
        state: state
      c.timers.splice c.timers.indexOf(context), 1
      context.timer = null
      context.deactivate()
    , wait
    c.timers.push context
