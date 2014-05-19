define [
    'Constants',
    'CellsFormController'
    'MapView',
    'jquery',
    'leaflet'
  ], (Constants, CellsFormController, MapView, $, L) ->
  'use strict'
  class Application
    constructor: ->
      @mapView = new MapView()
      @formController = new CellsFormController($("#sidebar"))
      @formController.setOnFormChangedListener (controller) =>
        description = controller.getDescription()
        $(".description:first").text description
        @updateCoverageLayer controller.getRequestHash()
        this

      @formController.loadData()
      #XXX: default url
      # @updateCoverageLayer({})

    updateCoverageLayer: (request) ->
      $.ajax
        dataType: "json"
        url: Constants.API_COVERAGE_URL
        data: request
        success: (data, textStatus, jqXHR) =>
          @mapView.coverageLayer.setData data
        error: (jqXHR, textStatus, errorThrown) ->
          alert(textStatus)

  $ ->
    app = new Application()
  this
