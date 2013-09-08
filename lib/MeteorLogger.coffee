Observatory = @Observatory ? {}

class Observatory.MeteorLogger extends Observatory.Logger
  constructor: (@name, @colName = '_observatory_logs', connection = null) ->
    super @name
    @_logsCollection = new Meteor.Collection @colName
    # can't update logs; setting up pointers to insert and remove allow functions
    if Meteor.isServer
      @_logsCollection.allow 
        update: (uid)-> false
        insert: (uid)=> @allowInsert uid
        remove: (uid)=> @allowRemove uid
    else
      Meteor.subscribe @colName # need to handle this differently
      
    
  # redefine these functions anytime on server side to be able to control what gets logged -
  # useful when in production and want to control what comes from the clients:
  # Observatory._meteorLogger.allowInsert = (uid) -> ...
  allowInsert: (uid)-> true
  allowRemove: (uid)-> false
    
  # overriding the main logging method
  log: (message)->
  	#console.log "Logging in Meteor Client"
  	msg = message # do we really need the clone thing??
  	msg.userId = @_checkUserId()
  	#console.log msg
  	@_logsCollection.insert msg


  # helper method to get userId
  # TODO: think how to get to it if we are in publish()
  # TODO: Needs testing!
  # TODO: Maybe just record uid and display actual user info when, uhm, displaying logs?
  _checkUserId: ->
    try
      uid = this.userId ? Meteor.userId()
    catch err
    uid

  
(exports ? this).Observatory = Observatory