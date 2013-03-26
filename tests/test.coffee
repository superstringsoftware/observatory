#chai = require 'chai'
#sinon = require 'sinon'
#chai.should()

#Meteor = sinon.spy()

#require = if require then require else if Npm? then Npm.require else __meteor_bootstrap__.require
#Meteor = require './tests/MeteorStub'
#TLog = require '../../TLog'

# Meteor stubs

describe 'Testing TLog', =>
  it 'should be created', =>
    logger = new TLog
