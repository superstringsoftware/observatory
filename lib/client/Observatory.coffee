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
Observatory.registerInitFunction (s)->
  
  @_meteorLogger = new Observatory.MeteorLogger 'Meteor Logger', @settings.logsCollectionName
  @subscribeLogger @_meteorLogger
  

#Observatory.initialize()

###
if Meteor.isServer
  Observatory._meteorLogger.allowInsert = (uid)->
    console.log "Trying to insert for " + uid
    true
###

(exports ? this).Observatory = Observatory