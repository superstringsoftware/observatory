if Meteor.isServer
  require = if Npm? then Npm.require else __meteor_bootstrap__.require
  Fiber = require 'fibers'
else
  # stub for the client
  Fiber = (fn)->
    run:->fn()

should = chai.should()

describe 'TLog class', ->
  tl = TLog.getLogger()
  TLog._clear() if Meteor.isServer
  it 'should be visible, have the global logs collection and log http by default',->
    #console.log TLog
    TLog.should.exist
    TLog._global_logs.should.exist
    TLog._log_http.should.be.true
  it 'should return the default logger with correct defaults', ->
    tl.should.exist
    tl.should.be.an.instanceof TLog
    tl._currentLogLevel.should.equal TLog.LOGLEVEL_DEBUG
    tl._log_user.should.be.true
    tl._printToConsole.should.be.false

  describe 'Logging methods:', ->
    it "should call methods with all log levels", ->
      for m,i in ['fatal','error','warn','info','verbose','debug','insaneVerbose']
        tl.should.respondTo m
        tl[m] "Logging #{TLog.LOGLEVEL_NAMES[i]} message", "TESTS"
      for m,i in ['trace','dir']
        tl.should.respondTo m
        tl[m] new Error("Test Error"), "Message for #{m}"

    # TODO: if something fails inside the Fiber, everything breaks, need to figure out how to resume execution flow
    it 'should log the message to the database correctly', (done)->
      obj =
        message: "Logging #{TLog.LOGLEVEL_NAMES[TLog.LOGLEVEL_INFO]} message"
        full_message: "Logging #{TLog.LOGLEVEL_NAMES[TLog.LOGLEVEL_INFO]} FULL message"
        module: "TESTS"
        timestamp: new Date
        isServer: Meteor.isServer
      customOptions = {cust1: "cust1", cust2: 10}

      rec = null
      # need to wrap this in Fiber in Meteor...
      f = new Fiber ->
        tl._lowLevelLog TLog.LOGLEVEL_INFO, obj, customOptions, (err, id)->
          if (err) then throw err
          rec = TLog._global_logs.findOne id
          #console.dir rec
          rec.should.exist
          obj.message.should.equal rec.message
          obj.full_message.should.equal rec.full_message
          obj.module.should.equal rec.module
          obj.timestamp.should.eql rec.timestamp
          obj.isServer.should.equal rec.isServer
          rec.customOptions.should.deep.equal customOptions
          done()

      f.run()
      #done()




