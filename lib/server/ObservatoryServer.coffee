Observatory = @Observatory ? {}

# quick and dirty authorization
# user - currently logged in user or null
# action - name of the action they want to run
# in the future, need some role-based checking, action map etc
# for now - only checking for the administrator role
# to address mind-boggling @userId issue, call as Observatory.canRun.call this !!! in publish functions
Observatory.canRun = (uid, action = 'view')->
  res = false
  if uid?
    user = Meteor.users.findOne(uid)
  else
    try
      user = (Meteor.users.findOne(_id: @userId) ? Meteor.user()) if not uid?
    catch err
  #console.log @userId
  #console.log user
  res = true if user?.profile?.observatoryProfile?.role is "administrator"
  res

# Class that publishes logs, manages relations with clients, sets up monitors etc
# heart of Observatory operations in Meteor
class Observatory.Server

  constructor: ->
    @mi = new Observatory.MeteorInternals

  # TODO: need to log calls when there's no needsSetup - that's malicious activity!!!
  # now adding a new user with administrator priviliges and changing the initialSetupComplete doc in the database
  initialSetup: (options)->
    return unless Observatory.settingsController.needsSetup()
    {user, email, password} = options
    #console.log "#{user}, #{password}, #{email}"
    id = Accounts.createUser {username: user, email: email, password: password, profile: {observatoryProfile: {role: "administrator"}} }
    Observatory.settingsController.setupComplete() if id?


  handshake: ->
    #console.log Meteor.user()
    #console.log Observatory.settingsController
    o =
      version: Observatory.version
      needsSetup: Observatory.settingsController.needsSetup()
      monitoring: Observatory.emitters.Monitor.isRunning
      registeredUsers: Meteor.users.find().count()
      logsCount: Observatory.getMeteorLogger().logsCount()
      meteorVersion: Meteor.release
      heartbeat: @heartbeat()
      sysinfo: Observatory.emitters.Monitor.sysInfoShort()

  heartbeat: ->
    @monitor = @monitor ? new Observatory.MonitoringEmitter
    @monitor.measure()
  

  # publishing settings and other info to local Observatory clients (local to the App being monitored that is)
  # now, of course you can connect to anything published both directly as well as via ddp.connect,
  # but keeping this separate for easier maintenance
  # TODO: granular settings publishing --> based on userId and connectionId eventually
  publishLocal: -> Observatory.settingsController.publishLocal()

  # func should return whether we allow publishing or not
  # This is the heart of Vega operations - publishing all necessary data to the client
  publish: (func)->
  
    #canPublish = if func? then func.call this, @userId else true
    #return unless canPublish

    # publishing ALL settings for management purposes
    Observatory.settingsController.publishAdmin()
    
    # publishing logs
    Meteor.publish '_observatory_logs', (numInPage = 300, pageNumber = 0)->
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
          #console.log "adding session to publish!!!", doc
          #console.log this
          # needs to be here because of mind-driving-crazy @userId thing in Meteor :(((
          ss = mi.convertSessionToView mi.findSession(doc.connectionId)
          ss.started = doc.started
          @added('_observatory_current_sessions', doc.connectionId, ss) #unless initializing

        removed: (doc)=>
          @removed('_observatory_current_sessions', doc.connectionId)
      }
      #initializing = false
      @ready()
      @onStop = -> handle.stop()
      return

    # publishing users in the selected [id] list - useful for getting logged in users etc
    Meteor.publish '_observatory_selected_users', (userIds)->
      #console.log userIds
      return unless Observatory.canRun.call(@) and userIds?
      handle = Meteor.users.find({_id: {$in: userIds}}, fields: services: 0).observe {
        added: (doc)=>
          #console.log doc
          @added('_observatory_remote_users', doc._id, doc) #unless initializing

        removed: (doc)=>
          @removed('_observatory_remote_users', doc._id)
      }
      #initializing = false
      @ready()
      @onStop = -> handle.stop()
      return
      


  startConnectionMonitoring: ->





################################################################################################################################################
# METHODS
#################################################################################################################################################

Meteor.methods
  # No authorization: initial handshake with the server
  # TODO: strip it down to Observatory version and essential info to establish a connection
  _observatoryHandshake: -> Observatory.meteorServer.handshake()
  # Initial (First Time) setup - so, no auth
  _observatoryInitialSetup: (options)-> Observatory.meteorServer.initialSetup options

  # METHODS REQUIRING AUTHORIZATION
  # Current server - method and publish handlers
  # TODO - remove Observatory handlers?
  _observatoryGetCurrentServer: ->
    throw new Meteor.Error(77,"Observatory access denied") if not Observatory.canRun()
    Observatory.meteorServer.mi.getCurrentServer()

  # Regular heartbeat
  _observatoryHeartbeat: ->
    throw new Meteor.Error(77,"Observatory access denied") if not Observatory.canRun()
    Observatory.meteorServer.heartbeat()

  # Currently open sessions
  _observatoryGetOpenSessions: ->
    throw new Meteor.Error(77,"Observatory access denied") if not Observatory.canRun()
    mi = Observatory.meteorServer.mi
    ss = mi.getCurrentSessions()
    sessions = []
    sessions.push mi.convertSessionToView(v) for k,v of ss
    #console.dir v._namedSubs
    sessions



# auth stuff

_checkUserId = ->
  #console.log @
  uid = null
  try
    uid = this.userId ? Meteor.userId()
    #console.log uid
    return uid
  catch err
    #console.log err
    uid
  
(exports ? this).Observatory = Observatory