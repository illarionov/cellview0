define [
], ->
  class Constants

    @API_URL: '/* @echo API_URL */' || "http://127.0.0.1:8080"
    @API_COVERAGE_URL: @API_URL + "/v1/coverage"
    @API_COVERAGE_HULL_URL: @API_COVERAGE_URL + "/hull"
    @API_CELLS_URL: @API_URL + "/v1/cells"

    @MAP_MAIN_LAYER: '/* @echo MAP_MAIN_LAYER */' ||
      "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
    @MAP_MAIN_LAYER_ATTRIBUTION = '/* @echo MAP_MAIN_LAYER_ATTRIBUTION */' ||
      'Map data © <a href="http://www.openstreetmap.org">OpenStreetMap contributors</a>'
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