chai = require 'chai'
#console.log Meteor
should = chai.should()
#EventLogger = (require '../lib/EventLogger.coffee').Observatory.EventLogger
#DDPLogger = (require '../lib/server/DDPLogger.coffee').Observatory.DDPLogger

describe 'EventLogger - base class for system loggers (http, ddp...)', ->
  lg = new Observatory.EventLogger "newLogger"
  it 'should be created with empty buffer and name set correctly',->
    lg.logsBuffer.should.be.empty
    lg.name.should.equal "newLogger"
    #lg.func.should.equal null

  it 'should add buffer objects correctly, process them and reset buffer to empty',->
    obj1 = a: 'a', b: 1
    obj2 = a: 'a', b: 2
    lg.addObjectToBuffer obj1
    lg.addObjectToBuffer obj2
    lg.logsBuffer.length.should.equal 2
    lg.logsBuffer[0].should.equal obj1
    lg.logsBuffer[1].should.equal obj2
    lg.processBuffer (obj)->
      obj.a.should.equal 'a'
    lg.logsBuffer.should.be.empty


describe 'DDPLogger - logs ddp messages on the server', ->

  it 'should be created with empty buffer and name set to DDP',->
    lg = new Observatory.DDPLogger
    lg.logsBuffer.should.be.empty
    lg.name.should.equal "DDP"
    lg.func.should.exist