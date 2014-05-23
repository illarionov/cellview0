define [
  'jquery'
  'leaflet',
  'leaflet-sidebar',
  'Constants',
  'CoverageLayer',
  'spinjs'
  'leaflet-spin'
], ($, L, leafletSidebar, Constants, CoverageLayer, Spinner, LeafletSpin) ->
  "use strict"
  class MapView

    constructor: ->
      window.Spinner = Spinner

      @coverageRequest = {}

      @leafletMap = L.map "map", {
        center: Constants.MAP_DEFAULT_CENTER,
        zoom: Constants.MAP_DEFAULT_ZOOM
      }

      @_initMainLayers()
      @_initCoverageLayer()
      @_initCoverageHullLayer()
      @_initSidebar()
      @_initLegend()
      @_initLayerControl()

    spin: (doSpin) ->
      @leafletMap.spin(doSpin,
        top: '80%'
        left: '45%'
      )

    updateCoverage: (request) ->
      @coverageRequest = request
      coverageData = []
      @spin true
      $.ajax
        dataType: "json"
        url: Constants.API_COVERAGE_URL
        data: @coverageRequest
        success: (data, textStatus, jqXHR) ->
          coverageData = data
        error: (jqXHR, textStatus, errorThrown) ->
          alert(textStatus)
        complete: =>
          @spin(false)
          @coverageLayer.setData coverageData
      @_updateCoverageContour()
      return

    _updateCoverageContour: () ->
      if not @leafletMap.hasLayer @coverageHullLayer
        @coverageHullLayer.clearLayers()
        return

      hullData=null
      @spin true
      $.ajax
        dataType: "json"
        url: Constants.API_COVERAGE_HULL_URL
        data: @coverageRequest
        success: (data, textStatus, jqXHR) ->
          hullData = data
        error: (jqXHR, textStatus, errorThrown) ->
          alert(textStatus)
        complete: =>
          @spin(false)
          @coverageHullLayer.clearLayers()
          @coverageHullLayer.addData hullData if hullData
      return

    _initMainLayers: ->
      @mainLayer = new L.tileLayer(Constants.MAP_MAIN_LAYER, {
        minZoom: 0,
        maxZoom: 18,
        attribution: Constants.MAP_MAIN_LAYER_ATTRIBUTION
      })
      @mainLayer.addTo(@leafletMap)

    _initCoverageLayer: ->
      @coverageLayer = new CoverageLayer()
      @coverageLayer.addTo @leafletMap

    _initCoverageHullLayer: ->
      @coverageHullLayer = new L.geoJson([],
        style:
          color: 'rgba(60,60,60,0.7)'
          fill: false
          weight: 4
          clickable: false
      )

      @coverageHullLayer.addTo @leafletMap

    _initSidebar: ->
      @sidebar = L.control.sidebar('sidebar', {
        position: 'right',
        closeButton: true,
        autoPan: false
      })
      @leafletMap.addControl @sidebar

    _initLegend: ->
      @legend = L.control(
        position: 'bottomleft'
      )
      @legend.onAdd = (map) ->
        this._canvas = L.DomUtil.create('canvas', 'info legend')
        #XXX: css
        this._canvas.width = 350
        this._canvas.height = 25

        this.update()
        return this._canvas
      @legend.update = (props) =>
        @coverageLayer.signalGradient.drawLegend(@legend._canvas)
      @legend.addTo(@leafletMap)

    _initLayerControl: ->
      mainLayers = {}
      mainLayers[Constants.MAP_MAIN_LAYER_NAME] = @mainLayer

      optionalLayers =
        'Coverage contour': @coverageHullLayer

      @layerControl = L.control.layers(mainLayers, optionalLayers)
      @layerControl.addTo(@leafletMap)

      @leafletMap.on 'overlayadd', (event) =>
        if @coverageHullLayer == event.layer
          @_updateCoverageContour()


  return MapView