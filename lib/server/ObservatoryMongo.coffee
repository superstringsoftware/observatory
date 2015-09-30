Observatory = @Observatory ? {}
Fiber = Npm.require 'fibers'

#Mongo native instance for getting all info
class Observatory.Mongo
  constructor: ->
    #@_db = new Meteor.Collection('_dummy').find()._mongo.db
    @_db = Observatory._meteorLogger._logsCollection.rawDatabase()
    @_col = Observatory._meteorLogger._logsCollection.rawCollection()


  # TODO: add proper error handling / logging in the async wrapper!
  getCollections: ->
    db = @_db
    f = Meteor.wrapAsync (cb) ->
      db.collections cb
    f1 = Meteor.wrapAsync (col, cb) ->
      col.stats cb
    cols = f()
    (f1(c) for c in cols)

  getStats: ->
    db = @_db
    f = Meteor.wrapAsync (cb) ->
      db.stats cb
    f()


  collectionCount: ->
    collections = @getCollections()
    collections.length or 0

(exports ? this).Observatory = Observatory
