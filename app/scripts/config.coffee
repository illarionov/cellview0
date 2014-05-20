require.config
  deps: ['Application']
  paths:
    jquery: '../../bower_components/jquery/dist/jquery',
    underscore: '../../bower_components/underscore/underscore'
    leaflet: '../../bower_components/leaflet-0.7.2.zip/leaflet'
    'leaflet-sidebar': '../../bower_components/leaflet-sidebar/src/L.Control.Sidebar'
    'leaflet-spin': '../../bower_components/Leaflet.Spin/leaflet.spin'
    spinjs: '../../bower_components/spin.js/spin'
    requirejs: '../../bower_components/requirejs/require'
    quadtree: '../../js_components/QuadTree'

  shim:
    'leaflet-sidebar':
      deps: [ 'leaflet' ]
      exports: 'L.Control.Sidebar'
    'leaflet-spin':
      deps: [ 'spinjs' ]
      exports: 'L.SpinMapMixin'
    'quadtree':
      exports: 'QuadTree'


