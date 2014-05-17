require.config
  deps: ['application']
  paths:
    jquery: '../../bower_components/jquery/dist/jquery',
    underscore: '../../bower_components/underscore/underscore'
    leaflet: '../../bower_components/leaflet-0.7.2.zip/leaflet'
    'leaflet-sidebar': '../../bower_components/leaflet-sidebar/src/L.Control.Sidebar'
    requirejs: '../../bower_components/requirejs/require'

  shim:
    'leaflet-sidebar':
      deps: [ 'leaflet' ]
