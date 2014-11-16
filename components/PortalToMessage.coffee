noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'portal',
    datatype: 'object'
  c.outPorts.add 'topic',
    datatype: 'string'
  c.outPorts.add 'message',
    datatype: 'string'

  c.previousData = {}

  noflo.helpers.WirePattern c,
    in: 'portal'
    out: ['topic', 'message']
    forwardGroups: true
  , (data, groups, out) ->
    previous = c.previousData[data.guid]
    c.previousData[data.guid] = data

    send = ->
      topic = "ingress/status/#{data.guid}"
      console.log "Sending #{data.title} to #{topic}"
      out.topic.send topic
      out.message.send JSON.stringify data

    unless previous
      do send
      return

    interval = 5*60*1000
    if previous.updated and previous.updated.getTime() + interval < data.updated.getTime()
      # Send every 5min anyway
      do send
      return

    if previous.team is data.team and previous.level is data.level and previous.health is data.health
      # No changes of interest
      return

    do send
  c
