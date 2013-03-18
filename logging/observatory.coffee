# Class that hanles all the logging logic 
#
# @example Getting a logger that will print only WARNING and more severe messages both to db and console:
#     TL = TLog.getLogger(TLog.LOGLEVEL_WARNING, true)
#
class TLog
  @_instance = undefined

  @_global_logs = new Meteor.Collection '_observatory_logs'

  # Get a logger with options
  #
  # @param [TLog enum] loglevel desired loglevel, one of TLog.LOGLEVEL_FATAL,TLog.LOGLEVEL_ERROR,TLog.LOGLEVEL_WARNING,TLog.LOGLEVEL_INFO,TLog.LOGLEVEL_VERBOSE
  # @param [Bool] want_to_print if true, log messages will be printed to the console as well
  #
  @getLogger: (loglevel = TLog.LOGLEVEL_INFO, want_to_print = true, log_user = false)->
    @_instance?=new TLog(loglevel,want_to_print, log_user, false)
    #@_instance.insaneVerbose("getLogger() called","TLog")
    @_instance.setOptions loglevel, want_to_print
    @_instance

  @LOGLEVEL_FATAL = 0
  @LOGLEVEL_ERROR = 1
  @LOGLEVEL_WARNING = 2
  @LOGLEVEL_INFO = 3
  @LOGLEVEL_VERBOSE = 4
  @LOGLEVEL_DEBUG = 5
  @LOGLEVEL_MAX = 6

  @limit = 300

  @LOGLEVEL_NAMES = [
    "FATAL", "ERROR", "WARNING", "INFO", "VERBOSE", "DEBUG", "MAX"
  ]
  @LOGLEVEL_NAMES_SHORT = [
    "FTL", "ERR", "WRN", "INF", "VRB", "DBG","MAX"
  ]

  constructor: (@_currentLogLevel, @_printToConsole, @_log_user = false, show_warning = true)->
    @_logs = TLog._global_logs
    if Meteor.isServer
      Meteor.publish '_observatory_logs',->
        TLog._global_logs.find {}, {sort: {timestamp: -1}, limit:TLog.limit}
      #very insecure, yes. For now this is the only dependency on auth branch so "?" let's us take care of this silently.
      # TODO: make this configurable
      TLog._global_logs.allow
        insert: (uid)->
          true
        update: (uid)->
          false

    if Meteor.isClient
      Meteor.subscribe('_observatory_logs')
    @warn("You should use TLog.getLogger(loglevel, want_to_print) method instead of a constructor! Constructor calls may be removed 
      in the next versions of the package.") if show_warning


  # function to set who is allowed to remove the logs from the database
  @allowRemove: (func)=>
    TLog._global_logs.allow
      remove: (uid)=>
        if func then func uid else true

  # Set options for a logger
  #
  # @param [TLog enum] loglevel desired (see getLogger())
  # @param [Bool] whether to print to the console
  #
  setOptions: (loglevel, want_to_print = true, log_user = false) ->
    if (loglevel>=0) and (loglevel<=TLog.LOGLEVEL_MAX)
      @_currentLogLevel = loglevel
    @_printToConsole = want_to_print
    @_log_user = log_user

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

  debug: (msg, module)->
    @_log(msg,TLog.LOGLEVEL_DEBUG, module)

  insaneVerbose: (msg, module)->
    @_log(msg,TLog.LOGLEVEL_MAX, module)

  # takes a error and logs it with message and stack trace if available
  trace: (error, message, module)->
    m = "Error: "
    if error.message
      m = m + error.message
    if error.trace
      m = m + " StackTrace: " + error.stack
    if error.reason?
      m = m + " Code: " + error.error + " Reason: " + error.reason
    msg = message + " | " + m if message
    @_log(msg,TLog.LOGLEVEL_ERROR, module)

  # inspects an object, stringifies it and prints out
  dir: (obj, message, module)->
    msg = if message then message else "Inspecting object:"
    if obj?
      mnames = Inspect.methods(obj)
      pnames = Inspect.properties(obj)
      methods = []
      props = []
      for m in mnames
        methods.push m
      for p in pnames
        props.push
          name: p
          value: obj[p]
      @debug(msg, module)
      @_log("Methods: " + JSON.stringify(methods),TLog.LOGLEVEL_DEBUG, module)
      @_log("Properties: " + JSON.stringify(props),TLog.LOGLEVEL_DEBUG, module)

  currentLogLevelName: ->
    TLog.LOGLEVEL_NAMES[@_currentLogLevel]

  logCount: ->
    @_logs.find({}).count()

  #internal method doing the logging
  _log: (msg, loglevel = TLog.LOGLEVEL_INFO, mdl) ->

    if loglevel <= @_currentLogLevel
      srv = false
      if Meteor.isServer
        srv = true

      uid = null
      if @_log_user
        try
          uid = Meteor.userId()
        catch err
      module = mdl
      timestamp = new Date Date.now()
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
        timestamp: timestamp
        full_message: full_message
        uid: uid

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



