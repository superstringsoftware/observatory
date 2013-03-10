_.extend Template.simple_tests,

  created: ->
    Session.set "_mtest_results",null
    Session.set "_mservertest_results",null

  testResults: ->
    Session.get "_mtest_results"

  testServerResults: ->
    Session.get "_mservertest_results"

  testResultClass1: (p)->
    if p then "success" else "error"

  testResultPassed: (p)->
    if p then "PASSED" else "FAILED:"

  testResultClass: (p)->
    if p then "text-success" else "text-error"

Template.simple_tests.events
  # processing client and common tests
  'click #runMTests': ->
    r = []
    suites = MTestFramework.suites
    for s in suites
      r.push(s.run())

    Session.set "_mtest_results",r

  'click #runServerMTests': ->
    #alert 'Clicked run server tests'
    Meteor.call 'runMServerTests',(error,result)->
      if !error
        Session.set "_mservertest_results",result
      else
        # need to indicate there's an error running server tests!!!
        Session.set "_mservertest_results",null




