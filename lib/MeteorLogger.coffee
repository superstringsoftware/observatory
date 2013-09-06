Observatory = @Observatory ? {}

class Observatory.MeteorLogger extends @Observatory.Logger
  constructor: (@name, @colName = '_observatory_logs', connection = null) ->
    @_logsCollection = new Meteor.Collection @colName
    # can't update logs; setting up pointers to insert and remove allow functions
    if Meteor.isServer
      @_logsCollection.allow 
        update: (uid)-> false
        insert: (uid)=> @allowInsert uid
        remove: (uid)=> @allowRemove uid
      
    
  # redefine these functions anytime on server side to be able to control what gets logged -
  # useful when in production and want to control what comes from the clients
  allowInsert: (uid)-> true
  allowRemove: (uid)-> false
    
  # overriding the main logging method
  log: (message)->
  	console.log "Logging in Meteor Client"
  	console.log message
  	{user, uid} = @_checkUser()
  	msg = _.clone message
  	msg.user = user
  	msg.userId = uid
  	console.log msg
  	@_logsCollection.insert msg


  # helper method to get userId
  # TODO: think how to get to it if we are in publish()
  # TODO: Needs testing!
  _checkUser: ->
    user = ''
    try
      uid = if this.userId? then this.userId else Meteor.userId()
      u = Meteor.users.findOne(uid) # TODO: check how it affects performance!
      if u and u.username
        user = u.username
      else
        if u and u.emails and u.emails[0]
          user = u.emails[0].address
        else
          user = if u and u.profile?.name then u.profile.name else uid
    catch err
    {user: user, uid: uid}

  
(exports ? this).Observatory = Observatory