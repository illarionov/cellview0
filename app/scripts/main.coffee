"use strict"

class CellViewMap

  MAPBOX_API_KEY = 'lsillarionov.ghk4pdd0';
  MAPBOX_LAYER_URI = 'http://api.tiles.mapbox.com/v3/' + MAPBOX_API_KEY + '/{z}/{x}/{y}.png';
  MAP_DEFAULT_CENTER = [56.1130, 47.2714];
  MAP_DEFAULT_ZOOM = 11;

  constructor: () ->
    @leaflet_map = L.map('map', {
      center: MAP_DEFAULT_CENTER,
      zoom: MAP_DEFAULT_ZOOM
    });

    new L.tileLayer(MAPBOX_LAYER_URI, {
      minZoom: 0,
      maxZoom: 18,
      attribution: 'Map data © <a href="http://www.openstreetmap.org">OpenStreetMap contributors</a>'
    }).addTo(@leaflet_map);

    @sidebar = L.control.sidebar('sidebar', {
      position: 'right',
      closeButton: true,
      autopan: false
    });

    @leaflet_map.addControl @sidebar

    setTimeout(() =>
      @sidebar.show()
    , 500)

    $(".nav .btn_toggle_sidebar:first").click(() =>
      @sidebar.toggle()
    )

cellViewMap = new CellViewMap









