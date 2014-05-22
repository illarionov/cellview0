define [
    'Constants',
    'CellsFormController'
    'MapView',
    'jquery',
    'leaflet'
  ], (Constants, CellsFormController, MapView, $, L) ->
  "use strict"
  class Application
    constructor: ->
      @mapView = new MapView()
      $(".nav .btn_toggle_sidebar:first").click => @mapView.sidebar.toggle()

      @formController = new CellsFormController($("#sidebar"))
      @formController.setOnFormChangedListener (controller) =>
        @updateCoverage(controller.getRequestHash(), controller.getDescription())
        @updateLinkXintRu(controller.getRequestHash())
        this

      @formController.setOnDataLoadedListener (controller) =>
        controller.setRequestHash(Constants.DEFAULT_COVERAGE_FORM)
        @updateCoverage(controller.getRequestHash(), controller.getDescription())
        @updateLinkXintRu(controller.getRequestHash())
        setTimeout( =>
          @mapView.sidebar.show()
        , 100)
        this

      @formController.loadData()

    updateCoverage: (request, description) ->
      @mapView.spin true
      $(".description:first").text description
      coverageData = []
      hullData=null
      $.ajax
        dataType: "json"
        url: Constants.API_COVERAGE_URL
        data: request
        success: (data, textStatus, jqXHR) ->
          coverageData = data
        error: (jqXHR, textStatus, errorThrown) ->
          alert(textStatus)
        complete: =>
          @mapView.spin(false)
          @mapView.coverageLayer.setData coverageData

      @mapView.spin true
      $.ajax
        dataType: "json"
        url: Constants.API_COVERAGE_HULL_URL
        data: request
        success: (data, textStatus, jqXHR) ->
          hullData = data
        error: (jqXHR, textStatus, errorThrown) ->
          alert(textStatus)
        complete: =>
          @mapView.spin(false)
          @mapView.coverageHullLayer.clearLayers()
          @mapView.coverageHullLayer.addData hullData if hullData

    updateLinkXintRu: (req) ->
      link = ""
      if req['cid']
        cells = @formController.getCells req
        cell = null
        for cellInfo in cells
          if cellInfo['mcc'] and cellInfo['mnc'] and cellInfo['lac'] and cellInfo['cid']
            cell = cellInfo
            break
        if cell?
          xinitReq = {}
          xinitReq[p] = cell[p] for p in [ 'mcc','mnc','lac','cid']
          xinitReq['networkType'] = cell['radio'] if cell['radio']

          url = "http://xinit.ru/bs/#!?" + $.param(xinitReq)
          link = $('<a>',
            text: 'Cell info on xinit.ru'
            href: url
            target: '_blank'
          )
      $('.link-xinit-ru:first').html(link)

  $ ->
    app = new Application()
  this
