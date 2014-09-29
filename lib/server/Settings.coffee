Observatory = @Observatory ? {}

#console.dir Observatory.SettingsCommon
# Settings
class Observatory.Settings extends Observatory.SettingsCommon

  @defaultServerSettings:
    logLevel: "INFO", printToConsole: false, logUser: true, logAnonymous: false,
    logHttp: true, logDDP: false, logBasicDDP: true, prohibitAutoPublish: false

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
      @col.insert({type: "SERVER", settings: Observatory.Settings.defaultServerSettings})
      @col.insert({type: "CLIENT_LOGGEDIN", settings: Observatory.Settings.defaultClientSettings})
      @col.insert({type: "CLIENT_ANONYMOUS", settings: Observatory.Settings.defaultClientSettings})

    if @col.find({type: "SERVER"}).count() is 0
      @col.insert({type: "SERVER", settings: Observatory.Settings.defaultServerSettings})

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
      #console.log "publishing settings #{@userId}"
      return if not Observatory.canRun.call(@)
      Observatory.SettingsCommon.col.find {}

  # returns current settings relevant for the environment in which it's called
  currentSettings: ->
    cs = @col.findOne({type: "SERVER"})
    #console.log cs
    cs.settings

  processSettingsUpdate: (s)->
    # printToConsole and loglevel are handled by super() call
    super s
    if s.logBasicDDP
      Observatory.emitters.DDPConnection.turnOn()
    else
      Observatory.emitters.DDPConnection.turnOff()
    if s.logDDP
      Observatory.emitters.DDP.turnOn()
    else
      Observatory.emitters.DDP.turnOff()
    if s.logHttp
      Observatory.emitters.Http.turnOn()
    else
      Observatory.emitters.Http.turnOff()

    # anonymous & client calls in general
    # this is somewhat dangerous as anonymous users can mess up the collection (but only inserting stuff, so not really)
    if @currentSettings().logAnonymous
      Observatory._meteorLogger.allowInsert = -> true
    else
      if @currentSettings().logUser
        Observatory._meteorLogger.allowInsert = (uid) -> if uid? then true else false
      else
        Observatory._meteorLogger.allowInsert = -> false









######################################################################################################
  # Settings changing functions
  ######################################################################################################

(exports ? this).Observatory = Observatory