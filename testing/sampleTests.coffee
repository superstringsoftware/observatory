#common tests
describe "Common test suite - run on both client and server",->
  foo1="bar"
  @it "this should pass", ->
    foo1.should.equal "bar"
  @it "this should fail", ->
    foo1.should.equal "bar1"


#client tests
if Meteor.isClient
  describe "Client only tests",->
    foo1="bar"
    @it "this should pass", ->
      foo1.should.equal "bar"
    @it "this should fail", ->
      foo1.should.equal "bar1"


#server tests
if Meteor.isServer
  describe "Server only tests",->
    foo1="bar"
    @it "this should pass", ->
      foo1.should.equal "bar"
    @it "this should fail", ->
      foo1.should.equal "bar1"
