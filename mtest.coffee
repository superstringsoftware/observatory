if Meteor.isServer
  require = __meteor_bootstrap__.require
  chai = require 'chai'
  chai.Assertion.includeStack = true

if Meteor.isClient
  chai.should()
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

  describe: (name,func)->
    @suite_function = func

  #simply a wrapper around assertion statements into a try-catch block
  it: (name, func)->
    test_passed = true
    msg = ''
    try
      func()
    catch error
      msg += error.message
      test_passed = false

    result = {passed: test_passed, message: msg, name: @name}
    @results.push(result)


  run: ->
    @results = []
    @suite_function()
    @results

#static class that wraps previous 2 and allows for easier "describe" syntax
class MTestFramework
  @suites = []

  @describe: (name,func)->
    s = new MSuite(name)
    s.describe(name,func)
    MTestFramework.suites.push(s)


#aliasing "describe" so that we can use the simple syntaxis
describe = MTestFramework.describe



