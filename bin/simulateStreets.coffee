#!/usr/bin/env coffee
#// vim: set filetype=coffee:
noflo = require 'noflo'
path = require 'path'

loader = new noflo.ComponentLoader path.resolve __dirname, '../'
fbp = """
INPORT=Pulsate.COLORS:COLORS
INPORT=Pulsate.STEP:STEP
INPORT=StreetLights.FLOORGREEN:GREEN
INPORT=StreetLights.FLOORBLUE:BLUE
Pulsate(ingress-table/Pulsate) COLORS -> COLORS Convert(ingress-table/ConvertStreetLight)
Convert STREET1[0] -> REDONE StreetLights(runtime/StreetLights)
Convert STREET1[1] -> GREENONE StreetLights
Convert STREET1[2] -> BLUEONE StreetLights
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
  noflo.graph.loadFBP graphDef, (graph) ->
    loader.listComponents ->
      console.log 'Registering test graph to NoFlo'
      loader.registerGraph 'ingress-table', 'SimulateStreets', graph, ->
        console.log 'Loading the test graph as component'
        loader.load 'SimulateStreets', (err, inst) ->
          return callback err if err
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
    return if data.id.indexOf('STREET') is -1
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
