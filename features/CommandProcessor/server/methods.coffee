# Externally exposed APIs, as usual in the Observatory suite
Observatory = @Observatory ? {}

# Observatory specific initialization
Observatory.registerInitFunction (s)->
  Observatory.commandServer = new Observatory.CommandServer
  Observatory.commandServer.publishAdmin()
  Observatory.commandServer.publishLocal()

# API itself - only one method
Meteor.methods
  # taking reponse to a command (typically), although can be more versatile
  _observatoryTakeResponse: (sessionId, response)->
    #console.log "_observatoryTakeResponse called on the SERVER"
    #console.log Observatory.commandServer
    #console.log sessionId, response
    Observatory.commandServer.sendCommandResponse sessionId, response

