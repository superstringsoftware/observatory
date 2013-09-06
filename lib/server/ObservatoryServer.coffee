Observatory = @Observatory ? {}

# Class that publishes logs, manages relations with clients, sets up monitors etc
# heart of Observatory operations in Meteor
class Observatory.Server 
  
  # func should return whether we allow publishing or not
  publish: (func)->
    if Meteor.isServer
      Meteor.publish Observatory.settings.logsCollectionName, (numInPage = 300, pageNumber = 0)->
        canPublish = if func? then func.call this, @userId else true
        @_logsCollection.find {}, sort: timestamp: -1, limit: numInPage if canPublish
  
(exports ? this).Observatory = Observatory