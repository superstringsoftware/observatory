Observatory = @Observatory ? {}

###
Settings format:

{
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

# wrapping subscription function if somebody wants to use locally
Observatory.subscribe = (numOfLogs)->
  Meteor.subscribe @settings.logsCollectionName, numOfLogs ? 50 if Meteor.isClient

# changing server definition function to meteor specific
Observatory.isServer = -> Meteor.isServer
# defining getter for the meteor logger
Observatory.getMeteorLogger = -> Observatory._meteorLogger
# adjusting initialize to read Meteor.settings
Observatory.initialize = _.wrap Observatory.initialize, (f, s)->
  s = Meteor.settings?.public?.observatorySettings unless s?
  f.call Observatory, s
# extending the settings changing function
Observatory.setSettings = _.wrap Observatory.setSettings, (f, s)->
  # calling base function
  f.call Observatory, s
  # don't allow collection name change on the fly? Autopublishing is impossible to change without restart. 
  # If you want granular control over how logs collection is being published, use the server
  # @settings.logsCollectionName = s?.logsCollectionName ? @settings.logsCollectionName
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
  
  # setting up client / server meteor loggers
  #console.log @settings
  @_meteorLogger = new Observatory.MeteorLogger 'Meteor Logger', @settings.logsCollectionName
  @subscribeLogger @_meteorLogger
  
  # adding Observatory Server and publishing logs if not forbidden explicitly
  if Meteor.isServer

    #console.log Meteor.absoluteUrl()

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

  else
    Meteor.subscribe @settings.logsCollectionName unless @settings.prohibitAutoPublish


Observatory.initialize()

###
if Meteor.isServer
  Observatory._meteorLogger.allowInsert = (uid)->
    console.log "Trying to insert for " + uid
    true
###
      

(exports ? this).Observatory = Observatory