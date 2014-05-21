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

      @leafletMap = L.map "map", {
        center: Constants.MAP_DEFAULT_CENTER,
        zoom: Constants.MAP_DEFAULT_ZOOM
      }

      @_initMainLayers()
      @_initCoverageLayer()
      @_initCoverageHullLayer()
      @_initSidebar()
      @_initLegend()

    spin: (doSpin) ->
      @leafletMap.spin(doSpin,
        top: '80%'
        left: '45%'
      )

    _initMainLayers: ->
      new L.tileLayer(Constants.MAPBOX_LAYER_URI, {
        minZoom: 0,
        maxZoom: 18,
        attribution: 'Map data © <a href="http://www.openstreetmap.org">OpenStreetMap contributors</a>'
      }).addTo(@leafletMap)

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


  return MapView