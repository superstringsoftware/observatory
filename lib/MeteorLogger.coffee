Observatory = @Observatory ? {}

class Observatory.MeteorLogger extends Observatory.Logger
  constructor: (@name, @colName = '_observatory_logs', connection = null) ->
    super @name
    @_logsCollection = new Mongo.Collection @colName
    # can't update logs; setting up pointers to insert and remove allow functions
    if Meteor.isServer
      @_logsCollection.allow
        update: (uid)->
          false
        insert: (uid)=>
          @allowInsert uid
        remove: (uid)=>
          @allowRemove uid





  # redefine these functions anytime on server side to be able to control what gets logged -
  # useful when in production and want to control what comes from the clients:
  # Observatory._meteorLogger.allowInsert = (uid) -> ...
  allowInsert: (uid)->
    true
  allowRemove: (uid)->
    false

  # overriding the main logging method
  log: (message)=>
    #console.log "Logging in Meteor Server: #{Meteor.isServer}"
    msg = message # do we really need the clone thing??
    msg.userId = msg.userId ? @_checkUserId()
    msg.connectionId = Meteor.connection._lastSessionId if not Meteor.isServer
    #console.log msg
    @_logsCollection.insert msg


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