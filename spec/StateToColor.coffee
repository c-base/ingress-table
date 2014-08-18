noflo = require 'noflo'
chai = require 'chai' unless chai
StateToColor = require '../components/StateToColor.coffee'
fs = require 'fs'
path = require 'path'

describe 'StateToColor component', ->
  @timeout 4000
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

  afterEach ->
    # Stop blinking
    c.shutdown()

  describe 'receiving a neutral portal', ->
    it 'should set the color correctly', (done) ->
      color.on 'data', (color) ->
        chai.expect(color).to.equal "[37, \"0x000000\"]"
        done()

      state.send
        guid: portalConfig.mainportal
        team: 'NEUTRAL'
        state: 'stable'

  describe 'receiving a Resistance portal under attack', ->
    it 'should set the color correctly', (done) ->
      expected = [
        "[37, \"0x000040\"]"
        "[37, \"0x600000\"]"
        "[37, \"0x000040\"]"
        "[37, \"0x600000\"]"
      ]
      color.on 'data', (color) ->
        chai.expect(color).to.equal expected.shift()
        done() unless expected.length

      state.send
        guid: portalConfig.mainportal
        team: 'RESISTANCE'
        state: 'attack'

  describe 'receiving a portal that has been recently captured', ->
    it 'should set the color correctly', (done) ->
      expected = [
        "[37, \"0x000040\"]"
        "[37, \"0x404040\"]"
        "[37, \"0x000040\"]"
        "[37, \"0x404040\"]"
      ]
      color.on 'data', (color) ->
        chai.expect(color).to.equal expected.shift()
        done() unless expected.length

      state.send
        guid: portalConfig.mainportal
        team: 'RESISTANCE'
        state: 'ownerchange'

  describe 'receiving a portal that is L8 green', ->
    it 'should set the color correctly', (done) ->
      expected = [
        "[37, \"0x004000\"]"
        "[37, \"0x00C800\"]"
        "[37, \"0x004000\"]"
        "[37, \"0x00C800\"]"
      ]
      color.on 'data', (color) ->
        chai.expect(color).to.equal expected.shift()
        done() unless expected.length

      state.send
        guid: portalConfig.mainportal
        team: 'ALIENS'
        state: 'bad'
