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
    unless @login
      return callback new Error "Missing login details"
    unless @hostname
      return callback new Error "Missing API server hostname"

    req = http.request
      host: @hostname
      hostname: @hostname
      auth: "#{@login.username}:#{@login.password}"
      path: "/api/table/portals/#{id}/1"
    , (res) =>
      unless res.statusCode is 200
        return callback new Error "Server responded with #{res.statusCode}"

      body = ''
      res.on 'data', (chunk) ->
        body += chunk
      res.on 'end', =>
        return callback new Error 'No return value from server' unless body

        try
          portalState = JSON.parse body
        catch e
          return callback e

        @outPorts.state.beginGroup id
        @outPorts.state.send portalState
        @outPorts.state.endGroup()
        @outPorts.state.disconnect()
        do callback

    req.on 'error', (err) =>
      callback err
    req.end()

exports.getComponent = -> new GetPortalState
