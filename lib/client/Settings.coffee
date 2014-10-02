Observatory = @Observatory ? {}

# Settings
class Observatory.Settings extends Observatory.SettingsCommon

  constructor: ->
    @col = Observatory.SettingsCommon.col
    @processSettingsUpdate @currentSettings()
    # observing the settings changes and rerunning the setup
    @col.find().observe {
      changed: (newDoc, oldDoc)=>
        @processSettingsUpdate(newDoc.settings)

    }
    # autorunning to make sure of re-subscription if the user id changes
    Meteor.startup =>
      Tracker.autorun =>
        uid = if Accounts? then Meteor.userId() else null
        @sub = Meteor.subscribe '_observatory_settings', {uid: uid, connectionId: Meteor.connection._lastSessionId}, {
          onError: (err)->
            console.log err
          onReady: =>
            newS = @currentSettings()
            @processSettingsUpdate(newS)
        }

  ready: -> @sub.ready()

  processSettingsUpdate: (s)->
    super s
    #console.log s

  currentSettings: -> @col.findOne()?.settings ? Observatory.SettingsCommon.defaultClientSettings


(exports ? this).Observatory = Observatory