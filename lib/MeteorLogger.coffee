Observatory = @Observatory ? {}

class Observatory.MeteorLogger extends Observatory.Logger

  constructor: (@name, @colName = '_observatory_logs', connection = null) ->
    super @name
    @_logsCollection = new Mongo.Collection @colName
    # ensure index for query by type and timestamp
    @_logsCollection._ensureIndex
      type: -1
      timestamp: -1
    # can't update logs; setting up pointers to insert and remove allow functions
    if Meteor.isServer
      @_logsCollection.allow
        update: (uid)->
          false
        insert: (uid)=>
          @allowInsert uid
        remove: (uid)=>
          @allowRemove uid
    #hard override node.js stdout and stderror methods
    @hookStream()

  #Server Methods for override process.stdout
  hookStream: ->
    return if Meteor.isClient
    stored_stdout_write = process.stdout.write
    self = @
    process.stdout.write = Meteor.bindEnvironment (string, encoding, fd) ->
      self.log self.messageStub string
      stored_stdout_write.apply process.stdout, arguments

  messageStub: (message) ->
    isServer: true
    severity: Observatory.LOGLEVEL.INFO
    module: "AUTO"
    timestamp: new Date
    textMessage: message

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
      #console.log "logging..."
      #console.dir message
      if not Observatory.settingsController.currentSettings().logAnonymous
        if not Observatory.settingsController.currentSettings().logUser
          return
        else
          return unless Meteor.userId()?

    #console.log "Logging in Meteor Server: #{Meteor.isServer}"
    msg = message # do we really need the clone thing??
    msg.userId = msg.userId ? @_checkUserId()
    msg.connectionId = Meteor.connection._lastSessionId if not Meteor.isServer
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