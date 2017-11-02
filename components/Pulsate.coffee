noflo = require 'noflo'

calculateStep = (step, maxSteps) ->
  # move value above 0
  adjust = 1
  # reduce value range between 1 and 0
  rangeAdjust = 2
  # Max RGB value
  maxValue = 100

  upperLimit = 0.5
  lowerLimit = 0

  # convert to percentage of time units
  percentage = (step * 100 / maxSteps) / 100

  # normalize to range between 1 and 0
  x = ((Math.sin(2 * Math.PI * percentage)) + adjust) / rangeAdjust

  # returns a value between UPPER_LIMIT and LOWER_LIMIT
  value = Math.max(lowerLimit, Math.min(x, upperLimit))

  # stretch to UPPER_LIMIT
  valueStretch = value / upperLimit

  return Math.floor Math.abs (valueStretch * maxValue)

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'rotate-right'
  c.description = 'Pulsate lights naturally'
  c.inPorts.add 'step',
    datatype: 'bang'
    description: 'Calculate the next cycle of the animation'
    required: yes
  c.inPorts.add 'colors',
    datatype: 'array'
    description: 'Colors to make pulsing'
    required: no
    control: yes
  c.outPorts.add 'colors',
    datatype: 'array'
    description: 'Current color values'
    required: yes
  c.tracks = [0, 70, 50, 15]
  c.maxSteps = 100
  c.tearDown = (callback) ->
    c.tracks = [0, 70, 50, 15]
    do callback
  c.process (input, output) ->
    return unless input.hasData 'step', 'colors'
    input.getData 'step'
    colors = input.getData 'colors'
    resultColors = []
    for step, idx in c.tracks
      ledColors = []
      for color in colors
        unless color
          # Light is off, no need to calculate
          ledColors.push 0
          continue
        ledColors.push calculateStep step, c.maxSteps
      resultColors.push ledColors
      c.tracks[idx]++
      if c.tracks[idx] > c.maxSteps
        c.tracks[idx] = 0
    output.sendDone
      colors: resultColors
