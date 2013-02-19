_.extend Template.simple_tests,

  testResults: ->
    Session.get "_mtest_results"


  testResultClass: (p)->
    if p then "success" else "error"

  testResultPassed: (p)->
    if p then "PASSED" else "FAILED:"

  testResultClass1: (p)->
    if p then "text-success" else "text-error"

Template.simple_tests.events {
  'click #runMTests': ->
    r = []
    suites = MTestFramework.suites
    for s in suites
      r.push({suiteName: s.name, results: s.run()})

    Session.set "_mtest_results",r
}


