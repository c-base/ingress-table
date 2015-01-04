#!/usr/bin/env coffee
#// vim: set filetype=coffee:
noflo = require 'noflo'
path = require 'path'

loader = new noflo.ComponentLoader path.resolve __dirname, '../'
rgb2hex = ([red, green, blue]) ->
  rgb = blue | (green << 8) | (red << 16)
  '0x' + (0x1000000 + rgb).toString(16).slice(1).toUpperCase()

loadGraph = (callback) ->
  loader.listComponents ->
    console.log 'Loading the test graph as component'
    loader.load 'runtime/PortalLights', (err, inst) ->
      console.log 'Loaded the test graph. Waiting for ready state'
      return callback err if err

      inst.runtime.on 'connected', ->
        console.log "Remote subgraph connected"
      inst.runtime.on 'error', (e) ->
        console.log "Remote subgraph error", e
      inst.runtime.on 'runtime', (msg) ->
        console.log "RECEIVED #{msg.command} from runtime"

      inst.once 'ready', ->
        console.log 'Graph is ready'
        callback null, inst

loadGraph (err, inst) ->
  if err
    console.log err
    process.exit 1

  pixel = noflo.internalSocket.createSocket()
  show = noflo.internalSocket.createSocket()
  inst.inPorts.pixel.attach pixel
  inst.inPorts.show.attach show
  inst.start()

  setPortal = (id, color) ->
    pixel.send "[#{id}, \"#{rgb2hex(color)}\"]"
    show.send true

  console.log 'c-base blue'
  setPortal 37, [0, 0, 64]
  setTimeout ->
    console.log 'c-base green'
    setPortal 37, [0, 64, 0]
    setTimeout ->
      console.log 'c-base red'
      setPortal 37, [96, 0, 0]
      setTimeout ->
        console.log 'c-base white'
        setPortal 37, [64, 64, 64]
      , 5000
    , 5000
  , 5000
