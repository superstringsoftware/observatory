Observatory = @Observatory ? {}

# Class that publishes logs, manages relations with clients, sets up monitors etc
# heart of Observatory operations in Meteor
class Observatory.Server 
  handshake: -> 
    o = 
      version: Observatory.version
      settings: Observatory.settings
      monitoring: Observatory.emitters.Monitor.isRunning
      heartbeat: @heartbeat()

  heartbeat: ->
    @monitor = @monitor ? new Observatory.MonitoringEmitter
    @monitor.measure()
  
  # func should return whether we allow publishing or not
  # This is the heart of Vega operations - publishing all necessary data to the client
  publish: (func)->
  
    canPublish = if func? then func.call this, @userId else true
    return unless canPublish
    
    # publishing logs
    Meteor.publish Observatory.settings.logsCollectionName, (numInPage = 300, pageNumber = 0)->
      #console.log "trying to publish logs with #{numInPage}"
      cl = Observatory.getMeteorLogger()._logsCollection
      cr = cl.find({type: {$ne: 'monitor'}}, {sort: {timestamp: -1}, limit: numInPage})

    # funky stuff - publishing specific query, just the monitoring logs
    Meteor.publish '_observatory_monitoring', (numInPage = 100, pageNumber = 0)->
      #console.log "trying to publish monitoring"
      cl = Observatory.getMeteorLogger()._logsCollection
      #initializing = true
      handle = cl.find({type: 'monitor'}, {sort: {timestamp: -1}, limit: numInPage}).observe {
        added: (doc)=>
          @added('_observatory_monitoring', doc._id, doc) #unless initializing
      }
      #initializing = false
      @ready()
      @onStop = -> handle.stop()

    # just the http logs - for web visits analysis, will need to move to aggregation queries eventually
    Meteor.publish '_observatory_http_logs', (numInPage = 100, pageNumber = 0)->
      #console.log "trying to publish monitoring"
      cl = Observatory.getMeteorLogger()._logsCollection
      #initializing = true
      handle = cl.find({module: 'HTTP'}, {sort: {timestamp: -1}, limit: numInPage}).observe {
        added: (doc)=>
          @added('_observatory_http_logs', doc._id, doc) #unless initializing
      }
      #initializing = false
      @ready()
      @onStop = -> handle.stop()

    # just the errors
    Meteor.publish '_observatory_errors', (numInPage = 100, pageNumber = 0)->
      cl = Observatory.getMeteorLogger()._logsCollection
      handle = cl.find({severity: {$lte: 1}}, {sort: {timestamp: -1}, limit: numInPage}).observe {
        added: (doc)=>
          @added('_observatory_errors', doc._id, doc) 
      }
      @ready()
      @onStop = -> handle.stop()
      


################################################################################################################################################
# METHODS
#################################################################################################################################################

Meteor.methods
  # called by Vega to check the heartbeat
  _observatoryHeartbeat: -> Observatory.meteorServer.heartbeat()
  _observatoryHandshake: -> Observatory.meteorServer.handshake()
  
(exports ? this).Observatory = Observatory