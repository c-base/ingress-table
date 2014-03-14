http = require 'http'
noflo = require 'noflo'

class GetPortalState extends noflo.AsyncComponent
  description: 'Get the state of an individual Ingress portal'
  icon: 'fire'

  constructor: ->
    @hostname = ''
    @login = null

    @inPorts = new noflo.InPorts
      id:
        datatype: 'string'
        required: yes
        description: 'UUID of a portal'
      hostname:
        datatype: 'string'
        required: yes
        description: 'Hostname of the Ingress data provider'
      login:
        datatype: 'object'
        required: no
        description: 'Object containing the username and password information'

    @outPorts = new noflo.OutPorts
      state:
        datatype: 'object'
        required: yes
      error:
        datatype: 'object'
        required: no

    @inPorts.hostname.on 'data', (@hostname) =>
    @inPorts.login.on 'data', (@login) =>

    super 'id', 'state'

  doAsync: (id, callback) ->
    do callback

exports.getComponent = -> new GetPortalState
