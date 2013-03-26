if Meteor.isServer
  require = if Npm? then Npm.require else __meteor_bootstrap__.require
  Mocha = require 'mocha'
  fs = require("fs")
  path = require("path")
  chai = require("chai")
  tty = require('tty')
  console.log tty.isatty(1)

  Meteor.startup ->
    runServerTests()

  runServerTests = ->
    console.log "runServerTests: ->"
    #console.dir mocha

    mocha = new Mocha({ui: 'bdd', reporter: 'spec'});
    Mocha.reporters.Base.useColors = true
    
    fs.readdirSync("tests").filter((file) ->
      file.substr(-3) is ".js"
    ).forEach (file) ->

      # Use the method "addFile" to add the file to mocha
      mocha.addFile path.join("tests", file)

    # Now, you can run the tests.
    res = mocha.run()
    #console.dir res
    res



  Meteor.methods
    runServerTests: runServerTests




###
if Meteor.isClient
  Template.tests.events
   'click #btnTest': ->
     console.log "'click #btnTest': ->"
     Meteor.call 'runServerTests', (err,res)->
       console.dir res

###