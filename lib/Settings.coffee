Observatory = @Observatory ? {}

# Settings
class Observatory.SettingsCommon
  @defaultClientSettings:
    logLevel: "ERROR", printToConsole: false, logUser: true, logAnonymous: true

  # settings collection
  @col: new Mongo.Collection('_observatory_settings')

  processSettingsUpdate: (s) -> Observatory.setSettings(s)

  currentSettings: -> throw new Error "SettingsCommon::currentSettings - needs overloading and should not be called directly"


(exports ? this).Observatory = Observatory