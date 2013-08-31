# Logs DDP messages on the server
Observatory = if Observatory? then Observatory else {}

class Observatory.DDPLogger extends Observatory.EventLogger
  constructor: ->
    super "DDP", (obj)->
      tl = TLog.getLogger()
      options =
        isServer: true
        message: obj.msg
        module: "DDP"
        timestamp: obj.timestamp
      full_message = tl._formatLogMessage options
      options.full_message = full_message
      tl._lowLevelLog TLog.LOGLEVEL_DEBUG, options, l
      console.log full_message if tl._printToConsole


(exports ? this).Observatory = Observatory