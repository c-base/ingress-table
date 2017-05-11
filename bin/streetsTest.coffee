#!/usr/bin/env coffee
#// vim: set filetype=coffee:
noflo = require 'noflo'
path = require 'path'

loader = new noflo.ComponentLoader path.resolve __dirname, '../'
loadGraph = (callback) ->
  loader.listComponents (err) ->
    return callback err if err
    console.log 'Loading the test graph as component'
    loader.load 'runtime/StreetLights', (err, inst) ->
      return callback err if err
      console.log 'Loaded the test graph. Waiting for ready state'
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

  ports = [
    'floorred'
    'floorgreen'
    'floorblue'
    'redone'
    'greenone'
    'blueone'
    'redtwo'
    'greentwo'
    'bluetwo'
    'redthree'
    'greenthree'
    'bluethree'
    'redfour'
    'greenfour'
    'bluefour'
  ]
  sockets = []
  for port in ports
    socket = noflo.internalSocket.createSocket()
    inst.inPorts[port].attach socket
    sockets.push socket

  sendAndWait = (port, socket, value, callback) ->
    console.log "#{port} #{value}"
    socket.send value
    setTimeout callback, 1000

  step = ->
    port = ports.shift()
    socket = sockets.shift()
    unless sockets.length
      console.log "DONE"
      process.exit 0
    sendAndWait port, socket, 10, ->
      sendAndWait port, socket, 50, ->
        sendAndWait port, socket, 100, ->
          sendAndWait port, socket, 0, ->
            step()
  do step
