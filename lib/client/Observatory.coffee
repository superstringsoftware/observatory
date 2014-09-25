# CLIENT

Observatory = @Observatory ? {}

# TODO: REDEFINE to be server slave
Observatory.initialize = _.wrap Observatory.initialize, (f, s)->
  f.call Observatory, s

# TODO: REDEFINE to be server slave
Observatory.setSettings = _.wrap Observatory.setSettings, (f, s)->
  # calling base function
  f.call Observatory, s

# adding meteor-specific initialization
# TODO: NOTE!!! Logger on the client is created only after we've received settings from the server, which may or may not be good - think through!
Observatory.registerInitFunction (s)->
  #console.log Meteor
  Meteor.startup =>
    Meteor.subscribe '_observatory_settings', {uid: Meteor.userId(), connectionId: Meteor.connection._lastSessionId},  =>
      #console.log 'subscribed'
      @settings = Observatory.Settings.findOne().settings
      #console.log @settings
      @_meteorLogger = new Observatory.MeteorLogger 'Meteor Logger', @settings.logsCollectionName
      @subscribeLogger @_meteorLogger


(exports ? this).Observatory = Observatory