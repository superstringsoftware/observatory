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
    f = Meteor.wrapAsync @_db.collections, @_db
    f2 = Meteor.wrapAsync @_db.collectionNames, @_db

    try
      ret = []
      for c in f()
        f1 = Meteor.wrapAsync c.stats, c
        r1 = f1(c)
        #console.log r1
        # taking out db name from collection name
        name = r1.ns.split '.'
        name.shift()
        ns = name.join '.'
        r1.ns = ns
        ret.push r1
      ret
    catch
      ret = f2()
      ret


  getStats: ->
    db = @_db
    st = Meteor.wrapAsync(db.stats, db)()
    st.url = db.options.url
    st


  collectionCount: ->
    collections = @getCollections()
    collections.length or 0

(exports ? this).Observatory = Observatory
