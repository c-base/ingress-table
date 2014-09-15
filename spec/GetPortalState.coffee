noflo = require 'noflo'
chai = require 'chai' unless chai
GetPortalState = require '../components/GetPortalState.coffee'
fs = require 'fs'
path = require 'path'

describe 'GetPortalState component', ->
  c = null
  id = null
  hostname = null
  login = null
  state = null
  error = null
  portalConfig = null
  beforeEach ->
    c = GetPortalState.getComponent()
    id = noflo.internalSocket.createSocket()
    hostname = noflo.internalSocket.createSocket()
    login = noflo.internalSocket.createSocket()
    state = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.inPorts.id.attach id
    c.inPorts.hostname.attach hostname
    c.inPorts.login.attach login
    c.outPorts.state.attach state
    c.outPorts.error.attach error
    portalConfig = JSON.parse fs.readFileSync path.resolve(__dirname, '../portals.json'), 'utf-8'

  describe.skip 'getting portal information', ->
    it 'should be able to retrieve it', (done) ->
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

      state.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data).to.have.keys [
          'guid'
          'health'
          'level'
          'team'
        ]
        chai.expect(data.guid).to.equal portalConfig.mainportal
        chai.expect(data.health).to.be.a 'number'
        chai.expect(data.health).to.be.within 0, 100
        chai.expect(data.level).to.be.a 'number'
        chai.expect(data.level).to.be.within 0, 8
        chai.expect(data.team).to.be.a 'string'
        chai.expect(data.team).to.match /RESISTANCE|ALIENS|NEUTRAL/
        done()

      id.send portalConfig.mainportal
