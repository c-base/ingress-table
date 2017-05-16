noflo = require 'noflo'

class Pulsate extends noflo.Component
  icon: 'rotate-right'
  description: 'Pulsate lights naturally'

  constructor: ->
    @value = 0
    @tracks = [0, 40, 30, 10]
    @maxSteps = 100
    @colors = [255, 255, 255]
    @inPorts = new noflo.InPorts
      step:
        datatype: 'bang'
        description: 'Calculate the next cycle of the animation'
        required: yes
      colors:
        datatype: 'array'
        description: 'Colors to make pulsing'
        required: no

    @outPorts = new noflo.OutPorts
      colors:
        datatype: 'array'
        description: 'Current color values'
        required: yes

    @inPorts.colors.on 'data', (@colors) =>
    @inPorts.step.on 'data', =>
      colors = []
      for step, idx in @tracks
        ledColors = []
        for color in @colors
          unless color
            ledColors.push 0
            continue
          ledColors.push @step step
        colors.push ledColors
        @tracks[idx]++
        if @tracks[idx] > @maxSteps
          @tracks[idx] = 0
      @outPorts.colors.send colors
    @inPorts.step.on 'disconnect', =>
      @outPorts.colors.disconnect()

  step: (step) ->
    # move value above 0
    adjust = 1
    # reduce value range between 1 and 0
    rangeAdjust = 2
    # Max RGB value
    maxValue = 100

    upperLimit = 0.5
    lowerLimit = 0

    # convert to percentage of time units
    percentage = (step * 100 / @maxSteps) / 100

    # normalize to range between 1 and 0
    x = ((Math.sin(2 * Math.PI * percentage)) + adjust) / rangeAdjust

    # returns a value between UPPER_LIMIT and LOWER_LIMIT
    value = Math.max(lowerLimit, Math.min(x, upperLimit))

    # stretch to UPPER_LIMIT
    valueStretch = value / upperLimit

    return Math.floor Math.abs (valueStretch * maxValue)

exports.getComponent = -> new Pulsate
