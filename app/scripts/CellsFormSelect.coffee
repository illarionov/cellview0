define [
  'jquery'
], ($) ->
  class CellsFormSelect
    constructor: (rootElm) ->
      @values =
        "": ""
      @select = rootElm

    set: (hash) ->
      @values = hash
      @refresh()

    getSelectedVal: ->
      v = @select.find('option:selected').val()
      if v == ""
        return null
      else
        return v

    setSelectedVal: (key) ->
      if not key
        key = ""
      else
        key = "" if not @values[key]
      @select.val(key)

    refresh: ->
      selected = @select.find('option:selected').val()
      @select.empty()
      for k in Object.keys(@values).sort(
        (a,b) ->
          if (a == "")
            if b == "" then return 0 else return -1
          if (b == "")
            return 1

          nA = parseInt(a, 10)
          nB = parseInt(b, 10)
          if (isNaN(nA) || isNaN(nB))
            return a - b
          else
            return nA - nB
      )
        option = $('<option></option>').val(k).html(@values[k])
        @select.append option
      if selected and @values[selected]?
        @select.val(selected)
      else
        @select.val("")

