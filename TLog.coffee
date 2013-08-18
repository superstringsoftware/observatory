#(exports ? this).TLog = TLog
# Class that handles all the logging logic
#
# @example Getting a logger that will print only WARNING and more severe messages both to db and console:
#     TL = TLog.getLogger(TLog.LOGLEVEL_WARNING, true)
#
class TLog
  @_connectLogsBuffer = []
  @_log_http = true

  @addToLogsBuffer: (obj)->
    @_connectLogsBuffer.push obj

  @checkConnectLogsBuffer: ->
    if TLog._connectLogsBuffer.length > 0
      tl = TLog.getLogger()
      for l in TLog._connectLogsBuffer
        msg = "#{l.method} #{l.url}: #{l.status} in #{l.responseTime} ms\n#{l.userAgent}\n#{l.responseHeader}"
        fullMsg = msg + "\nreferrer: #{l.referrer?}"
        loglevel = TLog.LOGLEVEL_VERBOSE
        if l.status >= 500 then loglevel = TLog.LOGLEVEL_FATAL
        else if l.status >= 400 then loglevel = TLog.LOGLEVEL_ERROR
        else if l.status >= 300 then loglevel = TLog.LOGLEVEL_WARNING

        options =
          isServer: true
          message: msg
          full_message: fullMsg
          module: "HTTP"
          timestamp: l.timestamp
          ip: l.remoteAddress
          elapsedTime: l.responseTime # e.g., response time for http or method running time for profiling functions

        # recording the result
        tl._lowLevelLog loglevel, options, l

      TLog._connectLogsBuffer = []


  @_instance = undefined
  @_global_logs = new Meteor.Collection '_observatory_logs'

  # Get a logger with options
  #
  # @param [TLog enum] loglevel desired loglevel, one of TLog.LOGLEVEL_FATAL,TLog.LOGLEVEL_ERROR,TLog.LOGLEVEL_WARNING,TLog.LOGLEVEL_INFO,TLog.LOGLEVEL_VERBOSE
  # @param [Bool] want_to_print if true, log messages will be printed to the console as well
  #
  @getLogger:->
    @_instance?=new TLog TLog.LOGLEVEL_DEBUG, true, true, false
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

  constructor: (@_currentLogLevel, @_printToConsole, @_log_user = true, show_warning = true)->
    if ObservatorySettings
      if ObservatorySettings.logLevel? then @_currentLogLevel = ObservatorySettings.logLevel
      if ObservatorySettings.printToConsole? then @_printToConsole = ObservatorySettings.printToConsole
      if ObservatorySettings.log_user? then @_log_user = ObservatorySettings.log_user
      if ObservatorySettings.log_http? then TLog._log_http = ObservatorySettings.log_http
    
    @_logs = TLog._global_logs
    if Meteor.isServer
      # Hooking into connect middleware
      __meteor_bootstrap__.app.use Observatory.logger #TLog.useragent
      Meteor.publish '_observatory_logs',->
        if !ObservatorySettings or ObservatorySettings.should_publish(@)
          TLog._global_logs.find {}, {sort: {timestamp: -1}, limit:TLog.limit}
        else
          false
      if ObservatorySettings.allow
        TLog._global_logs.allow(ObservatorySettings.allow)
      else
        TLog._global_logs.allow
          insert: (uid)->
            true
          update: (uid)->
            false

    if Meteor.isClient
      Meteor.subscribe('_observatory_logs')

    @warn("You should use TLog.getLogger(loglevel, want_to_print) method instead of a constructor! Constructor calls may be removed
      in the next versions of the package.") if show_warning
    @verbose "Creating logger with level #{TLog.LOGLEVEL_NAMES[@_currentLogLevel]}, print to console: #{@_printToConsole}, log user: #{@_log_user}", "Observatory"


  # function to set who is allowed to remove the logs from the database
  @allowRemove: (func)=>
    tl = TLog.getLogger()
    if Meteor.isServer
      TLog._global_logs.allow
        remove: (uid)=>
          tl.warn "Setting allowRemove on the logger to #{func}", "Observatory"
          if func then func uid else true
    else tl.warn "Tried to set remove permissions to #{func} on the client", "Observatory"

  # Set options for a logger
  #
  # @param [TLog enum] loglevel desired (see getLogger())
  # @param [Bool] whether to print to the console
  #
  setOptions: (loglevel, want_to_print = true, log_user = true, log_http = true) ->
    if (loglevel>=0) and (loglevel<=TLog.LOGLEVEL_MAX)
      @_currentLogLevel = loglevel
    @_printToConsole = want_to_print
    @_log_user = log_user
    TLog._log_http = log_http
    @verbose "Setting log options with level #{TLog.LOGLEVEL_NAMES[@_currentLogLevel]}, print to console: #{@_printToConsole}, log user: #{@_log_user}, http logging: #{TLog._log_http}", "Observatory"

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
      @_log("Methods: " + EJSON.stringify(methods),TLog.LOGLEVEL_DEBUG, module)
      @_log("Properties: " + EJSON.stringify(props),TLog.LOGLEVEL_DEBUG, module)

  currentLogLevelName: ->
    TLog.LOGLEVEL_NAMES[@_currentLogLevel]

  logCount: ->
    @_logs.find({}).count()


  # low level full logging convenience
  # DOES NOT check current level to allow logging monitoring etc functions
  _lowLevelLog: (loglevel, options, customOptions)->
    #return if loglevel >= @_currentLogLevel

    ts = if options.timestamp_text then options.timestamp_text else @_ps(TLog._convertDate(options.timestamp)) + @_ps(TLog._convertTime(options.timestamp))

    @_logs.insert
      isServer: options.isServer or false
      message: options.message
      full_message: options.fullMessage
      module: options.module
      loglevel: loglevel
      timestamp_text: ts
      timestamp: options.timestamp
      uid: options.uid # user id or null
      ip: options.ip # IP address or null
      elapsedTime: options.elapsedTime # e.g., response time for http or method running time for profiling functions
      customOptions: customOptions # anything else EJSONable that you want to store

  # normal Meteor logging
  _log: (msg, loglevel = TLog.LOGLEVEL_INFO, mdl) ->
    if loglevel <= @_currentLogLevel
      srv = false
      if Meteor.isServer
        srv = true

      uid = null
      user = ''
      if @_log_user
        try
          uid = Meteor.userId()
          u = Meteor.users.findOne(uid) # TODO: check how it affects performance!
          if u and u.username
            user = u.username
          else
            if u and u.emails and u.emails[0]
              user = u.emails[0].address
            else
              user = uid
        catch err

      module = mdl
      timestamp = new Date
      ts = @_ps(TLog._convertDate(timestamp)) + @_ps(TLog._convertTime(timestamp))
      full_message = if srv then ts + "[SERVER]" else ts + "[CLIENT]"
      full_message+= if module then @_ps module else "[]"
      full_message+= @_ps(TLog.LOGLEVEL_NAMES[loglevel]) #TODO: RANGE CHECK!!!
      full_message+= "[#{user}]"
      full_message+= ' ' + msg

      options =
        isServer: srv
        message: msg
        module: mdl
        timestamp: timestamp
        timestamp_text: ts
        full_message: full_message
        uid: uid

      @_lowLevelLog loglevel, options
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


# Starting the cycle of watching http logs buffer
if Meteor.isServer
  Meteor.startup ->
    Meteor.setInterval ->
      TLog.checkConnectLogsBuffer()
    , 5000

Inspect =
  TYPE_FUNCTION: "function"

  # Returns an array of (the names of) all methods
  methods: (obj) ->
    testObj = obj or self
    methods = []
    for prop of testObj
      methods.push prop  if typeof testObj[prop] is Inspect.TYPE_FUNCTION and typeof Inspect[prop] isnt Inspect.TYPE_FUNCTION
    methods


  # Returns an array of (the names of) all properties
  properties: (obj) ->
    testObj = obj or self
    properties = []
    for prop of testObj
      properties.push prop  if typeof testObj[prop] isnt Inspect.TYPE_FUNCTION and typeof Inspect[prop] isnt Inspect.TYPE_FUNCTION
    properties

#global.TLog = TLog
(exports ? this).TLog = TLog
(exports ? this).Inspect = Inspect