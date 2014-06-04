define [
  'jquery'
  'leaflet',
  'MapView',
  'Constants',
], ($, L, MapView, Constants) ->
  "use strict"
  class PointInfoPopup
    constructor: (mapView) ->
      @_mapView = mapView
      @_xhrRequest = null
      @_popup = null
      mapView.leafletMap.on 'click', @_onClick, this
      mapView.leafletMap.on 'popupclose', @_onPopupClose, this


    _onClick: (event) ->
      isCancelLoad = @_xhrRequest? or @_popup?
      @_abortXhrRequest()
      @_closePopup()
      if isCancelLoad then return

      @_mapView.spin true
      @_xhrRequest = $.ajax
        dataType: "json"
        url: Constants.API_MAP_POINT_INFO_URL
        data:
          lat: event.latlng.lat
          lon: event.latlng.lng
        success: (data, textStatus, jqXHR) =>
          @_showPopup(event.latlng, data)
        error: (jqXHR, textStatus, errorThrown) =>
          alert(textStatus)
          @_closePopup()
        complete: (jqXHR, textStatus) =>
          @_mapView.spin false
          @_xhrRequest = null
          @_showPopup(event.latlng, {})
      this

    _onPopupClose: (event) ->
      if event.popup == @_popup then @_popup = null

    _abortXhrRequest: ->
      if @_xhrRequest? and @_xhrRequest.readyState != 4
        @_xhrRequest.abort()

    _closePopup: ->
      if @_popup?
        @_leafletMap.closePopup @_popup
        @_popup = null

    _showPopup: (latLng, data) ->
      @_popup = (new L.popup())
        .setLatLng(latLng)
        .setContent("<h5>df</h5>")
        .openOn(@_mapView.leafletMap)