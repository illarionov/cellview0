'use strict';

var gulp = require('gulp'),
  open = require('open'),
  wiredep = require('wiredep').stream,
  yaml = require('js-yaml'),
  fs   = require('fs'),
  $ = require('gulp-load-plugins')(),
  secrets = yaml.safeLoad(fs.readFileSync('secrets.yml', 'utf8')),
  environment = process.env.NODE_ENV || 'development';

function getDistDir(subdir) {
  var dir = 'dist/' + environment;
  if (subdir) { dir +=  '/' + subdir; }
  return dir;
}

function getTmpDir(subdir) {
  var dir = 'app/.tmp/' + environment;
  if (subdir) { dir +=  '/' + subdir; }
  return dir;
}

// Styles
gulp.task('styles', function () {
  return gulp.src(['app/styles/main.css'])
    .pipe($.autoprefixer('last 1 version'))
    .pipe(gulp.dest('app/styles'))
    .pipe($.size());
});

// coffelint
gulp.task('coffeelint', function () {
  return gulp.src('app/scripts/**/*.coffee')
    .pipe($.coffeelint())
    .pipe($.coffeelint.reporter())
    .pipe($.size());
});

gulp.task('jshint', function () {
  return gulp.src(['gulpfile.js', 'app/scripts/**/*.js'])
    .pipe($.jshint('.jshintrc')).pipe($.jshint.reporter('default'))
    .pipe($.jscs())
    .pipe($.notify({
      message: '<%= options.date %> ✓ jshint: <%= file.relative %>',
      templateOptions: {
        date: new Date()
      }
    }));
});

// coffees
gulp.task('coffees', ['coffeelint'], function () {
  var configFilter = $.filter(['Constants.coffee']);

  return gulp.src(['app/scripts/**/*.coffee'])
    .pipe(configFilter)
    .pipe($.preprocess({context: secrets[environment]}))
    .pipe(configFilter.restore())
    .pipe($.coffee({bare: true}).on('error', $.util.log))
    .pipe(gulp.dest(getTmpDir('coffee')))
    .pipe($.size());
});

// requirejs
gulp.task('requirejs', ['coffees', 'jshint'], function () {
  $.requirejs({
    baseUrl: getTmpDir('coffee'),
    include: ['requirejs', 'config'],
    mainConfigFile: getTmpDir('coffee') + '/config.js',
    out: 'body.js',
    preserveLicenseComments: true,
    useStrict: true,
    wrap: false
  })
    .pipe($.uglify({'mangle': false, 'output': {
      'beautify': true,
      'comments': true,
      'indent_level': 2
     }}))
    .pipe(gulp.dest(getDistDir('scripts'))).pipe($.size())
    .pipe($.notify({
      message: '<%= options.date %> ✓ requirejs: <%= file.relative %>',
      templateOptions: {
        date: new Date()
      }
    }));
});

// Scripts
gulp.task('scripts', ['requirejs'], function () {
  return gulp.src(['app/scripts/**/*.js'])
    .pipe($.notify({
      message: '<%= options.date %> ✓ scripts: <%= file.relative %>',
      templateOptions: {
        date: new Date()
      }
    }))
    .pipe($.size());
});

// HTML
gulp.task('html', ['styles', 'scripts'], function () {
  var jsFilter = $.filter(['**/*.js']),
    cssFilter = $.filter('**/*.css');

  return gulp.src(['app/*.html'])
    .pipe($.useref.assets())
    .pipe(jsFilter)
    .pipe($.uglify())
    .pipe(jsFilter.restore())
    .pipe(cssFilter)
    .pipe($.csso())
    .pipe(cssFilter.restore())
    .pipe($.useref.restore())
    .pipe($.useref())
    .pipe(gulp.dest(getDistDir()))
    .pipe($.size());
});

// Images
gulp.task('images', function () {
  return gulp.src([
    'app/images/**/*',
    'app/lib/images/*',
  ])
    .pipe($.cache($.imagemin({
      optimizationLevel: 3,
      progressive: true,
      interlaced: true
    })))
    .pipe(gulp.dest(getDistDir('images')))
    .pipe($.size());
});

// Leaflet images
gulp.task('leaflet_images', function () {
  return gulp.src('app/bower_components/leaflet-0.7.2.zip/images/*')
    .pipe(gulp.dest(getDistDir('styles/images')))
    .pipe($.size());
});

// Clean
gulp.task('clean', function () {
  return gulp.src([
    getDistDir('styles'),
    getTmpDir('coffee'),
    getDistDir('scripts'),
    getDistDir('images')], { read: false }).pipe($.clean());
});

// Build
gulp.task('build', ['html', 'images', 'leaflet_images']);

// Default task
gulp.task('default', ['clean'], function () {
  gulp.start('build');
});

// Connect
gulp.task('connect', function () {
  $.connect.server({
    root: ['app'],
    port: 9000,
    livereload: true
  });
});

// Open
gulp.task('serve', ['connect'], function () {
  open('http://localhost:9000');
});

// Inject Bower components
gulp.task('wiredep', function () {
  gulp.src('app/styles/*.css')
    .pipe(wiredep({
      directory: 'app/bower_components',
      ignorePath: 'app/bower_components/'
    }))
    .pipe(gulp.dest('app/styles'));

  gulp.src('app/*.html')
    .pipe(wiredep({
      directory: 'app/bower_components',
      ignorePath: 'app/'
    }))
    .pipe(gulp.dest('app'));

});

// Watch
gulp.task('watch', ['connect', 'serve'], function () {
  // Watch for changes in `app` folder
  gulp.watch([
    'app/*.html',
    'app/styles/**/*.css',
    'app/scripts/**/*.js',
    'app/scripts/**/*.coffee',
    'app/images/**/*'
  ], function (event) {
    console.log('reload');
    return gulp.src(event.path)
      .pipe($.connect.reload());
  });

  // Watch .css files
  gulp.watch('app/styles/**/*.css', ['styles']);

  // Watch .js files
  gulp.watch('app/scripts/**/*.js', ['requirejs']);

  // Watch .coffee files
  gulp.watch('app/scripts/**/*.coffee', ['requirejs']);

  // Watch image files
  gulp.watch('app/images/**/*', ['images']);

  // Watch bower files
  gulp.watch('bower.json', ['wiredep']);
});

gulp.task('set-environment-production', function() {
  environment = process.env.NODE_ENV || 'production';
});

// Deploy
gulp.task('deploy', ['set-environment-production', 'build'], function() {

  var host = secrets[environment].deploy.host,
    port = secrets[environment].deploy.port || 22,
    dir = secrets[environment].deploy.dir;

  return gulp.src(getDistDir(), {read: false})
   .pipe($.shell([
    'rsync  -e "ssh -p ' + port + '" -av --delete ' + getDistDir() + '/ ' + host + ':' + dir + '/'
   ]));
});
