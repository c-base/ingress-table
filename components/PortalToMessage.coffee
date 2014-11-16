noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'portal',
    datatype: 'object'
  c.outPorts.add 'topic',
    datatype: 'string'
  c.outPorts.add 'message',
    datatype: 'string'

  noflo.helpers.WirePattern c,
    in: 'portal'
    out: ['topic', 'message']
    forwardGroups: true
  , (data, groups, out) ->
    out.topic.send "ingress/status/#{data.guid}"
    out.message.send JSON.stringify data

  c
