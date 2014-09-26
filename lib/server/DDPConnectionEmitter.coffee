
Observatory = @Observatory ? {}

class Observatory.DDPConnectionEmitter extends @Observatory.MessageEmitter
  @connectionCount = 0
  @messageStub: ->
    options =
      isServer: true
      severity: Observatory.LOGLEVEL.VERBOSE
      module: "DDP"
      timestamp: new Date
    options

  @_instance = undefined

  # getter for the instance
  @de: => 
    @_instance?= new Observatory.DDPConnectionEmitter "DDP Connection Emitter"
    @_instance

  @SessionsCollection = new Mongo.Collection

  # TODO: add support for logging this in settings
  constructor: (@name, @formatter)->
    #console.log "DDPEmitter::constructor #{name}"
    super @name, @formatter
    if Observatory.DDPConnectionEmitter._instance? then throw new Error "Attempted to create another instance of DDPConnectionEmitter and it is a really bad idea"
    # registering to listen to connection events with Meteor
    Meteor.onConnection (con)=>
      return unless Observatory.DDPConnectionEmitter.de().isOn #and Observatory.settings.logDDP
      Observatory.DDPConnectionEmitter.connectionCount++
      msg = Observatory.DDPConnectionEmitter.messageStub()
      msg.connectionId = con.id
      msg.textMessage = "New connection #{con.id} from #{con.clientAddress}"
      msg.IP = con.clientAddress
      msg.object = headers: con.httpHeaders, totalConnections: Observatory.DDPConnectionEmitter.connectionCount
      msg.type = "DDPConnection:OPEN"
      #msg.userId = @userId()
      # emitting message and putting to the buffer for the sake of Meteor logging. Insensitive loggers, such as Console,
      # should actually ignore this
      #console.log "Sessions: #{Observatory.MeteorInternals.getSessionCount()}"
      #console.log "Connections: #{Observatory.DDPConnectionEmitter.connectionCount}"
      Observatory.DDPEmitter.de().emitMessage msg, false
      Observatory.DDPConnectionEmitter.SessionsCollection.insert({connectionId: con.id})


      con.onClose =>
        #console.log "Closing connection #{con.id}"
        return unless Observatory.DDPConnectionEmitter.de().isOn #and Observatory.settings.logDDP
        Observatory.DDPConnectionEmitter.connectionCount--
        msg = Observatory.DDPConnectionEmitter.messageStub()
        msg.connectionId = con.id
        msg.textMessage = "Closing connection #{con.id} from #{con.clientAddress}"
        msg.IP = con.clientAddress
        msg.object = totalConnections: Observatory.DDPConnectionEmitter.connectionCount
        msg.type = "DDPConnection:CLOSE"
        #msg.userId = @userId()
        # emitting message and putting to the buffer for the sake of Meteor logging. Insensitive loggers, such as Console,
        # should actually ignore this
        # console.dir msg
        #console.dir Observatory.MeteorInternals.getSessionCount()
        #console.log "Sessions: #{Observatory.MeteorInternals.getSessionCount()}"
        #console.log "Connections: #{Observatory.DDPConnectionEmitter.connectionCount}"
        Observatory.DDPEmitter.de().emitMessage msg, false
        Observatory.DDPConnectionEmitter.SessionsCollection.remove({connectionId: con.id})











(exports ? this).Observatory = Observatory