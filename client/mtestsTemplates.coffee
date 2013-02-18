_.extend Template.simple_tests,

  testResults: ->
    console.log "testResults called"
    results = []
    #console.dir unit.tests
    suites = MTestFramework.suites
    console.log suites.length
    for s in suites
      results.push({suiteName: s.name, results: s.run()})
    console.log results[0].results?.length
    results

  testResultClass: (p)->
    if p then "success" else "error"

  testResultPassed: (p)->
    if p then "PASSED" else "FAILED:"

  testResultClass1: (p)->
    if p then "text-success" else "text-error"

