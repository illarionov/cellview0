define [
  'jquery'
  'leaflet',
  'leaflet-sidebar',
  'Constants',
  'CoverageLayer',
  'spinjs'
  'leaflet-spin'
], ($, L, leafletSidebar, Constants, CoverageLayer, Spinner, LeafletSpin) ->
  class MapView

    constructor: ->
      window.Spinner = Spinner
      @leafletMap = L.map "map", {
        center: Constants.MAP_DEFAULT_CENTER,
        zoom: Constants.MAP_DEFAULT_ZOOM
      }

      new L.tileLayer(Constants.MAPBOX_LAYER_URI, {
        minZoom: 0,
        maxZoom: 18,
        attribution: 'Map data © <a href="http://www.openstreetmap.org">OpenStreetMap contributors</a>'
      }).addTo(@leafletMap)

      @coverageLayer = new CoverageLayer()
      @coverageLayer.addTo(@leafletMap)

      @sidebar = L.control.sidebar('sidebar', {
        position: 'right',
        closeButton: true,
        autoPan: false
      })

      @leafletMap.addControl @sidebar

      $(".nav .btn_toggle_sidebar:first").click(() =>
        @sidebar.toggle()
      )

    spin: (doSpin) ->
      @leafletMap.spin(doSpin,
        top: '80%'
        left: '45%'
      )

  return MapView