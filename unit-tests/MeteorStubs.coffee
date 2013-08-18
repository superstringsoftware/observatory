# stub for testing, if we are in the test env Meteor won't be defined
Meteor = 
  isServer: true
  isClient: false
  Collection: (name)->
    @name = name
    allow: (fn)->
      console.log "collection allow called"
  startup: (fn)->
    fn.call this, arguments
  setInterval: (fn)->
    console.log "setInterval called"
  publish: (name, fn)->
    console.log "Publishing #{name}"
  __meteor_bootstrap__:
    app: 
      use: (fn)->
        console.log "Connect Hook called"

__meteor_bootstrap__ = Meteor.__meteor_bootstrap__
EJSON = JSON

#module.exports = this
module.exports.Meteor = Meteor
module.exports.EJSON = EJSON
#(exports ? this).Meteor = Meteor

