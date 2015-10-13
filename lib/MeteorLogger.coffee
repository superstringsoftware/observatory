Observatory = @Observatory ? {}

class Observatory.MeteorLogger extends Observatory.Logger

  constructor: (@name, @colName = '_observatory_logs', connection = null) ->
    super @name
    #TODO: need add remove db connection url to external settins
    #    remoteDB = new MongoInternals.RemoteCollectionDriver "mongodb://localhost:3001/logs_db"
    #    @_logsCollection = new Mongo.Collection @colName,
    #      _driver: remoteDB
    @_logsCollection = new Mongo.Collection @colName
    # 1048576 Bytes is 1MB
    # can't update logs; setting up pointers to insert and remove allow functions
    if Meteor.isServer
      # by hard default capped collection have 10 000 count rows
      @_logsCollection._createCappedCollection 1048576, 10000
      # ensure index for query by type and timestamp
      @_logsCollection._ensureIndex
        type: -1
        timestamp: -1
       
      @_logsCollection._ensureIndex
        severity: -1
        timestamp: -1

      @_logsCollection.allow
        update: (uid)->
          false
        insert: (uid)=>
          @allowInsert uid
        remove: (uid)=>
          @allowRemove uid

    # setting up interval to process buffered messages (we are using them in automagical stuff)
    Meteor.setInterval =>
      @processBuffer()
    , 5000 # every 5 seconds, should be enough

  # redefine these functions anytime on server side to be able to control what gets logged -
  # useful when in production and want to control what comes from the clients:
  # Observatory._meteorLogger.allowInsert = (uid) -> ...
  allowInsert: (uid)->
    false

  allowRemove: (uid)->
    false

  # overriding the main logging method
  log: (message)=>
    if Meteor.isClient
      #console.log "logging...", message
      #console.dir message
      if not Observatory.settingsController.currentSettings().logAnonymous
        if not Observatory.settingsController.currentSettings().logUser
          return
        else
          return unless Meteor.userId()?

    #console.log "Logging in Meteor Server: #{Meteor.isServer}"
    msg = message # do we really need the clone thing??
    msg.userId = msg.userId ? @_checkUserId()
    msg.sessionId = Observatory.lastSessionId() if not Meteor.isServer
    #console.log msg
    @_logsCollection.insert msg

  logsCount: ->
    @_logsCollection.find({}).count()

  # helper method to get userId
  # TODO: think how to get to it if we are in publish()
  # TODO: Needs testing!
  # TODO: Maybe just record uid and display actual user info when, uhm, displaying logs?
  _checkUserId: =>
    #console.log @
    uid = null
    try
      uid = this.userId ? Meteor.userId()
    #console.log uid
    #return uid
    catch err
    #console.log err
    uid


(exports ? this).Observatory = Observatory