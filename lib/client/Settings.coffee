Observatory = @Observatory ? {}

# Settings
class Observatory.Settings extends Observatory.SettingsCommon

  constructor: ->
    @col = Observatory.SettingsCommon.col
    # autorunning to make sure of re-subscription if the user id changes
    Meteor.startup =>
      Tracker.autorun =>
        @sub = Meteor.subscribe '_observatory_settings', {uid: Meteor.userId(), connectionId: Meteor.connection._lastSessionId}, {
          onError: (err)->
            console.log err
          onReady: =>
            newS = @currentSettings()
            @processSettingsUpdate(newS)
        }

  ready: -> @sub.ready()

  currentSettings: -> @col.findOne()?.settings #? Observatory.SettingsCommon.defaultClientSettings


(exports ? this).Observatory = Observatory