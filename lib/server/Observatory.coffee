Observatory = @Observatory ? {}

###
  Different initializations and startup functions.
  Needs clean up together with Galileo
###

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


# adding meteor-specific initialization
Observatory.registerInitFunction (s)->
  # setting up client / server meteor loggers
  @_meteorLogger = new Observatory.MeteorLogger 'Meteor Logger', @settingsController.currentSettings().logsCollectionName ? '_observatory_logs'
  @subscribeLogger @_meteorLogger

  # initializing emitters
  @emitters.DDP = Observatory.DDPEmitter.de 'DDP'
  @emitters.DDPConnection = Observatory.DDPConnectionEmitter.de 'DDP Connection'
  @emitters.Http = new Observatory.HttpEmitter 'HTTP'
  @emitters.Monitor = new Observatory.MonitoringEmitter 'Monitor'
  @emitters.System = new Observatory.SystemEmitter 'System', @_meteorLogger._logsCollection

  @meteorServer = new Observatory.Server
  @meteorServer.publish() #unless @settings.prohibitAutoPublish
  @meteorServer.publishLocal() # basically, only settings

  # turning on commands processing - this went into a separate init function in the CommandProcessor package
  #@meteorServer.commandServer.publishAdmin()
  #@meteorServer.commandServer.publishLocal()

  @settingsController.processSettingsUpdate @settingsController.currentSettings()

  # checking if running on localhost to bypass authorization
  @isLocalhost = if Meteor.absoluteUrl(replaceLocalhost:true).indexOf("http://127.0.0.1") is 0 then true else false
  #console.log @isLocalhost

  # setting up buffers checks for http and DDP logging
  Meteor.setInterval ->
    m = Observatory.getMeteorLogger()
    m.processBuffer()
  , 3000


(exports ? this).Observatory = Observatory
