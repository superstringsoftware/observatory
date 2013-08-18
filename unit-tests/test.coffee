chai = require 'chai'  
should = chai.should() 

describe 'TLog class', ->
  #console.dir TLog.TLog
  TLogModule = require '../TLog'
  TLog = TLogModule.TLog
  tl = TLog.getLogger()
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
   it 'should be a singleton', ->
   	tl1 = new TLog
   	tl.should.equal tl1

  describe 'Logging methods:', ->
    it "should call methods with all log levels", ->
      for m,i in ['fatal','error','warn','info','verbose','debug','insaneVerbose']
        tl.should.respondTo m
        tl[m] "Logging #{TLog.LOGLEVEL_NAMES[i]} message", "TESTS"
      for m,i in ['trace','dir']
        tl.should.respondTo m
        tl[m] new Error("Test Error"), "Message for #{m}"

    