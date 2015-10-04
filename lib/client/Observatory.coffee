# CLIENT

Observatory = @Observatory ? {}

###
# TODO: REDEFINE to be server slave
Observatory.initialize = _.wrap Observatory.initialize, (f, s)->
  f.call Observatory, s

# TODO: REDEFINE to be server slave
Observatory.setSettings = _.wrap Observatory.setSettings, (f, s)->
  # calling base function
  f.call Observatory, s
###

# adding meteor-specific initialization
# TODO: NOTE!!! Logger on the client is created only after we've received settings from the server, which may or may not be good - think through!
Observatory.registerInitFunction (s)->
  #console.log Meteor
  @settingsController = new Observatory.Settings
  Meteor.startup =>
    #console.log 'subscribed'
    #@settings = Observatory.settingsController.currentSettings()
    #console.log @settings
    @_meteorLogger = new Observatory.MeteorLogger 'Meteor Logger'
    @subscribeLogger @_meteorLogger

    # creating command processor (client)
    @_commandClient = new Observatory.CommandClient()

# abstracting hidden Meteor APIs to get current session on the client
Observatory.lastSessionId = -> Meteor.connection._lastSessionId

(exports ? this).Observatory = Observatory