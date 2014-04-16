#+--------------------------------------------------------------------+
#| Cakefile
#+--------------------------------------------------------------------+
#| Copyright FiftyTwoFiftyTwo, LLC (c) 2014
#+--------------------------------------------------------------------+
#|
#| This file is a part of iwishua
#|
#+--------------------------------------------------------------------+
#
# cake utils
#
fs = require 'fs'
util = require 'util'
{exec} = require 'child_process'
{nfcall} = require 'q'


#
# Build Source
#
#
task 'build:src', 'Build the coffee app', ->

  if not fs.existsSync('tmp/') then fs.mkdirSync('tmp')
  if not fs.existsSync('cloudCode/public/js/') then fs.mkdirSync('cloudCode/public/js')

  start = new Date().getTime()
  nfcall exec, 'coffee -o tmp -c -b src'

  .then ->
    nfcall exec, 'browserify --debug tmp/main.js > cloudCode/public/js/app.js'

  .then ->
    nfcall exec, 'browserify --debug tmp/main.js | uglifyjs > cloudCode/public/js/app.min.js'

  .fail ($err) ->
    util.error $err

  .done ($args) ->
    util.log $text for $text in $args when not /\s*/.test $text
    util.log "Compiled in #{new Date().getTime() - start} ms"
