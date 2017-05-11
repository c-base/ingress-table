#!/usr/bin/env coffee
#// vim: set filetype=coffee:
noflo = require 'noflo'
path = require 'path'
fs = require 'fs'
portals = JSON.parse fs.readFileSync path.resolve(__dirname, '../portals.json'), 'utf-8'

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
  ready = noflo.internalSocket.createSocket()
  shown = noflo.internalSocket.createSocket()
  pixelset = noflo.internalSocket.createSocket()
  inst.inPorts.pixel.attach pixel
  inst.inPorts.show.attach show
  inst.outPorts.ready.attach ready
  inst.outPorts.shown.attach shown
  inst.outPorts.pixelset.attach pixelset
  ready.on 'data', (data) ->
    console.log "READY", data
  shown.on 'data', (data) ->
    console.log "SHOWN", data
  pixelset.on 'data', (data) ->
    console.log "PIXELSET", data
  inst.start (err) ->
    if err
      console.log err
      process.exit 1

    # TODO: don't send until runtime hits running state

    setPortal = (id, color) ->
      val = "[#{id}, \"#{rgb2hex(color)}\"]"
      console.log "Sending #{val}"
      pixel.send val

    setPortals = (color) ->
      for portal,idx in portals.portals
        continue unless portal
        if idx is 37
          if color[2] is 64
            setPortal idx, [0, 0, 200]
          else
            setPortal idx, [0, 0, 64]
          continue
        setPortal idx, color
      console.log 'Sending SHOW'
      show.send true

    setTimeout ->
      console.log 'portals blue'
      setPortals [0, 0, 64]
      setTimeout ->
        console.log 'portals green'
        setPortals [0, 64, 0]
        setTimeout ->
          console.log 'portals red'
          setPortals [96, 0, 0]
          setTimeout ->
            console.log 'portals white'
            setPortals [64, 64, 64]
            setTimeout ->
              console.log "DONE"
              process.exit 0
            , 5000
          , 5000
        , 5000
      , 5000
    , 5000
