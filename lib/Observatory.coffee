# COMMON

Observatory = @Observatory ? {}

###
Settings format:

{
    "public": {
        "observatorySettings": {
            "logsCollectionName": "_observatory_logs",
            "logLevel": "DEBUG",
            "printToConsole": true,
            "logUser": true,
            "logHttp": true,
            "logDDP": true,
            "prohibitAutoPublish": false
        }
    }
}
###

# This is KEY for handshakes and stuff
Observatory.version = 
  major: 0
  minor: 4
  patch: 5

# changing server definition function to meteor specific
Observatory.isServer = -> Meteor.isServer
# defining getter for the meteor logger
Observatory.getMeteorLogger = -> Observatory._meteorLogger

Observatory.initialize()


(exports ? this).Observatory = Observatory