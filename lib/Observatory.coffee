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

# changing server definition function to meteor specific
Observatory.isServer = -> Meteor.isServer

Observatory.getMeteorLogger = -> Observatory._meteorLogger

# adding meteor-specific initialization
Observatory.registerInitFunction (s)->
  
  @settings.logsCollectionName = s?.logsCollectionName ? '_observatory_logs'
  @settings.logUser = s?.logUser ? true
  @settings.logHttp = s?.logHttp ? true
  @settings.logDDP = s?.logDDP ? false
  @settings.prohibitAutoPublish = s?.prohibitAutoPublish ? false
  
  # setting up client / server meteor loggers
  @_meteorLogger = new Observatory.MeteorLogger 'Meteor Logger', @settings.logsCollectionName
  @subscribeLogger @_meteorLogger
  
  # adding Observatory Server and publishing logs if not forbidden explicitly
  if Meteor.isServer
    @meteorServer = new Observatory.Server 
    @meteorServer.publish() unless @settings.prohibitAutoPublish

Observatory.initialize()

###
if Meteor.isServer
  Observatory._meteorLogger.allowInsert = (uid)->
    console.log "Trying to insert for " + uid
    true
###
      

(exports ? this).Observatory = Observatory