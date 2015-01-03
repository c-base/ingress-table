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
      loader.registerGraph 'ingress-table', 'SimulateStreets', graph, ->
        loader.load 'SimulateStreets', (err, inst) ->
          return callback err if err
          inst.once 'ready', ->
            callback null, inst

loadGraph fbp, (err, inst) ->
  if err
    console.log err
    process.exit 1

  step = noflo.internalSocket.createSocket()
  colors = noflo.internalSocket.createSocket()
  inst.inPorts.step.attach step
  inst.inPorts.colors.attach colors

  setInterval ->
    step.send true
  , 60

  setTimeout ->
    colors.send [255,0,0]
    setTimeout ->
      colors.send [255,255,255]
      setTimeout ->
        process.exit 0
      , 1000
    , 1000
  , 1000
