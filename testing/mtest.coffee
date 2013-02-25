# Server part commented out for now as we only support client side

if Meteor.isServer
  try
    require = __meteor_bootstrap__.require
    chai = require 'chai'
    chai.should()
    expect = chai.expect
    chai.Assertion.includeStack = true
  catch err
    TLog.getLogger().error(err.message) if TLog

  #defining remote Meteor method to be called from the client when we want to run server tests
  Meteor.methods {
    runMServerTests: ->
      r = []
      suites = MTestFramework.suites
      for s in suites
        r.push(s.run())
      r
  }


if Meteor.isClient
  chai.should()
  expect = chai.expect
  chai.Assertion.includeStack = true

#unit of tests, you do something like:
# u = new MUnit
# u.describe "Test unit",->
# ... some common code ...
#   @it "should do this and this",->
#       ... assertion code ...
#and then it runs via u.run() recording the results in u.results
class MSuite
  constructor: (@name)->
    @results = []
    @testNumber = 0
    @successfulNumber = 0
    @failedNumber = 0

  describe: (name,func)->
    @suite_function = func

  #simply a wrapper around assertion statements into a try-catch block
  it: (name, func)->
    @testNumber++
    test_passed = true
    @successfulNumber++
    msg = ''
    try
      func()
    catch error
      msg += error.message
      test_passed = false
      @successfulNumber--
      @failedNumber++

    result = {passed: test_passed, message: msg, name: name}
    @results.push(result)


  run: ->
    @testNumber = 0 #resetting number of tests (= number of it functions called)
    @successfulNumber = 0
    @failedNumber = 0
    @results = [] #results of all tests ("it")
    success = true
    msg = ''
    #wrapping the whole "describe" call into try-catch
    try
      @suite_function()
      if @successfulNumber == 0
        success = false
        msg = "none of the tests completed"
    catch err
      msg = err.message
      success = false
    r =
      suiteName: @name
      results: @results
      success: success
      testNumber: @testNumber
      failed: @failedNumber
      successful: @successfulNumber
      message: msg


#static class that wraps previous 2 and allows for easier "describe" syntax
class MTestFramework
  @suites = []

  @describe: (name,func)->
    s = new MSuite(name)
    s.describe(name,func)
    MTestFramework.suites.push(s)


#aliasing "describe" so that we can use the simple syntaxis
describe = MTestFramework.describe



