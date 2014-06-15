define [
  'jquery'
  'leaflet',
  'MapView',
  'SignalGradient',
  'Constants',
], ($, L, MapView, SignalGradient, Constants) ->
  "use strict"
  class PointInfoPopup
    constructor: (mapView) ->
      @_mapView = mapView
      @_xhrRequest = null
      @_popup = null
      @_cellInfotemplate = _.template($("script.popup_cells_at_point_template").html())
      @_formControllerReq = {}
      mapView.leafletMap.on 'click', @_onClick, this
      mapView.leafletMap.on 'popupclose', @_onPopupClose, this


    setFormControllerRequest: (request) ->
      @_formControllerReq = request
      if @_popup?
        latlng = @_popup.getLatLng()
        @_abortXhrRequest()
        @_closePopup()
        @_startLoad(latlng)

    _onClick: (event) ->
      isCancelLoad = @_isShownOrLoading()
      @_abortXhrRequest()
      @_closePopup()
      if not isCancelLoad
        @_startLoad(event.latlng)

    _startLoad: (latlng) ->
      @_mapView.spin true
      cells = []
      req = _.clone(@_formControllerReq)
      req.lat = latlng.lat
      req.lon = latlng.lng
      @_xhrRequest = $.ajax
        dataType: "json"
        url: Constants.API_MAP_POINT_INFO_URL
        data: req
        success: (data, textStatus, jqXHR) ->
          cells = data
        error: (jqXHR, textStatus, errorThrown) =>
          alert(textStatus)
          @_closePopup()
        complete: (jqXHR, textStatus) =>
          @_mapView.spin false
          @_xhrRequest = null
          @_showPopup(latlng, cells)
      this

    _isShownOrLoading: ->
      return @_xhrRequest? or @_popup?

    _onPopupClose: (event) ->
      if event.popup == @_popup then @_popup = null

    _abortXhrRequest: ->
      if @_xhrRequest? and @_xhrRequest.readyState != 4
        @_xhrRequest.abort()

    _closePopup: ->
      if @_popup?
        @_mapView.leafletMap.closePopup @_popup
        @_popup = null

    _showPopup: (latLng, data) ->
      sg = new SignalGradient()
      cell['signal_color'] = sg.getColor(cell['signal']) for cell in data
      templateContext =
        listTitle: "#{latLng.lat}, #{latLng.lng}"
        cells: data

      @_popup = (new L.popup(
        maxWidth: 500
        maxHeight: 400
        minWidth: 400
        closeOnClick: false
      ))
        .setLatLng(latLng)
        .setContent(@_cellInfotemplate(templateContext))
        .openOn(@_mapView.leafletMap)