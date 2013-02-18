###
unit = new MSuite('Test test')
unit.describe "Test test",->
  foo1="bar"
  @it "should equal bar", ->
    foo1.should.equal "bar"
  @it "should equal bar1", ->
    foo1.should.equal "bar1"

###
describe "Test suite",->
  foo1="bar"
  @it "this should pass", ->
    foo1.should.equal "bar"
  @it "this should fail", ->
    foo1.should.equal "bar1"

describe "Another test suite that is good",->
  @it "this should be ok",->
    true.should.equal true