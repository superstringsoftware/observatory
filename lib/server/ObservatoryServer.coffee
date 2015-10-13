Observatory = @Observatory ? {}

# quick and dirty authorization
# user - currently logged in user or null
# action - name of the action they want to run
# in the future, need some role-based checking, action map etc
# for now - only checking for the administrator role
# to address mind-boggling @userId issue, call as Observatory.canRun.call this !!! in publish functions
Observatory.canRun = (uid, action = 'view')->
  #return true if Observatory.isLocalhost
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
  #console.log "Result of running canRun is #{res}"
  res

# Class that publishes logs, manages relations with clients, sets up monitors etc
# heart of Observatory operations in Meteor
class Observatory.Server

  constructor: ->
    @mi = new Observatory.MeteorInternals
    @monitor = new Observatory.MonitoringEmitter
    @mongo = new Observatory.Mongo
    #@commandServer = new Observatory.CommandServer

  # TODO: need to log calls when there's no needsSetup - that's malicious activity!!!
  # now adding a new user with administrator priviliges and changing the initialSetupComplete doc in the database
  initialSetup: (options)->
    return unless Observatory.settingsController.needsSetup()
    {user, email, password} = options
    #console.log "#{user}, #{password}, #{email}"
    id = Accounts.createUser {username: user, email: email, password: password, profile: {observatoryProfile: {role: "administrator"}}}
    Observatory.settingsController.setupComplete() if id?

  addProfileUser: (id) ->
    Meteor.users.update
      _id: id
    ,
      $set:
        'profile.observatoryProfile':
          role: 'administrator'
    ,
      upsert: true
    Observatory.settingsController.setupComplete()

  handshake: ->
    #console.log "Handshake called"
    #console.log Meteor.user()
    #console.log Observatory.settingsController
    o =
      version: Observatory.version
      isLocalhost: Observatory.isLocalhost
      needsSetup: Observatory.settingsController.needsSetup()
      monitoring: Observatory.emitters.Monitor.isRunning
      registeredUsers: Meteor.users.find().count()
      logsCount: Observatory.getMeteorLogger().logsCount()
      meteorVersion: Meteor.release
      heartbeat: @heartbeat()
      sysinfo: Observatory.emitters.Monitor.sysInfoShort()
      mongoCollections: @mongo.getCollections()
      mongoStats: @mongo.getStats()


  heartbeat: ->
    @monitor.measure()


  # publishing settings and other info to local Observatory clients (local to the App being monitored that is)
  # now, of course you can connect to anything published both directly as well as via ddp.connect,
  # but keeping this separate for easier maintenance
  # TODO: granular settings publishing --> based on userId and connectionId eventually
  publishLocal: -> Observatory.settingsController.publishLocal()


  _publishLogsTimed: (name, collectionName, selector = {}) ->
    Meteor.publish name, (hours = 12, filter = {}, limit = 2000) ->
      return if not Observatory.canRun.call(@)
      cl = Observatory.getMeteorLogger()._logsCollection
      dt = new Date (Date.now() - 3600000 * hours)
      selector.timestamp =
        $gt: dt
      query = _.extend filter, selector
      handle = cl.find(query, {sort: {timestamp: -1}, limit: limit}).observe {
        added: (doc) =>
          @added(collectionName, doc._id, doc)
      }
      @ready()
      @onStop = -> handle.stop()
      return

  # func should return whether we allow publishing or not
  # This is the heart of Vega operations - publishing all necessary data to the client
  publish: (func)->
    # publishing ALL settings for management purposes
    Observatory.settingsController.publishAdmin()

    # publishing logs
    ###
    Meteor.publish '_observatory_logs', (numInPage = 300, pageNumber = 0)->
      #console.log "trying to publish logs with #{numInPage} and #{pageNumber}"
      return if not Observatory.canRun.call(@)
      #console.log "trying to publish logs with #{numInPage} and #{pageNumber}"
      cl = Observatory.getMeteorLogger()._logsCollection
      cr = cl.find({type: {$ne: 'monitor'}}, {sort: {timestamp: -1}, limit: numInPage})
      cr
    ###

    # funky stuff - publishing specific query, just the monitoring logs
    @_publishLogsTimed '_observatory_logs', '_observatory_remote_logs', type:
      $ne: 'monitor'
    @_publishLogsTimed '_observatory_monitoring', '_observatory_monitoring', type: 'monitor'
    @_publishLogsTimed '_observatory_http_logs', '_observatory_http_logs', module: 'HTTP'
    @_publishLogsTimed '_observatory_errors', '_observatory_errors', severity:
      $lte: 1
    @_publishLogsTimed '_observatory_profiling', '_observatory_profiling', type: 'profile'


    ########################################################################################################################
    # NON - PERSISTENT PUBLISHES
    ########################################################################################################################


    # open sessions - see DDPConnectionEmitter for hooks on manipulating dummy SessionsCollection
    Meteor.publish '_observatory_current_sessions', ->
      _self = this
      return if not Observatory.canRun.call(@)
      mi = new Observatory.MeteorInternals
      #console.log "trying to publish current sessions"
      #initializing = true
      handle = Observatory.DDPConnectionEmitter.SessionsCollection.find().observe {
        added: (doc)=>
          #console.log "adding session to publish!!!", doc
          #console.log this
          # needs to be here because of mind-driving-crazy @userId thing in Meteor :(((
          session = mi.findSession doc.sessionId
          return false unless session
          ss = mi.convertSessionToView session
          ss.started = doc.started
          @added('_observatory_current_sessions', doc.sessionId, ss) #unless initializing

        removed: (doc)=>
#          console.log 'remove from _observatory_current_sessions', doc.connectionId, doc
          @removed('_observatory_current_sessions', doc.sessionId) if doc.sessionId

        changed: (oldDoc, newDoc)=>
          session = mi.findSession newDoc.sessionId
          return false unless session
          ss = mi.convertSessionToView session
          #console.log "Session changed", ss.id
          @changed('_observatory_current_sessions', newDoc.sessionId, ss)
      }
      #initializing = false
      _self.ready()
      _self.onStop = -> handle.stop()
      return

    # publishing users in the selected [id] list - useful for getting logged in users etc
    Meteor.publish '_observatory_selected_users', (userIds)->
      #console.log userIds
      return unless Observatory.canRun.call(@)
      userIds = [] if not userIds?
      # Adding observatory administrators for additional checks on the client
      # (does not breach security because all server calls check if the user can run it in any case -
      # the only reason we are doing it is for more graceful handling of logged in users, who are NOT
      # Observatory admins)
      handle = Meteor.users.find({$or: [{_id: {$in: userIds}}, {"profile.observatoryProfile.role": "administrator"}]},
        fields:
          services: 0).observe {
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

    monitor = @monitor # 'self = this' but don't want to mess with 'this' here
    # non-persistent monitors simply fires up monitor for the heartbeat and a live chart in the monitoring tab in Vega
    # TODO: this needs to go once we do proper architecture as heartbeat and monitoring will be implemented separately

    Meteor.publish '_observatory_nonpersistent_monitor', (timePeriod = 5000, dataPoints = 50) ->
      return unless Observatory.canRun.call(@)
      monitor.stopNonpersistentMonitor()
      monitor.startNonpersistentMonitor timePeriod
      handle = monitor.Monitors.find({}, sort: {timestamp: -1}).observe
        added: (doc)=>
          #console.log "Monitors are ", monitor.Monitors.find({}).count()
          @added('_observatory_nonpersistent_monitor', doc._id, doc) #unless initializing
          if monitor.Monitors.find({}).count() > dataPoints
            #console.log "Monitors too many, cleaning up"
            monitor.Monitors.remove timestamp:
              $lt: (Date.now() - timePeriod * dataPoints)

        removed: (doc) =>
          @removed '_observatory_nonpersistent_monitor', doc._id

      #initializing = false
      @ready()
      @onStop = ->
        handle.stop()
        monitor.stopNonpersistentMonitor()
      return



  startConnectionMonitoring: ->


    ###
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

    ###

(exports ? this).Observatory = Observatory