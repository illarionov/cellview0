define [], () ->
  "use strict"
  class SignalGradient
    DEFAULT_SIGNAL_MIN = -120

    DEFAULT_SIGNAL_MAX = -30

    DEFAULT_GRADIENT_STEPS = [
      'rgba(56, 56, 56, 0.4)'
      'rgba(100, 100, 100, 0.4)'
      'rgba(20, 10, 120, 0.4)'
      'rgba(0, 120, 240, 0.5)'
      'rgba(0, 120, 120, 0.6)'
      'rgba(0, 255, 0, 0.7)'
      'rgba(255, 255, 0, 0.9)'
      'rgba(255, 120, 20, 0.9)'
      'rgba(255, 0, 0, 1)'
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

    drawLegend: (canvasElement) ->
      ctx = canvasElement.getContext('2d')
      ctx.fillStyle='white'
      ctx.clearRect(0, 0, canvasElement.width, canvasElement.height)

      gradHeight = 10
      gradMarginLR = 10
      gradWidth = canvasElement.width - 2 * gradMarginLR
      ctx.beginPath()
      ctx.fillStyle = @_createLinearGradient(ctx, gradWidth, gradHeight)
      ctx.rect(gradMarginLR, 0, gradWidth, gradHeight)
      ctx.fill()

      #ctx.beginPath()
      #ctx.strokeStyle = '#333333'
      #ctx.lineWidth = 1
      #ctx.rect(gradMarginLR, 0, gradWidth, gradHeight)
      #ctx.stroke()

      ctx.textAlign = "center"
      ctx.textBaseline = "top"
      ctx.fillStyle = "#333333"
      ctx.strokeStyle = "#333333"
      ctx.lineWidth = 0.5
      ctx.font = 'normal 11px sans-serif';

      textDx = gradWidth /  @_gradientSteps.length
      signalDt = (@_signalMax - @_signalMin) / @_gradientSteps.length
      textY = gradHeight + 5
      for i in [0..@_gradientSteps.length]
        textX = gradMarginLR + textDx * i
        v = @_signalMin + Math.ceil(signalDt * i)
        @_drawTexLabel(ctx, v, textX, textY)


    _drawTexLabel: (ctx, label, x, y) ->
      ctx.fillText(label, x, y)
      ctx.beginPath()
      ctx.moveTo(x, y - 8)
      ctx.lineTo(x, y - 2)
      ctx.stroke()

    _recreateGradient: ->
      gradContainer = document.createElement('canvas')
      gradContainer.width = @_signalMax - @_signalMin
      gradContainer.height = 1
      ctx = gradContainer.getContext('2d')
      ctx.fillStyle = @_createLinearGradient(ctx, gradContainer.width, gradContainer.height)
      ctx.fillRect(0, 0, gradContainer.width, gradContainer.height)
      @_colorGradientData = ctx.getImageData(0, 0, gradContainer.width, gradContainer.height).data

    _createLinearGradient: (ctx, width, height) ->
      grad = ctx.createLinearGradient(0, 0, width, height)
      for i in [0..@_gradientSteps.length-1]
        grad.addColorStop(i / @_gradientSteps.length, @_gradientSteps[i])
      return grad