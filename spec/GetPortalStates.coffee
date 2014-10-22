noflo = require 'noflo'
chai = require 'chai' unless chai
GetPortalStates = require '../components/GetPortalStates.coffee'
fs = require 'fs'
path = require 'path'

describe 'GetPortalStates component', ->
  c = null
  portals = null
  cookie = null
  username = null
  states = null
  error = null
  portalConfig = null
  cookieData = null
  beforeEach ->
    c = GetPortalStates.getComponent()
    portals = noflo.internalSocket.createSocket()
    cookie = noflo.internalSocket.createSocket()
    username = noflo.internalSocket.createSocket()
    states = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.inPorts.portals.attach portals
    c.inPorts.auth.attach cookie
    c.inPorts.username.attach username
    c.outPorts.states.attach states
    c.outPorts.error.attach error
    portalConfig = JSON.parse fs.readFileSync path.resolve(__dirname, '../portals.json'), 'utf-8'
    cookieData = fs.readFileSync path.resolve(__dirname, '../cookie.txt'), 'utf-8'

  describe 'getting area information', ->
    it 'should be able to return data for all configured portals', (done) ->
      @timeout 10000
      error.on 'data', (data) ->
        console.log data
        chai.expect(true).to.equal false
        done()

      portalData = []
      states.on 'data', (portalStates) ->
        chai.expect(portalStates).to.be.an 'array'
        portalConfig.portals.forEach (guid, led) ->
          unless guid
            portalData.push
              title: 'Unused'
              led: led
              guid: null
              state: 'unused'
              team: ''
              level: ''
          return unless guid
          data = null
          for state in portalStates
            continue unless state.guid is guid
            data = state
            break
          unless data
            portalData.push
              title: 'Unknown'
              led: led
              guid: guid
              state: 'missing'
              team: ''
              level: ''
            return
          portalData.push
            title: data.title
            led: led
            guid: guid
            state: 'found'
            team: data.team
            level: "L#{data.level}"

          chai.expect(data).to.include.keys [
            'guid'
            'health'
            'level'
            'team'
          ]
          chai.expect(data.health).to.be.a 'number'
          chai.expect(data.health).to.be.within 0, 100
          chai.expect(data.level).to.be.a 'number'
          chai.expect(data.level).to.be.within 0, 8
          chai.expect(data.team).to.be.a 'string'
          chai.expect(data.team).to.match /RESISTANCE|ALIENS|NEUTRAL/

        for portal in portalData
          console.log "LED #{portal.led} (#{portal.guid}, #{portal.title}) is #{portal.state} #{portal.level} #{portal.team}"
        done()

      cookie.send cookieData
      username.send process.env.API_USER or 'bergius'
      portals.send portalConfig.portals
