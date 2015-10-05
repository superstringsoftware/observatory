Observatory = @Observatory ? {}


class Observatory.CommandServer

  constructor: ->
    # commands collection, will be published to Vega and will accept incoming commands
    @col = new Mongo.Collection "_observatory_commands"
    @col.allow
      insert: (uid,doc)-> Observatory.canRun uid
      remove: (uid,doc)-> Observatory.canRun uid

    #@col.remove {} # cleaning up at startup

    # non-persistent collection published to Vega where we will put command responses
    @colCommandResponses = new Mongo.Collection null

  # publishing commands collection to vega to further observe and send commands to local clients
  publishAdmin: ->
    # TODO: need to think whether to publish all the command history here
    # publishing collection that will accept incoming commands from Vega
    col = @col
    Meteor.publish "_observatory_commands", ->
      return if not Observatory.canRun.call(@) # only publishing to observatory admins
      col.find {}, {limit:50}

    # setting up a watcher on the commands collection to catch server commands and handle them.
    # client commands are processed in publishLocal() below
    handle = col.find({server: true}).observe {
      added: (doc)=> @_processCommand doc
    }


    # publishing command responses to Vega - will be processed in Vega, not here, so just passing the response
    col1 = @colCommandResponses
    Meteor.publish "_observatory_command_responses", ->
      return if not Observatory.canRun.call(@) # only publishing to observatory admins
      _self = this
      handle = col1.find().observe {
        added: (doc)=>
          @added('_observatory_command_responses', doc._id, doc) #unless initializing

      }
      #initializing = false
      _self.ready()
      _self.onStop = -> handle.stop()
      return

  # publishes commands to a specific local client
  # -- we are observing cursor on _observatory_commands and once a new command comes
  # related to a specific sessionId - publishing it to the client
  # TODO: describe format of the command
  publishLocal: ->
    col = @col
    Meteor.publish '_observatory_local_commands', (options) ->
      #console.log "_observatory_local_commands subscribing with uid", options
      _self = this
      handle = col.find({sessionId: options.sessionId}).observe {
        added: (doc)=>
          #console.log "Added to commands", doc
          @added('_observatory_local_commands', doc._id, doc)
      }
      #initializing = false
      _self.ready()
      _self.onStop = -> handle.stop()
      return

  # this is called from one of Meteor.methods (see methods.coffee)
  sendCommandResponse: (sessionId, response)-> @colCommandResponses.insert {sessionId: sessionId, response: response}

  # processes server command
  _processCommand: (cmd)->
    #console.log "Processing server command", cmd
    tb = Observatory.getToolbox()
    accessor = cmd.command.split('.')
    t = global
    t = t[accessor[i]] for i in [0...accessor.length] if cmd.command isnt 'global'
    @colCommandResponses.insert {server: true, response: {command: cmd, response: tb.inspect t} }