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
            return b == "" ? 0 : -1
          if (b == "")
            return 1
          return a - b
      )
        option = $('<option></option>').val(k).html(@values[k])
        @select.append option
      if selected and @values[selected]?
        @select.val(selected)
      else
        @select.val("")

