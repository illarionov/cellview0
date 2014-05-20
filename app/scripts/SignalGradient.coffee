define [], () ->
  class SignalGradient
    DEFAULT_SIGNAL_MIN = -120

    DEFAULT_SIGNAL_MAX = -40

    DEFAULT_GRADIENT_STEPS = [
      'rgba(56, 56, 56, 0.7)'
      'rgba(100, 100, 100, 0.7)'
      'rgba(20, 10, 120, 0.7)'
      'rgba(0, 120, 240, 0.7)'
      'rgba(0, 255, 0, 0.7)'
      'rgba(255, 255, 0, 0.7)'
      'rgba(255, 120, 20, 0.7)'
      'rgba(255, 0, 0, 0.7)'
    ]

    constructor: ->
      @setSignalGradient(DEFAULT_SIGNAL_MIN, DEFAULT_SIGNAL_MAX, DEFAULT_GRADIENT_STEPS)

    setSignalRange: (min, max) ->
      @setSignalGradient(min, max, @_gradientSteps)

    setSignalGradient: (min, max, steps) ->
      if min >= max then throw new Error("min >= max")
      if not steps or steps.length == 0 then throw new Error("no steps")
      @_signalMin = min
      @_signalMax = max
      @_gradientSteps = steps
      @_recreateGradient()

    getColor: (signal)  ->
      if signal < @_signalMin then return @_gradientSteps[0]
      if signal > @_signalMax then return @_gradientSteps[@_gradientSteps.length - 1]
      idx = 4 * (signal - @_signalMin)
      cgd = @_colorGradientData
      return "rgba(#{cgd[idx]},#{cgd[idx+1]},#{cgd[idx+2]},#{cgd[idx+3]/255.0})"

    _recreateGradient: ->
      gradContainer = document.createElement('canvas')
      gradContainer.width = @_signalMax - @_signalMin
      gradContainer.height = 1
      ctx = gradContainer.getContext('2d')
      grad = ctx.createLinearGradient(0, 0, gradContainer.width, gradContainer.height)

      for i in [0..@_gradientSteps.length-1]
        grad.addColorStop(i / @_gradientSteps.length, @_gradientSteps[i])

      ctx.fillStyle = grad
      ctx.fillRect(0, 0, gradContainer.width, gradContainer.height)
      @_colorGradientData = ctx.getImageData(0, 0, gradContainer.width, gradContainer.height).data