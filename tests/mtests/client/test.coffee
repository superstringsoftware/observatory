
chai.should()

describe 'TLog class', ->
  it 'should be visible, have the global logs collection and log http by default',->
    #console.log TLog
    TLog.should.exist
    TLog._global_logs.should.exist
    TLog._log_http.should.be.true
  it 'should return the default logger and create the logs collection', ->
    tl = TLog.getLogger()
    tl.should.exist

    #task1.name.should.equal 'feed the cat'