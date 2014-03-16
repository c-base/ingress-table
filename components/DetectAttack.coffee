noflo = require 'noflo'

class DetectAttack extends noflo.Component
  icon: 'eye'
  description: 'Detect if portal of interest is attacked'

  constructor: ->
    @id = null
    @inPorts = new noflo.InPorts
      portal:
        datatype: 'string'
        description: 'GUID of the portal of interest'
        required: yes
      state:
        datatype: 'object'
        description: 'Portal state object'
        required: yes
    @outPorts = new noflo.OutPorts
      color:
        datatype: 'array'
        required: yes

    @inPorts.portal.on 'data', (@id) =>

    @inPorts.state.on 'data', (state) =>
      return unless @id
      return unless state.guid
      return unless state.guid is @id

      if state.state is 'attack'
        @outPorts.color.send [255, 0, 0]
        return
      if state.state is 'disco'
        @outPorts.color.send [0, 255, 255]
        return
      @outPorts.color.send [255, 255, 255]

    @inPorts.state.on 'disconnect', =>
      @outPorts.color.disconnect()

exports.getComponent = -> new DetectAttack
