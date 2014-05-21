#
# (c) 2014, Alexey Illarionov
#
# (c) 2014, Vladimir Agafonkin
# Leaflet.heat, a tiny and fast heatmap plugin for Leaflet.
# https://github.com/Leaflet/Leaflet.heat
#
define [
  'leaflet',
  'quadtree',
  'SignalGradient',
], (L, QuadTree, SignalGradient) ->
  "use strict"
  class CoverageLayer extends L.Class
    constructor: ->
      @defaultGridSize = 51
      @_canvas =  null
      @_frame =  null
      @_map = null
      @signalGradient = new SignalGradient()
      @_setData([])

    initialize: (options, data=[])->
      @_setData data
      L.setOptions(this, options)

    setData: (data=[]) ->
      @_setData data
      @redraw()

    redraw: ->
      if (@_canvas && !@_frame && !@_map._animating)
        @_frame = L.Util.requestAnimFrame(@_redraw, this)
      this

    addTo: (map) ->
      map.addLayer this
      this

    onAdd: (map) ->
      @_map = map
      @_initCanvas() if not @_canvas
      map._panes.overlayPane.appendChild(@_canvas)
      map.on('moveend', @_reset, this)
      if map.options.zoomAnimation && L.Browser.any3d
        map.on('zoomanim', @_animateZoom, this)
      @_reset()
      this

    onRemove: (map) ->
      map.getPanes().overlayPane.removeChild(this._canvas)
      map.off('moveend', @_reset, this)
      if (map.options.zoomAnimation)
        map.off('zoomanim', @_animateZoom, this)
      this

    _initCanvas: ->
      @_canvas = L.DomUtil.create('canvas', 'leaflet-coverage-layer leaflet-layer')
      size = @_map.getSize()
      @_canvas.width = size.x
      @_canvas.height = size.y
      if @_map.options.zoomAnimation && L.Browser.any3d
        L.DomUtil.addClass(@_canvas, 'leaflet-zoom-animated')
      else
        L.DomUtil.addClass(@_canvas, 'leaflet-zoom-hide')
      this

    _reset: ->
      topLeft = @_map.containerPointToLayerPoint([0, 0])
      L.DomUtil.setPosition(@_canvas, topLeft)

      size = this._map.getSize()
      @_canvas.width = size.x
      @_canvas.height = size.y
      @_redraw()
      this

    _animateZoom: (e) ->
      scale = @_map.getZoomScale(e.zoom)
      offset = @_map._getCenterOffset(e.center)._multiplyBy(-scale).subtract(@_map._getMapPanePos())
      @_canvas.style[L.DomUtil.TRANSFORM] = L.DomUtil.getTranslateString(offset) + " scale(#{scale})"
      this

    _setData: (data) ->
      dataBounds = new L.LatLngBounds(data)
      @_quad = new QuadTree(this._boundsToQuery(dataBounds), false, 6, 6)
      for point in data
        @_quad.insert
          x: point[1]
          y: point[0]
          sig: point[2]

    _boundsToQuery: (bounds) ->
      sw = bounds.getSouthWest()
      ne = bounds.getNorthEast()
      if not bounds.getSouthWest()
        x = y = 0
        width = height = 0.1
      else
        #XXX: wrong
        x = sw.lng
        y = sw.lat
        width = ne.lng - sw.lng
        height = ne.lat - sw.lat
      return {'x': x, 'y':y, 'width': width, 'height': height}

    _redraw: ->
      gridSize = @options?.gridSize || @defaultGridSize
      size = @_map.getSize()

      maxZoom = @options?.maxZoom
      maxZoom ?= @_map.getMaxZoom()
      v = 1 / Math.pow(2, Math.max(0, Math.min(maxZoom - this._map.getZoom(), 12)))
      gridSize = Math.ceil(v * gridSize)

      bounds = new L.LatLngBounds(
        @_map.containerPointToLatLng(L.point([-gridSize, -gridSize]))
        @_map.containerPointToLatLng(size.add([gridSize, gridSize])))

      ctx = @_canvas.getContext('2d')
      ctx.clearRect(0, 0, @_canvas.width, @_canvas.height)

      points = @_quad.retrieveInBounds(@_boundsToQuery(bounds))
      #points.sort (a,b) ->
      #  return a['sig'] - b['sig']

      if points.length > 0
        lastSignal = points[0]['sig']
      else
        lastSignal = 0
      ctx.fillStyle = @signalGradient.getColor(lastSignal)

      for qtP in points
        latLng = [qtP['y'], qtP['x']]
        continue if not bounds.contains(latLng)
        p = @_map.latLngToContainerPoint(latLng)
        if lastSignal != qtP['sig']
          lastSignal = qtP['sig']
          ctx.fillStyle = @signalGradient.getColor(lastSignal)
        ctx.fillRect(p.x-gridSize/2, p.y-gridSize/2, gridSize, gridSize)

      @_frame = null
