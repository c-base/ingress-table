http = require 'http'
noflo = require 'noflo'

class GetAreaState extends noflo.AsyncComponent
  description: 'Get the state of an individual Ingress portal'
  icon: 'globe'

  constructor: ->
    @hostname = ''
    @login = null

    @inPorts = new noflo.InPorts
      area:
        datatype: 'object'
        required: yes
        description: 'Corner coordinates for the area to fetch'
      hostname:
        datatype: 'string'
        required: yes
        description: 'Hostname of the Ingress data provider'
      login:
        datatype: 'object'
        required: no
        description: 'Object containing the username and password information'

    @outPorts = new noflo.OutPorts
      states:
        datatype: 'array'
        required: yes
      error:
        datatype: 'object'
        required: no

    @inPorts.hostname.on 'data', (@hostname) =>
    @inPorts.login.on 'data', (@login) =>

    super 'area', 'states'

  doAsync: (area, callback) ->
    do callback

exports.getComponent = -> new GetAreaState
