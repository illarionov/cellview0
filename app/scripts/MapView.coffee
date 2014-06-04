define [
  'jquery'
  'leaflet',
  'leaflet-sidebar',
  'Constants',
  'CoverageLayer',
  'PointInfoPopup',
  'spinjs'
  'leaflet-spin'
], ($, L, leafletSidebar, Constants, CoverageLayer, PointInfoPopup, Spinner, LeafletSpin) ->
  "use strict"
  class MapView

    constructor: ->
      window.Spinner = Spinner

      @_formControllerReq = {}
      @_currentCell = null

      @leafletMap = L.map "map", {
        center: Constants.MAP_DEFAULT_CENTER,
        zoom: Constants.MAP_DEFAULT_ZOOM
      }

      @_initMainLayers()
      @_initCoverageLayer()
      @_initCoverageHullLayer()
      @_initOpenCellIdLayer()
      @_initYandexLayer()
      @_initMozillaLayer()
      @_initGoogleLayer()
      @_initSidebar()
      @_initLegend()
      @_initLayerControl()
      @_pointInfoPopup = new PointInfoPopup(this)

    spin: (doSpin) ->
      @leafletMap.spin(doSpin,
        top: '80%'
        left: '45%'
      )

    setFormControllerRequest: (request) ->
      @_formControllerReq = request
      @_updateCoverage()
      @_updateCoverageContour()

    setCurrentCell: (cell) ->
      @_currentCell = cell
      @_updateOpenCellIdLayer()
      @_updateYandexLayer()
      @_updateMozillaLayer()
      @_updateGoogleLayer()

    _updateCoverage: () ->
      coverageData = []
      @spin true
      $.ajax
        dataType: "json"
        url: Constants.API_COVERAGE_URL
        data: @_formControllerReq
        success: (data, textStatus, jqXHR) ->
          coverageData = data
        error: (jqXHR, textStatus, errorThrown) ->
          alert(textStatus)
        complete: =>
          @spin(false)
          @coverageLayer.setData coverageData
      return

    _updateCoverageContour: ->
      if not @leafletMap.hasLayer @coverageHullLayer
        @coverageHullLayer.clearLayers()
        return

      hullData=null
      @spin true
      $.ajax
        dataType: "json"
        url: Constants.API_COVERAGE_HULL_URL
        data: @_formControllerReq
        success: (data, textStatus, jqXHR) ->
          hullData = data
        error: (jqXHR, textStatus, errorThrown) ->
          if not (jqXHR.status == 200 and jqXHR.responseText == "")
            alert(textStatus)
        complete: =>
          @spin(false)
          @coverageHullLayer.clearLayers()
          @coverageHullLayer.addData hullData if hullData
      return

    _updateOpenCellIdLayer: ->
      if not @leafletMap.hasLayer(@openCellIdLayer) or not @_currentCell
        @openCellIdLayer.clearLayers()
        return
      req =
        mcc: @_currentCell['mcc']
        mnc: @_currentCell['mnc']
        lac: @_currentCell['lac']
        cellid: @_currentCell['cid']
        key: Constants.OPEN_CELL_ID_API_KEY

      response = null
      @spin true
      @openCellIdLayer.clearLayers()
      $.ajax
        dataType: "xml"
        url: Constants.OPEN_CELL_ID_API_GET_CELL_URL
        data: req
        success: (data, textStatus, jqXHR) ->
          response = data
        error: (jqXHR, textStatus, errorThrown) ->
          alert(textStatus)
        complete: =>
          @spin(false)

          if response? and $(response).find('rsp')?
            rsp = $(response).find('rsp').get()
            rsp = $(rsp)
            if rsp.attr('stat')? and rsp.attr('stat') == 'ok'
              cell = rsp.find('cell')
              lat = parseFloat(cell.attr('lat'))
              lon = parseFloat(cell.attr('lon'))
              marker = new L.marker([lat, lon],
                icon: new L.icon(
                  iconUrl: 'images/marker-opencellid.png'
                  iconSize: [30, 40]
                  iconAnchor: [15, 39]
                  popupAnchor: [0, -40]
                )
              )
              desc = []
              for attr in cell[0].attributes
                desc.push "<b>#{attr.name}:</b>&nbsp;#{attr.value}"

              marker.bindPopup("<h5>OpenCellID</h5>" + desc.join("<br/>"))

              @openCellIdLayer.addLayer marker

    _updateYandexLayer: ->
      if not @leafletMap.hasLayer(@yandexLayer) or not @_currentCell
        @yandexLayer.clearLayers()
        return
      req =
        mcc: @_currentCell['mcc']
        mnc: @_currentCell['mnc']
        lac: @_currentCell['lac']
        cid: @_currentCell['cid']
      response = null
      @spin true
      @yandexLayer.clearLayers()
      $.ajax
        dataType: "json"
        url: Constants.API_YANDEX_CELL_ID_URL
        data: req
        success: (data, textStatus, jqXHR) ->
          response = data
        complete: =>
          @spin(false)
          if response?
            marker = new L.marker([response['lat'], response['lon']],
              icon: new L.icon(
                iconUrl: 'images/marker-yandex.png'
                iconSize: [30, 34]
                iconAnchor: [8, 33]
                popupAnchor: [0, -30]
              )
            )
            marker.bindPopup("<h5>Yandex</h5>")
            @yandexLayer.addLayer marker

    _updateMozillaLayer: ->
      if not @leafletMap.hasLayer(@mozillaLayer) or not @_currentCell
        @mozillaLayer.clearLayers()
        return
      req =
        mcc: @_currentCell['mcc']
        mnc: @_currentCell['mnc']
        lac: @_currentCell['lac']
        cid: @_currentCell['cid']
        network_radio: @_currentCell['radio']
      response = null
      @spin true
      @mozillaLayer.clearLayers()
      $.ajax
        dataType: "json"
        url: Constants.API_MOZILLA_CELL_ID_URL
        data: req
        success: (data, textStatus, jqXHR) ->
          response = data
        complete: =>
          @spin(false)
          if response?
            marker = new L.marker([response['lat'], response['lon']],
              icon: new L.icon(
                iconUrl: 'images/marker-mozilla.png'
                iconSize: [40, 40]
                iconAnchor: [18, 38]
                popupAnchor: [0, -40]
              )
            )
            marker.bindPopup("<h5>Mozilla location service</h5>")
            @mozillaLayer.addLayer marker

    _updateGoogleLayer: ->
      if not @leafletMap.hasLayer(@googleLayer) or not @_currentCell
        @googleLayer.clearLayers()
        return
      req =
        mcc: @_currentCell['mcc']
        mnc: @_currentCell['mnc']
        lac: @_currentCell['lac']
        cid: @_currentCell['cid']
      response = null
      @spin true
      @googleLayer.clearLayers()
      $.ajax
        dataType: "json"
        url: Constants.API_GOOGLE_CELL_ID_URL
        data: req
        success: (data, textStatus, jqXHR) ->
          response = data
        complete: =>
          @spin(false)
          if response?
            marker = new L.marker([response['lat'], response['lon']],
              icon: new L.icon(
                iconUrl: 'images/marker-google.png'
                iconSize: [22, 40]
                iconAnchor: [11, 40]
                popupAnchor: [0, -40]
              )
            )
            marker.bindPopup("<h5>Google cell location</h5>")
            @googleLayer.addLayer marker

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

    _initOpenCellIdLayer: ->
      @openCellIdLayer = new L.LayerGroup()
      @openCellIdLayer.getAttribution = ->
        '<a href="http://opencellid.org/">OpenCellID</a> Database CC-BY-SA 3.0'
      @openCellIdLayer.addTo(@leafletMap)

    _initYandexLayer: ->
      @yandexLayer = new L.LayerGroup()
      @yandexLayer.getAttribution = ->
        '<a href="http://yandex.ru/">Yandex</a> Database'
      @yandexLayer.addTo(@leafletMap)

    _initMozillaLayer: ->
      @mozillaLayer = new L.LayerGroup()
      @mozillaLayer.getAttribution = ->
        '<a href="https://location.services.mozilla.com/">Mozilla</a> location service'
      #@mozillaLayer.addTo(@leafletMap)

    _initGoogleLayer: ->
      @googleLayer = new L.LayerGroup()
      @googleLayer.getAttribution = ->
        '<a href="https://google.com">Google</a> location'
      @googleLayer.addTo(@leafletMap)

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
        'OpenCellID cell marker': @openCellIdLayer
        'Yandex cell marker': @yandexLayer
        'Mozilla location service cell marker': @mozillaLayer
        'Google cell location': @googleLayer

      @layerControl = L.control.layers(mainLayers, optionalLayers)
      @layerControl.addTo(@leafletMap)

      @leafletMap.on 'overlayadd', (event) ->
        if @coverageHullLayer == event.layer
          @_updateCoverageContour()
        else if @openCellIdLayer == event.layer
          @_updateOpenCellIdLayer()
        else if @yandexLayer == event.layer
          @_updateYandexLayer()
        else if @mozillaLayer == event.layer
          @_updateMozillaLayer()
        else if @googleLayer == event.layer
          @_updateGoogleLayer()
      , this

  return MapView