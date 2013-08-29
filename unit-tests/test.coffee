chai = require 'chai'
#console.log Meteor
should = chai.should()

describe 'TLog class', ->
  #TLog = TLogModule.TLog
  #console.dir TLog
  tl = TLog.getLogger()
  it 'should be visible, have the global logs collection and log http by default',->
    #console.log TLog
    TLog.should.exist
    TLog._global_logs.should.exist
    TLog._log_http.should.be.true
    TLog._connectLogsBuffer.should.be.empty
  it 'should return the default logger with correct defaults', ->
    tl.should.exist
    tl.should.be.an.instanceof TLog
    tl._currentLogLevel.should.equal TLog.LOGLEVEL_DEBUG
    tl._log_user.should.be.true
    tl._printToConsole.should.be.false
  it 'should add http logs to buffer and clean them after processing',->
    httpLog =
      timestamp: new Date
    TLog.addToLogsBuffer(httpLog)
    TLog._connectLogsBuffer.length.should.equal 1
    TLog._connectLogsBuffer[0].should.equal httpLog
    TLog.checkConnectLogsBuffer()
    TLog._connectLogsBuffer.should.be.empty


  describe 'Logging methods:', ->
    it "should call methods with all log levels", ->
      for m,i in ['fatal','error','warn','info','verbose','debug','insaneVerbose']
        tl.should.respondTo m
        tl[m] "Logging #{TLog.LOGLEVEL_NAMES[i]} message", "TESTS"
      for m,i in ['trace','dir']
        tl.should.respondTo m
        tl[m] new Error("Test Error"), "Message for #{m}"

    