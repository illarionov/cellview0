define [
    'Constants',
    'CellsFormController'
    'MapView',
    'jquery',
    'underscore',
    'leaflet',
    'bootflat'
    'jquery-deparam'
  ], (Constants, CellsFormController, MapView, $, _, L, Bootflat, jqDeparam) ->
  "use strict"
  class Application
    constructor: ->
      @mapView = new MapView()
      $(".nav .btn_toggle_sidebar:first").click => @mapView.sidebar.toggle()

      @formController = new CellsFormController($("#sidebar"))
      @formController.setOnFormChangedListener (controller) => @onFormControllerChanged(controller)
      @formController.setOnDataLoadedListener (controller) =>
        controller.setRequestHash(@getRequestHashFromLocationHref())
        @onFormControllerChanged(controller)
        setTimeout( =>
          @mapView.sidebar.show()
        , 100)
        this

      @formController.loadData()

    getRequestHashFromLocationHref: ->
      hash = window.location.hash
      if (hash.indexOf('#') == 0) then hash = hash.substr(1)

      h = jqDeparam(hash)
      if _.isEmpty(h) then h = Constants.DEFAULT_COVERAGE_FORM
      return h

    onFormControllerChanged: (controller) ->
      reqHash = controller.getRequestHash()
      $(".cells-form-value:first").html controller.getDescription()
      @mapView.updateCoverage(reqHash)
      @updateLinkXintRu(reqHash)
      @updateCellDescription(reqHash)
      window.location.hash = '#' + $.param(reqHash)
      this

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
      return

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
