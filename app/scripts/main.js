(function (window, document, L, undefined) {
    'use strict';

    var MAPBOX_API_KEY = 'lsillarionov.ghk4pdd0';
    var MAPBOX_LAYER_URI = 'http://api.tiles.mapbox.com/v3/' + MAPBOX_API_KEY + '/{z}/{x}/{y}.png';
    var MAP_DEFAULT_CENTER = [56.1130, 47.2714];
    var MAP_DEFAULT_ZOOM = 11;

    var map, sidebar;

    /* create leaflet map */
    map = L.map('map', {
        center: MAP_DEFAULT_CENTER,
        zoom: MAP_DEFAULT_ZOOM
    });

    /* add default stamen tile layer */
    new L.tileLayer(MAPBOX_LAYER_URI, {
        minZoom: 0,
        maxZoom: 18,
        attribution: 'Map data © <a href="http://www.openstreetmap.org">OpenStreetMap contributors</a>'
    }).addTo(map);

    sidebar = L.control.sidebar('sidebar', {
        position: 'right',
        closeButton: true,
        autopan: false
    });
    map.addControl(sidebar);

    setTimeout(function () {
        sidebar.show();
    }, 500);

    $('.nav .btn_toggle_sidebar:first').click(function () {
        sidebar.toggle();
    });

}(window, document, L));