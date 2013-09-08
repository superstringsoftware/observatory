###################################################################################################
# Backward compatibility stuff!!!
# TLog is deprecated
####################################################################################################
  
class TLog
  @getLogger:-> 
    tb = Observatory.getToolbox()
    tb.dir = (obj, message, module)->
      msg = if message then message else "Inspecting object:"
      @_emitWithSeverity Observatory.LOGLEVEL.VERBOSE, msg, @inspect obj, module
    tb.setOptions = @setOptions
    tb
  @allowRemove: (f)-> Observatory.getMeteorLogger().allowRemove f
  @publish: (f)-> Observatory.meteorServer.publish f
  @_getLogs: (sort)-> Observatory.getMeteorLogger()._logsCollection.find {}, sort: timestamp: -1


  @LOGLEVEL_FATAL = 0
  @LOGLEVEL_ERROR = 1
  @LOGLEVEL_WARNING = 2
  @LOGLEVEL_INFO = 3
  @LOGLEVEL_VERBOSE = 4
  @LOGLEVEL_DEBUG = 5
  @LOGLEVEL_MAX = 6

  @LOGLEVEL_NAMES = [
    "fatal", "error", "warning", "info", "verbose", "debug", "max"
  ]
  @LOGLEVEL_NAMES_CAPS = [
    "FATAL", "ERROR", "WARNING", "INFO", "VERBOSE", "DEBUG", "MAX"
  ]
  @LOGLEVEL_NAMES_SHORT = [
    "ftl", "err", "wrn", "inf", "vrb", "dbg","max"
  ]

  # Set options for a logger
  #
  # @param [TLog enum] loglevel desired (see getLogger())
  # @param [Bool] whether to print to the console
  #
  @setOptions: (loglevel, want_to_print = true, log_user = true, log_http = true, log_DDP = true) ->
    settings = 
      maxSeverity: loglevel
      printToConsole: want_to_print
      logUser: log_user
      logHttp: log_http
      logDDP: log_DDP
    Observatory.setSettings settings
    

  
(exports ? this).TLog = TLog
#(exports ? this).Observatory = @Observatory
