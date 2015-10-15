describe 'Toolbox class', ->

  tb = Observatory.getToolbox()
  it 'should be ok', ->
    tb.should.exist

  describe 'Logging methods:', ->
    it "should call methods with all log levels, both ignoring the severity levels and respecting those", ->
      for m,i in ['fatal','error','warn','info','verbose','debug','insaneVerbose']
        tb.should.respondTo m
      for m,i in ['_fatal','_error','_warn','_info','_verbose','_debug','_insaneVerbose']
        tb.should.respondTo m


