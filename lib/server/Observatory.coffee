# TODO: Need to define settings and stuff on the SERVER and publish to the client
# the client needs to be a slave
# SERVER

Observatory = @Observatory ? {}

###
Settings format:
  "public" only for backward compat. Now settings stay on the server.

{
  "observatorySettings": {
      "logLevel": "DEBUG",
      "printToConsole": true,
      "logUser": true,
      "logAnonymous": true,
      "logHttp": true,
      "logDDP": true,
      "prohibitAutoPublish": false
  }
    "public": {
        "observatorySettings": {
            "logsCollectionName": "_observatory_logs",
            "logLevel": "DEBUG",
            "printToConsole": true,
            "logUser": true,
            "logHttp": true,
            "logDDP": true,
            "prohibitAutoPublish": false
        }
    }
}
###

Observatory.loadSettings = ->
  # first run in the app - filling collection with defaults
  if Observatory.Settings.find().count() is 0
    Observatory.Settings.insert({type: "SERVER", settings: Observatory.defaultServerSettings})
    Observatory.Settings.insert({type: "CLIENT_LOGGEDIN", settings: Observatory.defaultClientSettings})
    Observatory.Settings.insert({type: "CLIENT_ANONYMOUS", settings: Observatory.defaultClientSettings})
    s = @defaultServerSettings
  else
    s = @Settings.findOne({type: "SERVER"})?.settings
    if not s?
      Observatory.Settings.insert({type: "SERVER", settings: Observatory.defaultServerSettings})
      s = @defaultServerSettings
  s

# initialize runs all functions that are registered with registerInitFunction with s as arguments
Observatory.initialize = _.wrap Observatory.initialize, (f, s)->
  #s = Meteor.settings?.public?.observatorySettings unless s?
  s = @loadSettings() unless s?
  #console.log s
  f.call Observatory, s

# extending the settings changing function
Observatory.setSettings = _.wrap Observatory.setSettings, (f, s)->
  # calling base function
  f.call Observatory, s
  @settings.logUser = s.logUser ? @settings.logUser
  @settings.logHttp = s?.logHttp ? @settings.logHttp
  @settings.logDDP = s?.logDDP ? @settings.logDDP

# adding meteor-specific initialization
Observatory.registerInitFunction (s)->


  # Default settings for loglevel and printToConsole are INFO and false (defined in Galileo).
  @settings.logsCollectionName = s?.logsCollectionName ? '_observatory_logs'
  @settings.logUser = s?.logUser ? true
  @settings.logHttp = s?.logHttp ? true
  @settings.logDDP = s?.logDDP ? false
  @settings.prohibitAutoPublish = s?.prohibitAutoPublish ? false
  @settings.logAnonymous = s?.logAnonymous ? false
  
  # setting up client / server meteor loggers
  #console.log @settings
  @_meteorLogger = new Observatory.MeteorLogger 'Meteor Logger', @settings.logsCollectionName
  @subscribeLogger @_meteorLogger

  if not @settings.logAnonymous
    @_meteorLogger.allowInsert = (uid) ->
      if uid? then true else false

  Observatory.Settings.allow
    insert: (uid, doc) -> Observatory.canRun(uid)
    update: (uid, doc, fields, modifier) -> Observatory.canRun(uid)
    # TODO: for removal, need to make sure SERVER, CLIENT and ANONYMOUS can't be deleted
    remove: (uid, doc) -> Observatory.canRun(uid)

  
  @meteorServer = new Observatory.Server
  @meteorServer.publish() unless @settings.prohibitAutoPublish
  @meteorServer.publishLocal() # basically, only settings
  @emitters.DDP = Observatory.DDPEmitter.de 'DDP'
  @emitters.DDPConnection = Observatory.DDPConnectionEmitter.de 'DDP Connection'
  @emitters.Http = new Observatory.HttpEmitter 'HTTP'
  @emitters.Monitor = new Observatory.MonitoringEmitter 'Monitor'
  # setting up buffers checks for http and DDP logging
  Meteor.setInterval ->
    m = Observatory.getMeteorLogger()
    m.processBuffer()
  , 3000


#Observatory.initialize()

###
if Meteor.isServer
  Observatory._meteorLogger.allowInsert = (uid)->
    console.log "Trying to insert for " + uid
    true
###

(exports ? this).Observatory = Observatory
