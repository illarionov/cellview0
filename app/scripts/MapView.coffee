define [
  'jquery'
  'leaflet',
  'leaflet-sidebar',
  'Constants'
], ($, L, leafletSidebar, Constants) ->
  class MapView


    constructor: ->
      @leafletMap = L.map "map", {
        center: Constants.MAP_DEFAULT_CENTER,
        zoom: Constants.MAP_DEFAULT_ZOOM
      }

      new L.tileLayer(Constants.MAPBOX_LAYER_URI, {
        minZoom: 0,
        maxZoom: 18,
        attribution: 'Map data © <a href="http://www.openstreetmap.org">OpenStreetMap contributors</a>'
      }).addTo(@leafletMap)

      @sidebar = L.control.sidebar('sidebar', {
        position: 'right',
        closeButton: true,
        autopan: false
      })

      @leafletMap.addControl @sidebar

      setTimeout(=>
        @sidebar.show()
      , 500)

      $(".nav .btn_toggle_sidebar:first").click(() =>
        @sidebar.toggle()
      )
  return MapView