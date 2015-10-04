Observatory = @Observatory ? {}

# processing commands coming from the server and sending the results back
# slightly tricky architecture:
# Obs Client in the APP <--------------> Obs Server in the APP <-----------------> Vega client
# and then it's even more tricky:
# in ObsSrv there will be a persistent _observatory_commands_collection
# From Vega, we will send commands - insert into _observatory_commands_collection with userId, sessionId etc
# in ObsSrv, we will observe() this collection and once there's a new command -->
# call @added inside the publish function for the ObsClient _observatory_local_commands collection
# in ObsClient, we will subscribe to this collection and when a new command comes - process it (similar to what's going on in Settings)
# NOTE: yes, can simplify:
# just use the same collection name and publish it with userid and connectionid, this way don't need to fiddle with
# observing cursors as whatever we insert from Vega client will be published to correct clients automatically
# just need to make sure insert allow is defined correctly - only if Observatory.canRun(), but not for local clients
# how do we pass responses to commands though? In the logs collection?? or as a method call?
# in a separate collection?? e.g., "command_responses" or something?
# Logs is preferable as it already defines security for anonymous vs others etc.

class Observatory.CommandClient

  constructor: ->
    @_col = new Mongo.Collection "_observatory_local_commands"

    # subscribing to commands with specific user and session Ids for granular support
    Tracker.autorun =>
      uid = if Accounts? then Meteor.userId() else null
      @sub = Meteor.subscribe '_observatory_local_commands', {sessionId: Observatory.lastSessionId()}, {
        onReady: =>
          console.log "_observatory_local_commands ready"
      }

    @_handle = @_col.find({}).observe {
      added: (doc)=>
        #console.log "Added to commands", doc
        @processCommand doc
    }

  # TODO: getObject needs some thinking, as logging an Object with functions is impossible and EJSON.stringify fails on them as well.
  processCommand: (cmd)->
    tb = Observatory.getToolbox()
    console.log "received new command: ", cmd
    switch cmd.command
      when "getObject" # command that returns any object from the client (in theory)
        tb.info("Response to the command", window[cmd.options.name], "COMMANDS")
