define [
  'jquery'
  'leaflet',
  'leaflet-sidebar',
  'Constants',
  'CellsFormSelect'
], ($, L, leafletSidebar, Constants, CellsFormSelect) ->
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
        complete: =>
          @_setStatusLoadingCellList(false)
          @_refresh()


    setOnFormChangedListener: (listener) ->
      @listeners.push listener

    getRequestHash: ->
      h = {}
      h['mcc'] = @selectMcc.selectedVal() if @selectMcc.selectedVal()
      h['mnc'] = @selectMnc.selectedVal() if @selectMnc.selectedVal()
      h['radio'] = @selectRadio.selectedVal() if @selectRadio.selectedVal()
      h['lac'] = @selectLac.selectedVal() if @selectLac.selectedVal()
      # XXX h['rnc'] = @selectRnc.selectedVal() if @selectRnc.selectedVal()
      h['psc'] = @selectPsc.selectedVal() if @selectPsc.selectedVal()
      h['cid'] = @selectCid.selectedVal() if @selectCid.selectedVal()
      h

    getDescription: ->
      description = []
      mcc = @selectMcc.selectedVal()
      if mcc then description.push("mcc: " + CellsFormController.getMccDescription mcc)
      mnc = @selectMnc.selectedVal()
      if mnc then description.push("mnc: " + CellsFormController.getMncDescription mnc)
      radio = @selectRadio.selectedVal()
      if radio then description.push "radio: #{radio}"
      lac = @selectLac.selectedVal()
      if lac then description.push "lac: #{lac}"
      rnc = @selectRnc.selectedVal()
      if rnc then description.push "rnc: #{rnc}"
      psc = @selectPsc.selectedVal()
      if psc then description.push "psc: #{psc}"
      cid = @selectCid.selectedVal()
      if cid then description.push "cid: #{cid}"
      description.join(', ')

    _onSelectionChanged : (eventObject) =>
      @_refresh()
      @_notifyOnFormChanged()

    _notifyOnFormChanged: ->
      listener(this) for listener in @listeners

    _setStatusLoadingCellList: (isLoading) ->
      @selectElements.prop('disabled', isLoading)

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

    _grepMcc: (cells) ->
      if not cells
        throw new Error "cells not defined"
      mcc = @selectMcc.selectedVal()
      if not mcc
        return cells
      mcc = parseInt(mcc)
      list = cellInfo for cellInfo in cells when cellInfo['mcc'] is mcc

    _grepMnc: (cells) ->
      if not cells
        throw new Error "cells not defined"
      mnc = @selectMnc.selectedVal()
      if not mnc
        return cells
      mnc = parseInt(mnc)
      list = cellInfo for cellInfo in cells when +cellInfo['mnc'] is mnc

    _grepLac: (cells) ->
      if not cells
        throw new Error "cells not defined"
      lac = @selectLac.selectedVal()
      if not lac
        return cells
      lac = parseInt(lac)
      list = cellInfo for cellInfo in cells when cellInfo['lac'] == lac

    _grepPsc: (cells) ->
      if not cells
        throw new Error "cells not defined"
      psc = @selectPsc.selectedVal()
      if not psc
        return cells
      psc = parseInt(psc)
      list = cellInfo for cellInfo in cells when cellInfo['psc'] == psc

    _grepRadio: (cells) ->
      if not cells
        throw new Error "cells not defined"
      radio = @selectRadio.selectedVal()
      if not radio
        return cells
      list = cellInfo for cellInfo in cells when cellInfo['radio'] == radio

    _grepRnc: (cells) ->
      if not cells
        throw new Error "cells not defined"
      rnc = @selectRnc.selectedVal()
      if not rnc
        return cells
      rnc = parseInt(rnc)
      list = cellInfo for cellInfo in cells when cellInfo['cid'] >> 16 == rnc
