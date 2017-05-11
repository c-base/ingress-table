#!/usr/bin/env coffee
#// vim: set filetype=coffee:
noflo = require 'noflo'
path = require 'path'

loader = new noflo.ComponentLoader path.resolve __dirname, '../'
fbp = """
INPORT=Pulsate.COLORS:COLORS
INPORT=Pulsate.STEP:STEP
Pulsate(ingress-table/Pulsate) COLORS -> COLORS Convert(ingress-table/ConvertStreetLight)
Convert STREET1[0] -> IN RepeatRed(core/Repeat)
Convert STREET1[1] -> IN RepeatGreen(core/Repeat)
Convert STREET1[2] -> IN RepeatRed(core/Repeat)
RepeatRed OUT -> REDONE StreetLights(runtime/StreetLights)
RepeatGreen OUT -> GREENONE StreetLights
RepeatBlue OUT -> BLUEONE StreetLights
RepeatRed OUT -> FLOORRED StreetLights
RepeatGreen OUT -> FLOORGREEN StreetLights
RepeatBlue OUT -> FLOORBLUE StreetLights
Convert STREET2[0] -> REDTWO StreetLights
Convert STREET2[1] -> GREENTWO StreetLights
Convert STREET2[2] -> BLUETWO StreetLights
Convert STREET3[0] -> REDTHREE StreetLights
Convert STREET3[1] -> GREENTHREE StreetLights
Convert STREET3[2] -> BLUETHREE StreetLights
Convert STREET4[0] -> REDFOUR StreetLights
Convert STREET4[1] -> GREENFOUR StreetLights
Convert STREET4[2] -> BLUEFOUR StreetLights
"""

loadGraph = (graphDef, callback) ->
  noflo.graph.loadFBP graphDef, (err, graph) ->
    return callback err if err
    loader.listComponents (err) ->
      return callback err if err
      console.log 'Registering test graph to NoFlo'
      loader.registerGraph 'ingress-table', 'SimulateStreets', graph, (err) ->
        return callback err if err
        console.log 'Loading the test graph as component'
        loader.load 'ingress-table/SimulateStreets', (err, inst) ->
          console.log 'Loaded the test graph. Waiting for ready state'
          return callback err if err

          remoteSub = inst.network.getNode 'StreetLights'
          remoteSub.component.runtime.on 'connected', ->
            console.log "Remote subgraph connected"
          remoteSub.component.runtime.on 'error', (e) ->
            console.log "Remote subgraph error", e
          remoteSub.component.runtime.on 'runtime', (msg) ->
            console.log "RECEIVED #{msg.command} from runtime"

          inst.once 'ready', ->
            console.log 'Graph is ready'
            callback null, inst

loadGraph fbp, (err, inst) ->
  if err
    console.log err
    process.exit 1

  step = noflo.internalSocket.createSocket()
  colors = noflo.internalSocket.createSocket()
  inst.inPorts.step.attach step
  inst.inPorts.colors.attach colors

  currentColor = 'white'
  setInterval ->
    console.log "#{currentColor} step"
    step.send true
  , 500

  inst.network.on 'data', (data) ->
    return if data.id.indexOf('Street') is -1
    console.log data.id, data.data

  setTimeout ->
    currentColor = 'red'
    colors.send [255,0,0]
    setTimeout ->
      currentColor = 'green'
      colors.send [0,255,0]
      setTimeout ->
        currentColor = 'blue'
        colors.send [0,0,255]
        setTimeout ->
          console.log 'DONE'
          process.exit 0
        , 10000
      , 10000
    , 10000
  , 10000
