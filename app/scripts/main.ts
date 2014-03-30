/// <reference path="types/dt-jquery2/jquery.d.ts" />
/// <reference path="types/leaflet/leaflet.d.ts" />
"use strict";

class Main {
    private static MAPBOX_API_KEY = 'lsillarionov.ghk4pdd0';
    private static MAPBOX_LAYER_URI = 'http://api.tiles.mapbox.com/v3/' + Main.MAPBOX_API_KEY + '/{z}/{x}/{y}.png';
    private static MAP_DEFAULT_CENTER = [56.1130, 47.2714];
    private static MAP_DEFAULT_ZOOM = 11;

    constructor(L) {

        /* create leaflet map */
        var map = L.map('map', {
            center: Main.MAP_DEFAULT_CENTER,
            zoom: Main.MAP_DEFAULT_ZOOM
        });

        /* add default stamen tile layer */
        new L.tileLayer(Main.MAPBOX_LAYER_URI, {
            minZoom: 0,
            maxZoom: 18,
            attribution: 'Map data © <a href="http://www.openstreetmap.org">OpenStreetMap contributors</a>'
        }).addTo(map);

        var sidebar = L.control.sidebar('sidebar', {
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
    }

}

new Main(L);