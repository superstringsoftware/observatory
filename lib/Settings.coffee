Observatory = @Observatory ? {}

# Settings
class Observatory.SettingsCommon
  @defaultClientSettings:
    logLevel: "INFO", printToConsole: false, logUser: true, logAnonymous: false

  # settings collection
  @col: new Mongo.Collection('_observatory_settings')

  currentSettings: -> throw new Error "SettingsCommon::currentSettings - needs overloading and should not be called directly"


(exports ? this).Observatory = Observatory