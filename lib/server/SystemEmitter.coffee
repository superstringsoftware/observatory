Observatory = @Observatory ? {}

class Observatory.SystemEmitter extends @Observatory.MessageEmitter
  #FIXME: _collection param: need create collection manager (I can't create few collection with the same name)
  # @param {String} name
  # @param {Mongo.Collection object} _collection
  constructor: (@name, @_collection) ->
    throw new Error "SystemEmitter constructor: param `Collection` is not defined" unless @_collection
    super @name
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
    module: "SYSTEM"
    timestamp: new Date
    textMessage: message

  log: (message) ->
    return console.log 'System emitter should be run in the server' if Meteor.isClient
    @_collection.insert message

(exports ? this).Observatory = Observatory
