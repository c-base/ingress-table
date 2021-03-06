noflo = require 'noflo'

# @runtime noflo-nodejs

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'eye'
  c.description = 'Determine the table state of a portal based on state changes in Ingress'
  c.inPorts.add 'state',
    type: 'http://ingress.com/ns#portal'
    datatype: 'object'
    # { guid: 'a6301120831b46f1be00fa2cb0bce195.16',
    #   health: 100,
    #   team: 'RESISTANCE',
    #   level: 4 }
    description: 'Current state of a portal in Ingress'
    required: yes
  c.outPorts.add 'state',
    datatype: 'object'
    description: 'Calculated state of the portal, e.g. under attack but blue'
    required: yes

  c.setUp = (callback) ->
    # Previous seen state of the portals, keyed by GUID
    c.previousStates = {}
    callback()
  c.tearDown = (callback) ->
    delete c.previousStates
    callback()

  c.forwardBrackets =
    state: ['state']
  c.process (input, output) ->
    return unless input.hasData 'state'
    newState = input.getData 'state'
    return output.done() unless newState.guid
    output.send
      state: calculateState newState, c.previousStates
    c.previousStates[newState.guid] = newState
    output.done()

calculateState = (newState, previousStates) ->
  state =
    guid: newState.guid
    team: newState.team
    state: 'stable'

  if newState.shards
    # TODO: We don't get Shard info from the API yet, this is merely a placeholder
    console.log newState.updated, "Portal #{newState.title} has shards"
    state.state = 'disco'
    return state

  if newState.level is 8 and newState.team is 'RESISTANCE'
    console.log newState.updated, "Portal #{newState.title} is L#{newState.level} #{newState.team}"
    state.state = 'awesome'

  if newState.level is 8 and newState.team is 'ALIENS'
    console.log newState.updated, "Portal #{newState.title} is L#{newState.level} #{newState.team}"
    state.state = 'bad'

  if newState.level is 8 and newState.team is 'NEUTRAL'
    console.log newState.updated, "Portal #{newState.title} (#{newState.team}) is L#{newState.level} and has disco"
    state.state = 'disco'
    return state
  
  if newState.mods?.length
    # Check if we have "special" mods for triggering disco mode
    specialMods = false
    for mod in newState.mods
      if mod.type is 'Link Amp' and mod.rarity is 'Very Rare'
        specialMods = true
      if mod.type is 'SoftBank Ultra Link' and mod.rarity is 'Very Rare'
        specialMods = true
    if specialMods
      console.log newState.updated, "Portal #{newState.title} has special disco mods"
      state.state = 'disco'

  if newState.level > 8
    console.log newState.updated, "Portal #{newState.title} (#{newState.team}) plays calvinball"
    state.state = 'calvinball'
    return state

  previous = previousStates[newState.guid]
  unless previous
    console.log newState.updated, "Portal #{newState.title} is L#{newState.level} #{newState.team}"
    return state

  # We have a previous state to compare with

  if newState.team isnt previous.team
    console.log newState.updated, "Portal #{newState.title} switched from #{previous.team} to #{newState.team}"
    state.state = 'ownerchange'
    return state

  if newState.level > previous.level and newState.level isnt 8
    console.log newState.updated, "Portal #{newState.title} (#{newState.team}) upgraded"
    state.state = 'upgraded'
    return state

  if newState.level < previous.level or newState.health < previous.health
    console.log newState.updated, "Portal #{newState.title} (#{newState.team}) under attack"
    state.state = 'attack'
    return state

  return state
