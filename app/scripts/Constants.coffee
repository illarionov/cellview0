define [
], ->
  class Constants

    @API_URL: '/* @echo API_URL */' || "http://127.0.0.1:8080"
    @API_COVERAGE_URL: @API_URL + "/v1/coverage"
    @API_COVERAGE_HULL_URL: @API_COVERAGE_URL + "/hull"
    @API_CELLS_URL: @API_URL + "/v1/cells"

    @MAPBOX_API_KEY: '/* @echo MAPBOX_API_KEY */' || 'examples.map-i86nkdio'
    @MAPBOX_LAYER_URI: "http://api.tiles.mapbox.com/v3/#{@MAPBOX_API_KEY}/{z}/{x}/{y}.png"
    @MAP_DEFAULT_CENTER: [56.1130, 47.2714]
    @MAP_DEFAULT_ZOOM: 11

    @MCC_NAMES:
      250: 'Russia'

    @MNC_NAMES:
      1: 'MTS'
      2: 'Megafon'
      7: 'Smarts'
      39: 'Rostelecom'
      99: 'Beeline'

    @DEFAULT_COVERAGE_FORM:
      mcc: 250
      mnc: 99
      network_radio: 'umts'