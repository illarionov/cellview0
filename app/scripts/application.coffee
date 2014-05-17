define [
    'Constants',
    'CellsFormController'
    'MapView',
    'jquery',
    'leaflet'
  ], (Constants, CellsFormController, MapView, $, L) ->
  'use strict'
  $ ->
    mv = new MapView()
    formController = new CellsFormController($("#sidebar"))

    formController.setOnFormChangedListener (controller) ->
      description = controller.getDescription()
      $(".description:first").text description
      this

    formController.loadData()
  this
