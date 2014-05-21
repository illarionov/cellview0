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
        this

      @formController.setOnDataLoadedListener (controller) =>
        controller.setRequestHash(Constants.DEFAULT_COVERAGE_FORM)
        @updateCoverage(controller.getRequestHash(), controller.getDescription())
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

  $ ->
    app = new Application()
  this
