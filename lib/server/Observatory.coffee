# TODO: Need to define settings and stuff on the SERVER and publish to the client
# the client needs to be a slave
# SERVER

Observatory = @Observatory ? {}

# initialize runs all functions that are registered with registerInitFunction with s as arguments
Observatory.initialize = _.wrap Observatory.initialize, (f, s)->
  #s = Meteor.settings?.public?.observatorySettings unless s?
  Observatory.settingsController = new Observatory.Settings
  s = Observatory.settingsController.currentSettings() unless s?
  #console.log s
  f.call Observatory, s

# extending the settings changing function
Observatory.setSettings = _.wrap Observatory.setSettings, (f, s)->
  # calling base function
  f.call Observatory, s
  ###
  @settings.logUser = s.logUser ? @settings.logUser
  @settings.logHttp = s?.logHttp ? @settings.logHttp
  @settings.logDDP = s?.logDDP ? @settings.logDDP
  ###

# adding meteor-specific initialization
Observatory.registerInitFunction (s)->
  # Default settings for loglevel and printToConsole are INFO and false (defined in Galileo).
  ###
  @settings.logsCollectionName = s?.logsCollectionName ? '_observatory_logs'
  @settings.logUser = s?.logUser ? true
  @settings.logHttp = s?.logHttp ? true
  @settings.logDDP = s?.logDDP ? false
  @settings.prohibitAutoPublish = s?.prohibitAutoPublish ? false
  @settings.logAnonymous = s?.logAnonymous ? false
  ###

  # setting up client / server meteor loggers
  #console.log @settings
  @_meteorLogger = new Observatory.MeteorLogger 'Meteor Logger', @settingsController.currentSettings().logsCollectionName ? '_observatory_logs'
  @subscribeLogger @_meteorLogger

  @meteorServer = new Observatory.Server
  @meteorServer.publish() #unless @settings.prohibitAutoPublish
  @meteorServer.publishLocal() # basically, only settings
  @emitters.DDP = Observatory.DDPEmitter.de 'DDP'
  @emitters.DDPConnection = Observatory.DDPConnectionEmitter.de 'DDP Connection'
  @emitters.Http = new Observatory.HttpEmitter 'HTTP'
  @emitters.Monitor = new Observatory.MonitoringEmitter 'Monitor'
  @emitters.System = new Observatory.SystemEmitter 'System', @_meteorLogger._logsCollection

  @settingsController.processSettingsUpdate @settingsController.currentSettings()

  # checking if running on localhost to bypass authorization
  @isLocalhost = if Meteor.absoluteUrl(replaceLocalhost:true).indexOf("http://127.0.0.1") is 0 then true else false
  #console.log @isLocalhost

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


# TESTING!!!
###
Meteor.publish = _.wrap Meteor.publish, (f)->
  args = _.rest arguments
  #console.log args

  name = args[0]
  func = args[1]

  args[1] = _.wrap func, (f1)->
    t1 = Date.now()
    args1 = _.rest arguments
    console.log "Calling publish function #{name} with #{args1}"
    ret = f1.apply this, args1
    console.log "...executed in #{Date.now()-t1}ms"
    ret

  r = f.apply this, args
  r
###

(exports ? this).Observatory = Observatory
