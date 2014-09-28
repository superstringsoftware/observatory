Observatory = @Observatory ? {}

#console.dir Observatory.SettingsCommon
# Settings
class Observatory.Settings extends Observatory.SettingsCommon

  @defaultServerSettings:
    logLevel: "INFO", printToConsole: false, logUser: true, logAnonymous: false,
    logHttp: true, logDDP: false, prohibitAutoPublish: false

  constructor: ->
    #console.log "constructor called"
    @col = Observatory.SettingsCommon.col
    @col.allow
      insert: (uid, doc) -> Observatory.canRun(uid)
      update: (uid, doc, fields, modifier) -> Observatory.canRun(uid)
      # TODO: for removal, need to make sure SERVER, CLIENT and ANONYMOUS can't be deleted
      remove: (uid, doc) -> Observatory.canRun(uid) and doc.type not in ["SERVER", "CLIENT_LOGGEDIN", "CLIENT_ANONYMOUS"]
    #console.log this
    # every startup checking that the databse contains at least the key stuff
    @loadSettings()
    # observing if our SERVER values change so that we process these changes
    @col.find({type: "SERVER"}).observe {
      changed: (newDoc, oldDoc)=>
        #console.log this
        @processSettingsUpdate(newDoc.settings)

      removed: (doc)=>
        throw new Meteor.Error 78, "SERVER settings removed: this SHOULD NOT be happening!"
    }

  needsSetup: ->
    if @col.find({initialSetupComplete: true}).count()>0 then false else true
  setupComplete: ->
    @col.insert({initialSetupComplete: true})

  loadSettings: ->
    # first run in the app - filling collection with defaults (initial setup)
    if @col.find().count() is 0
      @col.insert({type: "SERVER", settings: @defaultServerSettings})
      @col.insert({type: "CLIENT_LOGGEDIN", settings: @defaultClientSettings})
      @col.insert({type: "CLIENT_ANONYMOUS", settings: @defaultClientSettings})

    if @col.find({type: "SERVER"}).count() is 0
      @col.insert({type: "SERVER", settings: @defaultServerSettings})

    @currentSettings()

  publishLocal: ->
    Meteor.publish '_observatory_settings', (opts)->
      #console.log 'publishing settings'
      # for now, no granularity, only anon vs logged in
      if @userId then Observatory.SettingsCommon.col.find {type: "CLIENT_LOGGEDIN"} else Observatory.SettingsCommon.col.find {type: "CLIENT_ANONYMOUS"}

  publishAdmin: ->
    # TODO: rethink naming, as now Vega won't be able to monitor itself on the client (maybe that's ok)
    Meteor.publish '_observatory_settings_admin', (opts)->
      #console.log @
      console.log "publishing settings #{@userId}"
      return if not Observatory.canRun.call(@)
      Observatory.SettingsCommon.col.find {}

  # returns current settings relevant for the environment in which it's called
  currentSettings: ->
    cs = @col.findOne({type: "SERVER"})
    #console.log cs
    cs.settings

  ######################################################################################################
  # Settings changing functions
  ######################################################################################################

(exports ? this).Observatory = Observatory