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
        @updateCoverageLayer(controller.getRequestHash(), controller.getDescription())
        this

      @formController.setOnDataLoadedListener (controller) =>
        controller.setRequestHash(Constants.DEFAULT_COVERAGE_FORM)
        @updateCoverageLayer(controller.getRequestHash(), controller.getDescription())
        setTimeout( =>
          @mapView.sidebar.show()
        , 100)
        this

      @formController.loadData()

    updateCoverageLayer: (request, description) ->
      @mapView.spin true
      $(".description:first").text description
      coverageData = []
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

  $ ->
    app = new Application()
  this
