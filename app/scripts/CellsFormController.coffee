define [
  'jquery'
  'leaflet',
  'leaflet-sidebar',
  'Constants',
  'CellsFormSelect'
], ($, L, leafletSidebar, Constants, CellsFormSelect) ->
  "use strict"
  class CellsFormController
    constructor: (rootDiv) ->
      throw new Error("rootDiv undefined") if not rootDiv?
      @cells = []
      @listeners = []
      @rootDiv = rootDiv
      @selectMcc = new CellsFormSelect $(rootDiv).find '#select_mcc'
      @selectMnc = new CellsFormSelect $(rootDiv).find '#select_mnc'
      @selectRadio = new CellsFormSelect $(rootDiv).find '#select_radio'
      @selectLac = new CellsFormSelect $(rootDiv).find '#select_lac'
      @selectRnc = new CellsFormSelect $(rootDiv).find '#select_rnc'
      @selectPsc = new CellsFormSelect $(rootDiv).find '#select_psc'
      @selectCid = new CellsFormSelect $(rootDiv).find '#select_cid'
      @selectElements = $(rootDiv).find '.form-control'
      @selectElements.change @_onSelectionChanged

    loadData: ->
      $.ajax
        dataType: "json"
        url: @_getCellListUrl()
        success: (data, textStatus, jqXHR) =>
          @cells = data
        error: (jqXHR, textStatus, errorThrown) ->
          alert(textStatus)
        complete: (jqXHR, textStatus) =>
          @_refresh()
          @_notifyDataLoaded() if textStatus == "success" || textStatus == "notmodified"

    setOnFormChangedListener: (listener) ->
      @listeners.push { 'cb': listener, 'item': 'onFormChanged' }

    setOnDataLoadedListener: (listener) ->
      @listeners.push { 'cb': listener, 'item': 'onDataLoaded' }

    getRequestHash: ->
      h = {}
      h['mcc'] = @selectMcc.getSelectedVal() if @selectMcc.getSelectedVal()
      h['mnc'] = @selectMnc.getSelectedVal() if @selectMnc.getSelectedVal()
      h['network_radio'] = @selectRadio.getSelectedVal() if @selectRadio.getSelectedVal()
      h['lac'] = @selectLac.getSelectedVal() if @selectLac.getSelectedVal()
      h['rnc'] = @selectRnc.getSelectedVal() if @selectRnc.getSelectedVal()
      h['psc'] = @selectPsc.getSelectedVal() if @selectPsc.getSelectedVal()
      h['cid'] = @selectCid.getSelectedVal() if @selectCid.getSelectedVal()
      h

    getDescription: ->
      description = []
      mcc = @selectMcc.getSelectedVal()
      if mcc then description.push("mcc: " + CellsFormController.getMccDescription mcc)
      mnc = @selectMnc.getSelectedVal()
      if mnc then description.push("mnc: " + CellsFormController.getMncDescription mnc)
      radio = @selectRadio.getSelectedVal()
      if radio then description.push "radio: #{radio}"
      lac = @selectLac.getSelectedVal()
      if lac then description.push "lac: #{lac}"
      rnc = @selectRnc.getSelectedVal()
      if rnc then description.push "rnc: #{rnc}"
      psc = @selectPsc.getSelectedVal()
      if psc then description.push "psc: #{psc}"
      cid = @selectCid.getSelectedVal()
      if cid then description.push "cid: #{cid}"
      description.join(', ')

    setRequestHash: (req) ->
      @selectMcc.setSelectedVal(req['mcc'])
      @selectMnc.setSelectedVal(req['mnc'])
      @selectRadio.setSelectedVal(req['network_radio'])
      @selectLac.setSelectedVal(req['lac'])
      @selectRnc.setSelectedVal(req['rnc'])
      @selectPsc.setSelectedVal(req['psc'])
      @selectCid.setSelectedVal(req['cid'])
      @_refresh()

    _onSelectionChanged : (eventObject) =>
      @_refresh()
      @_notifyOnFormChanged()

    _notifyOnFormChanged: ->
      listener.cb(this) for listener in @listeners when listener['item'] is 'onFormChanged'

    _notifyDataLoaded: ->
      listener.cb(this) for listener in @listeners when listener['item'] is 'onDataLoaded'

    _getCellListUrl: -> Constants.API_CELLS_URL

    _refresh: ->
      @_refreshMcc()
      @_refreshMnc()
      @_refreshRadio()
      @_refreshLac()
      @_refreshRnc()
      @_refreshPsc()
      @_refreshCid()

    _refreshMcc: ->
      mccHash =
        "": ""
      for cellInfo in @cells
        mcc = cellInfo['mcc']
        mccHash[mcc] = CellsFormController.getMccDescription mcc
      @selectMcc.set(mccHash)
      this

    _refreshMnc: ->
      mncHash =
        "": ""
      cells = @_grepMcc(@cells)
      for cellInfo in cells
        mnc = cellInfo['mnc']
        mncHash[mnc] = CellsFormController.getMncDescription mnc
      @selectMnc.set mncHash
      this

    _refreshRadio: ->
      radioHash =
        "": ""
      cells = @_grepMcc(@cells)
      cells = @_grepMnc(cells)
      for cellInfo in cells
        radio = cellInfo['radio']
        radioHash[radio] = radio

      @selectRadio.set radioHash
      this

    _refreshLac: ->
      lacHash =
        "": ""
      cells = @_grepMcc(@cells)
      cells = @_grepMnc(cells)
      cells = @_grepRadio(cells)
      for cellInfo in cells
        lac = cellInfo['lac']
        lacHash[lac] = lac

      @selectLac.set lacHash
      this

    _refreshRnc: ->
      rncHash =
        "": ""
      cells = @_grepMcc(@cells)
      cells = @_grepMnc(cells)
      cells = @_grepRadio(cells)
      cells = @_grepLac(cells)
      for cellInfo in cells
        cid = cellInfo['cid']
        if (cid >= 0x10000)
          rnc = cid >> 16
          rncHash[rnc] = rnc
      @selectRnc.set rncHash
      this

    _refreshPsc: ->
      pscHash =
        "": ""
      cells = @_grepMcc(@cells)
      cells = @_grepMnc(cells)
      cells = @_grepRadio(cells)
      cells = @_grepLac(cells)
      cells = @_grepRnc(cells)
      for cellInfo in cells
        psc = cellInfo['psc']
        pscHash[psc] = psc

      @selectPsc.set pscHash
      this

    _refreshCid: ->
      cidHash =
        "": ""
      cells = @_grepMcc(@cells)
      cells = @_grepMnc(cells)
      cells = @_grepRadio(cells)
      cells = @_grepLac(cells)
      cells = @_grepRnc(cells)
      cells = @_grepPsc(cells)
      for cellInfo in cells
        cid = cellInfo['cid']
        if (cid < 0x10000)
          cidHash[cid] = cid
        else
          rnc = cid >> 16
          newCid = cid & 0xffff
          cidHash[cid] = "#{cid} (RNC: #{rnc} CID: #{newCid})"

      @selectCid.set cidHash
      this

    @getMccDescription: (mcc) ->
      if Constants.MCC_NAMES[mcc]?
        return "#{mcc} #{Constants.MCC_NAMES[mcc]}"
      else
        return mcc

    @getMncDescription: (mnc) ->
      if Constants.MNC_NAMES[mnc]?
        return "#{mnc} #{Constants.MNC_NAMES[mnc]}"
      else
        return mnc

    _grepInt: (cells, name, val) ->
      if not cells
        throw new Error "cells not defined"
      if not val
        return cells
      valInt = parseInt(val)
      cellInfo for cellInfo in cells when cellInfo[name] is valInt

    _grepMcc: (cells) ->
      @_grepInt(cells, 'mcc', @selectMcc.getSelectedVal())

    _grepMnc: (cells) ->
      @_grepInt(cells, 'mnc', @selectMnc.getSelectedVal())

    _grepLac: (cells) ->
      @_grepInt(cells, 'lac', @selectLac.getSelectedVal())

    _grepPsc: (cells) ->
      @_grepInt(cells, 'psc', @selectPsc.getSelectedVal())

    _grepRadio: (cells) ->
      if not cells
        throw new Error "cells not defined"
      radio = @selectRadio.getSelectedVal()
      if not radio
        return cells
      cellInfo for cellInfo in cells when cellInfo['radio'] == radio

    _grepRnc: (cells) ->
      if not cells
        throw new Error "cells not defined"
      rnc = @selectRnc.getSelectedVal()
      if not rnc
        return cells
      rnc = parseInt(rnc)
      cellInfo for cellInfo in cells when cellInfo['cid'] >> 16 == rnc
