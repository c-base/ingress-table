http = require 'http'
noflo = require 'noflo'

# @runtime noflo-nodejs

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
    unless @login
      return callback new Error "Missing login details"
    unless @hostname
      return callback new Error "Missing API server hostname"

    req = http.request
      host: @hostname
      hostname: @hostname
      auth: "#{@login.username}:#{@login.password}"
      path: "/api/table/area/#{area.minLatE6}/#{area.minLonE6}/#{area.maxLatE6}/#{area.maxLonE6}"
    , (res) =>
      body = ''
      res.on 'data', (chunk) ->
        body += chunk
      res.on 'end', =>
        return callback new Error 'No return value from server' unless body

        try
          portalStates = JSON.parse body
        catch e
          return callback e

        unless res.statusCode is 200
          return callback new Error "Server responded with #{res.statusCode}"
        @outPorts.states.send portalStates
        do callback

    req.on 'error', (err) =>
      callback err
    req.setTimeout 1000, -> req.abort()
    req.end()

exports.getComponent = -> new GetAreaState
