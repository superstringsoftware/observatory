Observatory = @Observatory ? {}

# quick and dirty authorization
# user - currently logged in user or null
# action - name of the action they want to run
# in the future, need some role-based checking, action map etc
# for now - only checking for the administrator role
# to address mind-boggling @userId issue, call as Observatory.canRun.call this !!! in publish functions
Observatory.canRun = (user, action = 'view')->
  res = false
  try
    user = (Meteor.users.findOne(_id: @userId) ? Meteor.user()) if not user?
  catch err
  #console.log @userId
  console.log user
  res = true if user?.profile?.observatoryProfile?.role is "administrator"
  res

# Class that publishes logs, manages relations with clients, sets up monitors etc
# heart of Observatory operations in Meteor
class Observatory.Server
  needsSetup: -> if Observatory.Settings.find({initialSetupComplete: true}).count()>0 then false else true

  # TODO: need to log calls when there's no needsSetup - that's malicious activity!!!
  # now adding a new user with administrator priviliges and changing the initialSetupComplete doc in the database
  initialSetup: (options)->
    if not @needsSetup() then return
    {user, email, password} = options
    #console.log "#{user}, #{password}, #{email}"
    id = Accounts.createUser {username: user, email: email, password: password, profile: {observatoryProfile: {role: "administrator"}} }
    Observatory.Settings.insert({initialSetupComplete: true}) if id?


  handshake: ->
    #console.log Meteor.user()
    o =
      version: Observatory.version
      needsSetup: @needsSetup()
      #settings: Observatory.settings
      monitoring: Observatory.emitters.Monitor.isRunning
      heartbeat: @heartbeat()
      sysinfo: Observatory.emitters.Monitor.sysInfoShort()

  heartbeat: ->
    @monitor = @monitor ? new Observatory.MonitoringEmitter
    @monitor.measure()
  

  # publishing settings and other info to local Observatory clients (local to the App being monitored that is)
  # now, of course you can connect to anything published both directly as well as via ddp.connect,
  # but keeping this separate for easier maintenance
  # TODO: granular settings publishing --> based on userId and connectionId eventually
  publishLocal: ->
    Meteor.publish '_observatory_settings', (opts)->
      #console.log 'publishing settings'
      # for now, no granularity, only anon vs logged in
      cur = if @userId then Observatory.Settings.find {type: "CLIENT_LOGGEDIN"} else Observatory.Settings.find {type: "CLIENT_ANONYMOUS"}

  # func should return whether we allow publishing or not
  # This is the heart of Vega operations - publishing all necessary data to the client
  publish: (func)->
  
    #canPublish = if func? then func.call this, @userId else true
    #return unless canPublish

    # publishing ALL settings for management purposes
    # TODO: rethink naming, as now Vega won't be able to monitor itself on the client (maybe that's ok)
    Meteor.publish '_observatory_settings_admin', (opts)->
      #console.log 'publishing settings'
      return if not Observatory.canRun.call(@)
      Observatory.Settings.find {}
    
    # publishing logs
    Meteor.publish Observatory.settings.logsCollectionName, (numInPage = 300, pageNumber = 0)->
      return if not Observatory.canRun.call(@)
      #console.log "trying to publish logs with #{numInPage}"
      cl = Observatory.getMeteorLogger()._logsCollection
      cr = cl.find({type: {$ne: 'monitor'}}, {sort: {timestamp: -1}, limit: numInPage})

    # funky stuff - publishing specific query, just the monitoring logs
    Meteor.publish '_observatory_monitoring', (numInPage = 100, pageNumber = 0)->
      return if not Observatory.canRun.call(@)
      #console.log "trying to publish monitoring"
      cl = Observatory.getMeteorLogger()._logsCollection
      #initializing = true
      handle = cl.find({type: 'monitor'}, {sort: {timestamp: -1}, limit: numInPage}).observe {
        added: (doc)=>
          #console.log "added called!"
          #console.log doc
          @added('_observatory_monitoring', doc._id, doc) #unless initializing
      }
      #initializing = false
      @ready()
      @onStop = -> handle.stop()
      return

    # just the http logs - for web visits analysis, will need to move to aggregation queries eventually
    Meteor.publish '_observatory_http_logs', (numInPage = 100, pageNumber = 0)->
      return if not Observatory.canRun.call(@)
      #console.log "trying to publish monitoring - logs"
      cl = Observatory.getMeteorLogger()._logsCollection
      #initializing = true
      handle = cl.find({module: 'HTTP'}, {sort: {timestamp: -1}, limit: numInPage}).observe {
        added: (doc)=>
          @added('_observatory_http_logs', doc._id, doc) #unless initializing
      }
      #initializing = false
      @ready()
      @onStop = -> handle.stop()
      return

    # just the errors
    Meteor.publish '_observatory_errors', (numInPage = 100, pageNumber = 0)->
      return if not Observatory.canRun.call(@)
      #console.log "trying to publish errors"
      cl = Observatory.getMeteorLogger()._logsCollection
      handle = cl.find({severity: {$lte: 1}}, {sort: {timestamp: -1}, limit: numInPage}).observe {
        added: (doc)=>
          @added('_observatory_errors', doc._id, doc) 
      }
      @ready()
      @onStop = -> handle.stop()
      return

    # profiling data
    Meteor.publish '_observatory_profiling', (numInPage = 100, pageNumber = 0)->
      return if not Observatory.canRun.call(@)
      #console.log "trying to publish profiling"
      cl = Observatory.getMeteorLogger()._logsCollection
      #initializing = true
      handle = cl.find({type: 'profile'}, {sort: {timestamp: -1}, limit: numInPage}).observe {
        added: (doc)=>
          @added('_observatory_profiling', doc._id, doc) #unless initializing
      }
      #initializing = false
      @ready()
      @onStop = -> handle.stop()
      return

    # open sessions - see DDPConnectionEmitter for hooks on manipulating dummy SessionsCollection
    Meteor.publish '_observatory_current_sessions', ->
      return if not Observatory.canRun.call(@)
      mi = new Observatory.MeteorInternals
      #console.log "trying to publish current sessions"
      #initializing = true
      handle = Observatory.DDPConnectionEmitter.SessionsCollection.find().observe {
        added: (doc)=>
          #console.log this
          # needs to be here because of mind-driving-crazy @userId thing in Meteor :(((
          ss = mi.convertSessionToView mi.findSession(doc.connectionId)
          @added('_observatory_current_sessions', doc.connectionId, ss) #unless initializing

        removed: (doc)=>
          @removed('_observatory_current_sessions', doc.connectionId)
      }
      #initializing = false
      @ready()
      @onStop = -> handle.stop()
      return





################################################################################################################################################
# METHODS
#################################################################################################################################################

Meteor.methods
  # called by Vega to check the heartbeat
  _observatoryHeartbeat: -> Observatory.meteorServer.heartbeat()
  _observatoryHandshake: -> Observatory.meteorServer.handshake()
  _observatoryInitialSetup: (options)-> Observatory.meteorServer.initialSetup options


  # auth stuff
  
(exports ? this).Observatory = Observatory