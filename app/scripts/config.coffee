require.config
  deps: ['Application']
  paths:
    bootflat: '../../../bower_components/bootflatv2/bootflat/js/icheck.min'
    bootstrap: '../../../bower_components/bootflatv2/js/bootstrap.min'
    jquery: '../../../bower_components/jquery/dist/jquery',
    'jquery-deparam': '../../../bower_components/jquery-deparam/jquery-deparam',
    leaflet: '../../../bower_components/leaflet-0.7.2.zip/leaflet-src'
    'leaflet-sidebar': '../../../bower_components/leaflet-sidebar/src/L.Control.Sidebar'
    'leaflet-spin': '../../../bower_components/Leaflet.Spin/leaflet.spin'
    requirejs: '../../../bower_components/requirejs/require'
    spinjs: '../../../bower_components/spin.js/spin'
    underscore: '../../../bower_components/underscore/underscore'

  shim:
    'leaflet-sidebar':
      deps: [ 'leaflet' ]
      exports: 'L.Control.Sidebar'
    'leaflet-spin':
      deps: [ 'spinjs' ]
      exports: 'L.SpinMapMixin'
    'bootstrap':
      deps: ['jquery']
      exports: "$.fn.popover"
    'bootflat':
      deps: ['bootstrap']
