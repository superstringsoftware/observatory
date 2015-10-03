Observatory = @Observatory ? {}


class Observatory.CommandServer

  constructor: ->
    # commands collection, will be published to Vega
    @col = new Mongo.Collection "_observatory_commands"
    @col.allow
      insert: (uid,doc)-> Observatory.canRun uid
      remove: (uid,doc)-> Observatory.canRun uid

  # publishing commands collection to vega to further observe and send commands to local clients
  publishAdmin: ->
    # TODO: need to think whether to publish all the command history here
    col = @col
    Meteor.publish "_observatory_commands", ->
      return if not Observatory.canRun.call(@) # only publishing to observatory admins
      col.find {}

  # this is a more important function that publishes commands to a specific local client
  # -- we are observing cursor on _observatory_commands and once a new command comes
  # related to a specific uid or cid - publishing it to the client
  # FIXME: for now, only takes userId and ignores session / connection Id, need to rethink
  publishLocal: ->
    col = @col
    Meteor.publish '_observatory_local_commands', (uid, cid) ->
      _self = this
      handle = col.find({userId: uid}).observe {
        added: (doc)=>
          @added('_observatory_local_commands', doc._id, doc)
      }
      #initializing = false
      _self.ready()
      _self.onStop = -> handle.stop()
      return