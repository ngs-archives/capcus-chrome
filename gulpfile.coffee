gulp       = require 'gulp'
gutil      = require 'gulp-util'
coffee     = require 'gulp-coffee'
mocha      = require 'gulp-mocha'
watch      = require 'gulp-watch'
coffeelint = require 'gulp-coffeelint'
cson       = require 'gulp-cson'
fs         = require 'fs'
ChromeExtension = require 'crx'

require 'coffee-script/register'

gulp.task 'coffee', ->
  gulp
    .src 'src/**/*.coffee'
    .pipe coffeelint()
    .pipe coffeelint.reporter()
    .pipe coffee(bare: yes)
    .pipe gulp.dest 'build'

gulp.task 'cson', ->
  gulp
    .src 'src/**/*.cson'
    .pipe do cson
    .pipe gulp.dest 'build'

gulp.task 'copy', ->
  gulp
    .src 'src/**/*.png'
    .pipe gulp.dest 'build'

gulp.task 'watch', ->
  gulp.watch 'src/**/*.coffee', ->
    gulp.run 'coffee'
  gulp.watch 'src/**/*.cson', ->
    gulp.run 'cson'
  gulp.watch 'src/**/*.png', ->
    gulp.run 'copy'

getManifest = ->
  JSON.parse fs.readFileSync 'build/manifest.json'

gulp.task 'crx', ->
  {version} = getManifest()
  basename = "release/capcus-#{version}"
  crx = new ChromeExtension {
    rootDirectory: 'build'
    privateKey: fs.readFileSync 'key.pem'
  }
  crx.load()
    .then ->
      crx.loadContents()
    .then (next) ->
      fs.writeFile basename + '.zip', next
      crx.pack next
    .then (next) ->
      fs.writeFile basename + '.crx', next

gulp.task 'build', ['coffee', 'cson', 'copy', 'crx']

gulp.task 'default', ['build']
