Observatory = @Observatory ? {}

###
  DANGER ZONE!!!
  hooking up into new Mongo.Collection() calls
  it was IMPOSSIBLE to do directly due to complicated prototype chain checking inside meteor code,
  but this turned out to be a MUCH easier and lightweight solution:

  wrapping Mongo.Collection.prototype._defineMutationMethods method which is called from the constructor.

  Now we have access to ALL created collections server side, but need to watch for meteor code changes.
###
Mongo.Collection::_defineMutationMethods = _.wrap Mongo.Collection::_defineMutationMethods, (f)->
  args = _.rest arguments
  #console.log "_defineMutationMethods called inside ", this._name
  Observatory.Mongo.collections[this._name] = this unless this._name is null
  f.apply this, args


#Mongo native instance for getting all info
class Observatory.Mongo
  @collections: {}
  constructor: ->
    #@_db = new Meteor.Collection('_dummy').find()._mongo.db
    @_db = Observatory._meteorLogger._logsCollection.rawDatabase()
    @_col = Observatory._meteorLogger._logsCollection.rawCollection()
    Observatory.Mongo.collections.users = Meteor.users if Meteor.users?

    ###
    @_db.executeDbAdminCommand {"hostInfo" : 1}, (err, res)->
      console.log err
      console.log res.documents[0]

    ###


  # Rewrote this method to use only Mongo.Collections, NOT going to the database to get names first -
  # as it fails depending on monbodb permissions, plus -
  # we want to have a separate mongodb management functionality anyway eventually
  ###
    avgObjSize: 1008
    count: 2
    indexSizes: Object
    lastExtentSize: 8192
    nindexes: 10
    ns: "users"
    numExtents: 1
    ok: 1
    paddingFactor: 1
    should: (...)
    size: 2016
    storageSize: 8192
    systemFlags: 1
    totalIndexSize: 81760
    userFlags: 1
  ###
  getCollections: ->
    ret = []
    for k, v of Observatory.Mongo.collections
      r =
        meteorName: k
        ns: k
        count: v.find().count()
      f1 = Meteor.wrapAsync v.rawCollection().stats, v.rawCollection()
      try
        r1 = f1 v.rawCollection()
        _.extend r, r1
      catch ex
      ret.push r
    ret


  # TODO: add proper error handling / logging in the async wrapper!
  getCollectionsOLD: ->
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
