gulp       = require 'gulp'
gutil      = require 'gulp-util'
coffee     = require 'gulp-coffee'
mocha      = require 'gulp-mocha'
watch      = require 'gulp-watch'
coffeelint = require 'gulp-coffeelint'
cson       = require 'gulp-cson'
watching   = no

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

gulp.task 'build', ['coffee', 'cson', 'copy']

gulp.task 'default', ['build']
