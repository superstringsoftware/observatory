Observatory = @Observatory ? {}

# Class that publishes logs, manages relations with clients, sets up monitors etc
# heart of Observatory operations in Meteor
class Observatory.Server 
  
  # func should return whether we allow publishing or not
  publish: (func)->
    if Meteor.isServer
      Meteor.publish Observatory.settings.logsCollectionName, (numInPage = 1000, pageNumber = 0)->
        canPublish = if func? then func.call this, @userId else true
        #console.log "trying to publish logs with #{numInPage}"
        cl = Observatory.getMeteorLogger()._logsCollection
        cr = cl.find({}, {sort: {timestamp: -1}, limit: numInPage}) if canPublish #
        
  
(exports ? this).Observatory = Observatory