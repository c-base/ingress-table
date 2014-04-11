noflo = require 'noflo'
chai = require 'chai' unless chai
GetAreaState = require '../components/GetAreaState.coffee'
fs = require 'fs'
path = require 'path'

describe 'GetAreaState component', ->
  c = null
  area = null
  hostname = null
  login = null
  states = null
  error = null
  portalConfig = null
  beforeEach ->
    c = GetAreaState.getComponent()
    area = noflo.internalSocket.createSocket()
    hostname = noflo.internalSocket.createSocket()
    login = noflo.internalSocket.createSocket()
    states = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.inPorts.area.attach area
    c.inPorts.hostname.attach hostname
    c.inPorts.login.attach login
    c.outPorts.states.attach states
    c.outPorts.error.attach error
    portalConfig = JSON.parse fs.readFileSync path.resolve(__dirname, '../portals.json'), 'utf-8'

  describe 'getting area information', ->
    it 'should be able to return data for all configured portals', (done) ->
      return done() unless process.env.API_HOST
      return done() unless process.env.API_USERNAME
      return done() unless process.env.API_PASSWORD

      hostname.send process.env.API_HOST
      login.send
        username: process.env.API_USERNAME
        password: process.env.API_PASSWORD

      error.on 'data', (data) ->
        chai.expect(true).to.equal false
        done()

      portals = []
      states.on 'data', (portalStates) ->
        chai.expect(portalStates).to.be.an 'array'
        portalConfig.portals.forEach (guid, led) ->
          unless guid
            portals.push
              led: led
              guid: null
              state: 'unused'
          return unless guid
          data = null
          for state in portalStates
            continue unless state.guid is guid
            data = state
            break
          unless data
            portals.push
              led: led
              guid: guid
              state: 'missing'
            return
          portals.push
            led: led
            guid: guid
            state: 'found'

          chai.expect(data).to.have.keys [
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

        for portal in portals
          if portal.guid is portalConfig.mainportal
            console.log "LED #{portal.led} (c-base #{portal.guid}) is #{portal.state}"
            continue
          console.log "LED #{portal.led} (#{portal.guid}) is #{portal.state}"
        done()

      area.send portalConfig.area
