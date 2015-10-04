Observatory = @Observatory ? {}


class Observatory.CommandServer

  constructor: ->
    # commands collection, will be published to Vega
    @col = new Mongo.Collection "_observatory_commands"
    @col.allow
      insert: (uid,doc)-> Observatory.canRun uid
      remove: (uid,doc)-> Observatory.canRun uid

    # non-persistent collection published to Vega where we will put command responses
    @colCommandResponses = new Mongo.Collection null

  # publishing commands collection to vega to further observe and send commands to local clients
  publishAdmin: ->
    # TODO: need to think whether to publish all the command history here
    col = @col
    Meteor.publish "_observatory_commands", ->
      return if not Observatory.canRun.call(@) # only publishing to observatory admins
      col.find {}

    # publishing command responses to Vega
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

  # this is a more important function that publishes commands to a specific local client
  # -- we are observing cursor on _observatory_commands and once a new command comes
  # related to a specific uid or cid - publishing it to the client
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