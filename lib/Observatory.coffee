# COMMON

Observatory = @Observatory ? {}

# This is KEY for handshakes and stuff
Observatory.version =
  major: 0
  minor: 9
  patch: 2
  prerelease: [] #'rc', 1
  wrapNum: 0

# changing server definition function to meteor specific
Observatory.isServer = -> Meteor.isServer
# defining getter for the meteor logger
Observatory.getMeteorLogger = -> Observatory._meteorLogger

Observatory.initialize()

Observatory.SYSTEM_DEBUG = true # whether we are debugging observatory itself: TODO: set to FALSE before publishing to atmosphere!!!

(exports ? this).Observatory = Observatory