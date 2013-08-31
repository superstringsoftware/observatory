# stub for testing, if we are in the test env Meteor won't be defined
Meteor =
  isServer: true
  isClient: false
  Collection: (name)->
    @name = name
    allow: (fn)->
      #console.log "collection allow called"
    insert: ->
      #console.log "collection insert called"
  startup: (fn)->
    fn.call this, arguments
  setInterval: (fn)->
    #console.log "setInterval called"
  publish: (name, fn)->
    #console.log "Publishing #{name}"
  default_server:
    stream_server:
      register: (func)->

EJSON = JSON

WebApp =
  connectHandlers:
    use:(name)->
      #console.log "WebApp.connectHandlers.use #{name} called"

Observatory =
  logger: ->
    #console.log "logger called"

#module.exports = this
#module.exports.Meteor = Meteor
#module.exports.EJSON = EJSON
#(exports ? this).Meteor = @Meteor

