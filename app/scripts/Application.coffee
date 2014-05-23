define [
    'Constants',
    'CellsFormController'
    'MapView',
    'jquery',
    'underscore',
    'leaflet',
    'bootflat'
  ], (Constants, CellsFormController, MapView, $, _, L, Bootflat) ->
  "use strict"
  class Application
    constructor: ->
      @mapView = new MapView()
      $(".nav .btn_toggle_sidebar:first").click => @mapView.sidebar.toggle()

      @formController = new CellsFormController($("#sidebar"))
      @formController.setOnFormChangedListener (controller) =>
        reqHash = controller.getRequestHash()
        @updateCoverage(reqHash, controller.getDescription())
        @updateLinkXintRu(reqHash)
        @updateCellDescription(reqHash)
        this

      @formController.setOnDataLoadedListener (controller) =>
        controller.setRequestHash(Constants.DEFAULT_COVERAGE_FORM)
        reqHash = controller.getRequestHash()
        @updateCoverage(reqHash, controller.getDescription())
        @updateLinkXintRu(reqHash)
        @updateCellDescription(reqHash)
        setTimeout( =>
          @mapView.sidebar.show()
        , 100)
        this

      @formController.loadData()

    updateCoverage: (request, description) ->
      @mapView.spin true
      $(".cells-form-value:first").html description
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
        cell = @_getCell(req)
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

    updateCellDescription: (req) ->
      description = ""
      cell = @_getCell(req)
      if cell
        h = []
        mainKeys = ['mcc', 'mnc', 'radio', 'lac', 'psc', 'cid']
        additionalKeys = _.chain(cell).keys().difference(mainKeys).value().sort()

        for k in mainKeys.concat(additionalKeys)
          h.push "<b>#{k}:</b>&nbsp;" + _.escape(cell[k])
        description = h.join(", ")
      $('.cell-description:first').html(description)

    _getCell: (req) ->
      return if not req['cid']?
      cells = @formController.getCells req
      return _.find(cells, (cell) ->
        return cell['mcc']? and cell['mnc']? and cell['lac']? and cell['cid']?
      )


  $ ->
    app = new Application()
  this
