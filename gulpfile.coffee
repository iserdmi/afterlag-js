gulp = require 'gulp'
argv = require('yargs').argv
gulpif = require 'gulp-if'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
coffee = require 'gulp-coffee'
include = require 'gulp-include'
insert = require 'gulp-insert'
sourcemaps = require 'gulp-sourcemaps'
bower_config = require './bower.json'

copyrights = "/* Afterlag.js #{bower_config.version} — #{bower_config.description} Author: #{bower_config.author.name} (#{bower_config.author.web}). Licensed MIT. */\n"

gulp.task 'scripts', ->
  gulp.src('src/*.coffee')
    .pipe gulpif !argv.production, sourcemaps.init()
    .pipe include()
    .pipe coffee()
    .pipe insert.prepend copyrights
    .pipe gulp.dest 'dist'
    .pipe uglify()
    .pipe gulpif !argv.production, sourcemaps.write()
    .pipe rename
      suffix: '.min'
    .pipe insert.prepend copyrights
    .pipe gulp.dest 'dist'

gulp.task 'watch', ->
  gulp.watch 'src/*.coffee', ['scripts']

gulp.task 'default', ['scripts']
