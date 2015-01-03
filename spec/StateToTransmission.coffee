noflo = require 'noflo'
chai = require 'chai' unless chai
StateToTransmission = require '../components/StateToTransmission.coffee'
fs = require 'fs'
path = require 'path'

describe 'StateToTransmission component', ->
  @timeout 4000
  c = null
  state = null
  light = null
  portalConfig = null
  beforeEach ->
    c = StateToTransmission.getComponent()
    portals = noflo.internalSocket.createSocket()
    state = noflo.internalSocket.createSocket()
    light = noflo.internalSocket.createSocket()
    c.inPorts.portals.attach portals
    c.inPorts.state.attach state
    c.outPorts.light.attach light
    portalConfig = JSON.parse fs.readFileSync path.resolve(__dirname, '../portals.json'), 'utf-8'
    portals.send portalConfig.portals

  describe 'receiving a neutral portal', ->
    it 'should set the light correctly', (done) ->
      light.on 'data', (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data).to.eql [
          37         # Light IDX
          "0x000000" # Accent color
          "0x000000" # Base color
          1000       # Period ms
          50         # Duty cycle %
          0          # Offset ms
          0          # Length ms
        ]
        done()

      state.send
        guid: portalConfig.mainportal
        team: 'NEUTRAL'
        state: 'stable'

  describe 'receiving a Resistance portal under attack', ->
    it 'should set the light correctly', (done) ->
      light.on 'data', (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data).to.eql [
          37         # Light IDX
          "0x600000" # Accent color
          "0x000040" # Base color
          1000       # Period ms
          50         # Duty cycle %
          0          # Offset ms
          10000      # Length ms
        ]
        done()

      state.send
        guid: portalConfig.mainportal
        team: 'RESISTANCE'
        state: 'attack'

  describe 'receiving a portal that has been recently captured', ->
    it 'should set the light correctly', (done) ->
      light.on 'data', (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data).to.eql [
          37         # Light IDX
          "0x404040" # Accent color
          "0x000040" # Base color
          1000       # Period ms
          50         # Duty cycle %
          0          # Offset ms
          10000      # Length ms
        ]
        done()

      state.send
        guid: portalConfig.mainportal
        team: 'RESISTANCE'
        state: 'ownerchange'

  describe 'receiving a portal that is L8 green', ->
    it 'should set the light correctly', (done) ->
      light.on 'data', (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data).to.eql [
          37         # Light IDX
          "0x00C800" # Accent color
          "0x004000" # Base color
          1000       # Period ms
          50         # Duty cycle %
          0          # Offset ms
          -1         # Length ms
        ]
        done()

      state.send
        guid: portalConfig.mainportal
        team: 'ALIENS'
        state: 'bad'
