https = require 'https'
noflo = require 'noflo'
querystring = require 'querystring'
googleAuth = require 'google-auth-library'
googleOAuth2 = new googleAuth().OAuth2

# @runtime noflo-nodejs

authUrl = 'https://www.google.com/accounts/OAuthLogin'
apiSource = 'com.google.ingress.dev.external'
apiService = 'ah'
apiHost = 'betaspike.appspot.com'
apiPath = '/rpc/externalApi/getPortalInfo/'
loginPath = '/_ah/login'
xsrfPath = '/xsrftoken'
updateInterval = 60 * 60 * 12 * 1000

getRequestOptions = (method, host, path) ->
  return options =
    host: host
    port: 443
    method: method
    path: path
    agent: false

getAuth = (credentials, callback) ->
  auth = new googleOAuth2 credentials.client_id, credentials.client_secret
  auth.credentials = credentials
  auth.credentials.expiry_date = new Date(credentials.token_expiry).getTime()
  auth.request
    method: 'POST'
    uri: authUrl
    form:
      source: apiSource
      service: apiService
    headers:
      'User-Agent': 'ingress-table'
  , (err, data) ->
    return callback err if err
    dict = {}
    rows = data.split '\n'
    for r in rows
      [key, value] = r.split '='
      continue unless key
      dict[key] = value

    unless dict.Auth
      return callback new Error 'Failed to receive auth code'

    callback err, dict.Auth

obtainCookie = (auth, callback) ->
  cookiePath = loginPath + '?' + querystring.stringify
    auth: auth
  options = getRequestOptions 'GET', apiHost, cookiePath
  options.headers =
    'User-Agent': 'ingress-table'
  req = https.request options, (res) ->
    unless res.headers['set-cookie']
      return callback new Error 'No cookie received'
    callback null, res.headers['set-cookie']
  req.setTimeout 2000
  req.end()

obtainXsrf = (cookie, callback) ->
  options = getRequestOptions 'GET', apiHost, xsrfPath
  options.headers =
    'Cookie': cookie
    'User-Agent': 'ingress-table'
  req = https.request options, (res) ->
    unless res.statusCode is 200
      data = ''
      res.on 'data', (chunk) ->
        data += chunk
      res.on 'end', ->
        return callback new Error 'XSFR request failed: ' + data
    data = ''
    res.on 'data', (chunk) ->
      data += chunk
    res.on 'end', ->
      callback null,
        xsrf: data
        timeout: Date.now() + updateInterval
  req.setTimeout 2000
  req.end()

getPortals = (portals, username, cookie, xsrf, callback) ->
  options = getRequestOptions 'POST', apiHost, "#{apiPath}#{username}"
  options.headers =
    'Cookie': cookie
    'X-XsrfToken': xsrf
    'Content-Type': 'application/json'
    'User-Agent': 'ingress-table'

  data =
    params: [portals]
  jsonData = JSON.stringify data
  options.headers['Content-Length'] = jsonData.length

  req = https.request options, (res) ->
    data = ''
    res.on 'data', (chunk) ->
      data += chunk
    res.on 'end', ->
      received = JSON.parse data
      if received.error
        callback new Error received.error
        return
      unless res.statusCode is 200
        callback new Error received.exception
        return
      callback null, normalizeResult received.result

  req.setTimeout 2000
  req.write jsonData
  req.end()

normalizeResult = (result) ->
  states = []
  for guid, val of result
    portal = val.externalApiPortal
    portal.guid = guid
    portal.updated = new Date
    switch portal.controllingFaction
      when 'Resistance'
        portal.team = 'RESISTANCE'
      when 'Enlightened'
        portal.team = 'ALIENS'
      else
        portal.team = 'NEUTRAL'
    states.push portal
  states

hasXsrf = (c) ->
  return false unless c.xsrf
  return false unless Date.now() < c.xsrfValid
  true

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'fire'
  c.description = 'Get the state of Ingress portal(s)'

  c.inPorts.add 'auth',
    datatype: 'string'
    required: yes
    description: 'Authorization token'
  c.inPorts.add 'username',
    datatype: 'string'
    required: yes
    description: 'API username'
  c.inPorts.add 'portals',
    datatype: 'array'
    description: 'List of portal GUIDs to fetch'
  c.outPorts.add 'states',
    datatype: 'array'
    required: yes
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'portals'
    params: ['username', 'auth']
    out: 'states'
    async: true
  , (data, groups, out, callback) ->
    guids = data.filter (p) -> typeof p is 'string'

    unless c.cookie
      try
        credentials = JSON.parse c.params.auth
      catch e
        return callback e
      getAuth credentials, (err, auth) ->
        return callback err if err
        obtainCookie auth, (err, cookie) ->
          return callback err if err
          c.cookie = cookie
          obtainXsrf c.cookie, (err, xsrf) ->
            if err
              c.cookie = null
              return callback err
            c.xsrf = xsrf.xsrf
            c.xsrfValid = xsrf.timeout
            getPortals guids, c.params.username, c.cookie, c.xsrf, (err, states) ->
              if err
                c.cookie = null
                c.xsrf = null
                return callback err
              out.beginGroup Date.now()
              out.send states
              out.endGroup()
              do callback
      return

    unless hasXsrf c
      obtainXsrf c.cookie, (err, xsrf) ->
        if err
          c.cookie = null
          return callback err
        c.xsrf = xsrf.xsrf
        c.xsrfValid = xsrf.timeout
        getPortals guids, c.params.username, c.cookie, c.xsrf, (err, states) ->
          return callback err if err
          out.beginGroup Date.now()
          out.send states
          out.endGroup()
          do callback
      return

    getPortals guids, c.params.username, c.cookie, c.xsrf, (err, states) ->
      return callback err if err
      out.beginGroup Date.now()
      out.send states
      out.endGroup()
      do callback

  c
