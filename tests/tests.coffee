if Meteor.isServer
  require = if Npm? then Npm.require else __meteor_bootstrap__.require
  Mocha = require 'mocha'
  fs = require("fs")
  path = require("path")


Meteor.methods
    runServerTests: ->
      console.log "runServerTests: ->"
      mocha = new Mocha({
                        ui: 'bdd',
                        reporter: 'spec'
                        });
      console.dir mocha


      fs.readdirSync("tests").filter((file) ->
        file.substr(-3) is ".js"
      ).forEach (file) ->

        # Use the method "addFile" to add the file to mocha
        mocha.addFile path.join("tests", file)


      # Now, you can run the tests.
      mocha.run (failures) ->
        console.dir failures




if Meteor.isClient
  Template.tests.events
   'click #btnTest': ->
     console.log "'click #btnTest': ->"
     Meteor.call 'runServerTests', (err,res)->
       console.dir res