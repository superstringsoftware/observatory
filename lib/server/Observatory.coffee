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

Observatory.initialize = _.wrap Observatory.initialize, (f, s)->
  s = Meteor.settings?.public?.observatorySettings unless s?
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
  
  @meteorServer = new Observatory.Server
  @meteorServer.publish() unless @settings.prohibitAutoPublish
  @emitters.DDP = Observatory.DDPEmitter.de 'DDP'
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