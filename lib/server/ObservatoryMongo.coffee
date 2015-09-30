Observatory = @Observatory ? {}
Fiber = Npm.require 'fibers'

#Mongo native instance for getting all info
class Observatory.Mongo
  constructor: ->
    @_db = new Meteor.Collection('_dummy').find()._mongo.db

  getCollections: ->
    db = @_db
    f = Meteor.wrapAsync (cb) ->
      db.listCollections cb
    f()

  getStats: ->
    db = @_db
    f = Meteor.wrapAsync (cb) ->
      db.stats cb
    f()


  collectionCount: ->
    collections = @getCollections()
    collections.length or 0

(exports ? this).Observatory = Observatory
