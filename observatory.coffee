# Class that hanles all the logging logic 
#
# @example Getting a logger that will print only WARNING and more severe messages both to db and console:
#     TL = TLog.getLogger(TLog.LOGLEVEL_WARNING, true)
#
class TLog
  @_instance = undefined

  @_global_logs = new Meteor.Collection '_observatory_logs'

  #very insecure, yes. For now this is the only dependency on auth branch so "?" let's us take care of this silently.
  # TODO: make this configurable 
  @_global_logs.allow? {
    insert:
      () -> true
    update: ->
      false
    remove: ->
      true
  }

  # Get a logger with options
  #
  # @param [TLog enum] loglevel desired loglevel, one of TLog.LOGLEVEL_FATAL,TLog.LOGLEVEL_ERROR,TLog.LOGLEVEL_WARNING,TLog.LOGLEVEL_INFO,TLog.LOGLEVEL_VERBOSE
  # @param [Bool] want_to_print if true, log messages will be printed to the console as well
  #
  @getLogger: (loglevel = TLog.LOGLEVEL_MAX, want_to_print = true)->    
    @_instance?=new TLog(loglevel,want_to_print, false)
    @_instance.verbose("getLogger() called","TLog")
    @_instance

  @LOGLEVEL_FATAL = 0
  @LOGLEVEL_ERROR = 1
  @LOGLEVEL_WARNING = 2
  @LOGLEVEL_INFO = 3
  @LOGLEVEL_VERBOSE = 4
  @LOGLEVEL_MAX = 5

  @limit = 300

  @LOGLEVEL_NAMES = [
    "FATAL", "ERROR", "WARNING", "INFO", "VERBOSE", "MAX"
  ]
  @LOGLEVEL_NAMES_SHORT = [
    "FTL", "ERR", "WRN", "INF", "VRB", "MAX"
  ]

  constructor: (@_currentLogLevel, @_printToConsole, show_warning = true)->
    @_logs = TLog._global_logs
    if Meteor.isServer
      Meteor.publish '_observatory_logs',()->
        TLog._global_logs.find {}, {sort: {timestamp: -1}, limit:TLog.limit}
    if Meteor.isClient
      Meteor.subscribe('_observatory_logs')
    @warn("You should use TLog.getLogger(loglevel, want_to_print) method instead of a constructor! Constructor calls may be removed 
      in the next versions of the package.") if show_warning


  # Set options for a logger
  #
  # @param [TLog enum] loglevel desired (see getLogger())
  # @param [Bool] whether to print to the console
  #
  setOptions: (loglevel, want_to_print = true) ->
    if (loglevel>=0) and (loglevel<=3)
      @_currentLogLevel = loglevel
    @_printToConsole = want_to_print

  # Main logging methods:
  fatal: (msg, module)->
    @_log(msg,TLog.LOGLEVEL_FATAL,module)

  error: (msg, module)->
    @_log(msg,TLog.LOGLEVEL_ERROR, module)

  warn: (msg, module)->
    @_log(msg,TLog.LOGLEVEL_WARNING, module)

  info: (msg, module)->
    @_log(msg,TLog.LOGLEVEL_INFO, module)

  verbose: (msg, module)->
    @_log(msg,TLog.LOGLEVEL_VERBOSE, module)

  currentLogLevelName: ->
    TLog.LOGLEVEL_NAMES[@_currentLogLevel]

  logCount: ->
    @_logs.find({}).count()

  #internal method doing the logging
  _log: (msg, loglevel = 3, mdl) ->

    if loglevel <= @_currentLogLevel
      srv = false
      if Meteor.is_server 
        srv = true
      
      module = mdl
      timestamp = new Date()
      ts = @_ps(TLog._convertDate(timestamp)) + @_ps(TLog._convertTime(timestamp))
      full_message = if srv then ts + "[SERVER]" else ts + "[CLIENT]"
      full_message+= if module then @_ps module else "[]"
      full_message+= @_ps(TLog.LOGLEVEL_NAMES[loglevel]) #TODO: RANGE CHECK!!!
      full_message+= ' ' + msg
      @_logs.insert
        isServer: srv
        message: msg
        module: module
        loglevel: loglevel
        timestamp_text: ts
        timestamp: timestamp.getTime()
        full_message: full_message

      console.log(full_message) if @_printToConsole

  _convertTimestamp: (timestamp)->
    st = timestamp.getUTCDate() + '/' + timestamp.getUTCMonth() + '/'+timestamp.getUTCFullYear() + ' ' +
      timestamp.getUTCHours()+ ':' + timestamp.getUTCMinutes() + ':' + timestamp.getUTCSeconds() + '.' + timestamp.getUTCMilliseconds()

  @_convertDate: (timestamp)->
    st = timestamp.getUTCDate() + '/' + timestamp.getUTCMonth() + '/'+timestamp.getUTCFullYear()

  @_convertTime: (timestamp, ms=true)->
    ts = timestamp.getUTCHours()+ ':' + timestamp.getUTCMinutes() + ':' + timestamp.getUTCSeconds() 
    ts += '.' + timestamp.getUTCMilliseconds() if ms
    ts

  _ps: (s)->
    '['+s+']'

  @_getLogs: (sort)->
    if sort
      @_global_logs.find({}, sort: sort)
    else
      @_global_logs.find {}, sort: {timestamp: -1}

  #Ouch! This should be really protected once auth is figured out.
  @_clear: ->
    @_global_logs.remove {}



