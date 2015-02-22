gulp = require 'gulp'
argv = require('yargs').argv
gulpif = require 'gulp-if'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
coffee = require 'gulp-coffee'
include = require 'gulp-include'
sourcemaps = require 'gulp-sourcemaps'

gulp.task 'scripts', ->
  gulp.src('src/*.coffee')
    .pipe gulpif !argv.production, sourcemaps.init()
    .pipe include()
    .pipe coffee()    
    .pipe gulp.dest 'dist'
    .pipe uglify()
    .pipe gulpif !argv.production, sourcemaps.write()
    .pipe rename
      suffix: '.min'
    .pipe gulp.dest 'dist'

gulp.task 'watch', ->
  gulp.watch 'src/*.coffee', ['scripts']

gulp.task 'default', ['scripts', 'watch']
