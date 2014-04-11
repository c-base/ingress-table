noflo = require 'noflo'
chai = require 'chai' unless chai
StateToColor = require '../components/StateToColor.coffee'
fs = require 'fs'
path = require 'path'

describe 'StateToColor component', ->
  c = null
  state = null
  color = null
  portalConfig = null
  beforeEach ->
    c = StateToColor.getComponent()
    portals = noflo.internalSocket.createSocket()
    state = noflo.internalSocket.createSocket()
    color = noflo.internalSocket.createSocket()
    c.inPorts.portals.attach portals
    c.inPorts.state.attach state
    c.outPorts.color.attach color
    portalConfig = JSON.parse fs.readFileSync path.resolve(__dirname, '../portals.json'), 'utf-8'
    portals.send portalConfig.portals

  describe 'receiving a neutral portal', ->
    it 'should set the color correctly', (done) ->
      color.on 'data', (color) ->
        chai.expect(color).to.equal "[30, \"0x403000\"]"
        done()

      state.send
        guid: portalConfig.mainportal
        team: 'NEUTRAL'
        state: 'stable'
