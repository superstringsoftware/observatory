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

    f2 = Meteor.wrapAsync (cb) ->
      db.collectionNames cb

    cols = f()
    try
      ret = (f1(c) for c in cols)
      ret
    catch
      ret = f2()
      ret


  getStats: ->
    db = @_db
    f = Meteor.wrapAsync (cb) ->
      db.stats cb
    st = f()
    st.url = db.options.url
    st


  collectionCount: ->
    collections = @getCollections()
    collections.length or 0

(exports ? this).Observatory = Observatory
