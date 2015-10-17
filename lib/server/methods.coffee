Observatory = @Observatory ? {}

###
  All methods exposed to clients
###


Meteor.methods
# No authorization: initial handshake with the server
# TODO: strip it down to Observatory version and essential info to establish a connection
  _observatoryHandshake: ->
    #console.log "_observatoryHandshake called"
    tb = Observatory.getToolbox()
    s = Observatory.meteorServer
    tb.profile method: "handshake()", s, s.handshake

# Initial (First Time) setup - so, no auth
  _observatoryInitialSetup: (options)-> Observatory.meteorServer.initialSetup options

# Add initial setup to loggined user
  _observatoryAddUserProfile: (userId) ->
    Observatory.meteorServer.addProfileUser userId

# METHODS REQUIRING AUTHORIZATION
# Current server - method and publish handlers
# TODO - remove Observatory handlers?
  _observatoryGetCurrentServer: ->
    throw new Meteor.Error(77,"Observatory access denied") if not Observatory.canRun()
    Observatory.meteorServer.mi.getCurrentServer()

  _observatoryServerStats: ->
    throw new Meteor.Error(77,"Observatory access denied") if not Observatory.canRun()
    tb = Observatory.getToolbox()
    s = Observatory.meteorServer
    tb.profile method: "serverStats()", s, s.serverStats


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

  # get all modules from observatory logs
  _observatoryLogModules: ->
    #raw collection
    col = Observatory.meteorServer.mongo._col
    aggregate = Meteor.wrapAsync col.aggregate.bind col
    aggregate [
      $group:
        _id:
          module: "$module"
    ,
      $project:
        module: "$_id.module"
    ]
