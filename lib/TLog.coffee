class TLog
  @_log_http = true
  @_log_DDP = true

  
  ###################################################################################################
  # Backward compatibility stuff!!!
  ####################################################################################################
  @getLogger:-> 
    tb = Observatory.getToolbox()
    tb.dir = @dir
    tb
  @allowRemove: (f)-> Observatory.getMeteorLogger().allowRemove f
  @publish: (f)-> Observatory.meteorServer.publish f


  @LOGLEVEL_FATAL = 0
  @LOGLEVEL_ERROR = 1
  @LOGLEVEL_WARNING = 2
  @LOGLEVEL_INFO = 3
  @LOGLEVEL_VERBOSE = 4
  @LOGLEVEL_DEBUG = 5
  @LOGLEVEL_MAX = 6

  @limit = 300

  @LOGLEVEL_NAMES = [
    "fatal", "error", "warning", "info", "verbose", "debug", "max"
  ]
  @LOGLEVEL_NAMES_CAPS = [
    "FATAL", "ERROR", "WARNING", "INFO", "VERBOSE", "DEBUG", "MAX"
  ]
  @LOGLEVEL_NAMES_SHORT = [
    "ftl", "err", "wrn", "inf", "vrb", "dbg","max"
  ]

  constructor: (@_currentLogLevel, @_printToConsole, @_log_user = true, show_warning = true)->
    if TLog._instance? then throw new Error "Attempted to create another instance of the TLog"

    settings = Meteor.settings?.public?.observatorySettings
    #console.log settings
    if settings?
      @_currentLogLevel = TLog[settings.logLevel]
      @_printToConsole = settings.printToConsole
      @_log_user = settings.logUser
      @_log_http = settings.logHttp
      @_log_DDP = settings.logDDP

    TLog._log_http = @_log_http ? true
    TLog._log_DDP = @_log_DDP ? true

  
  # Set options for a logger
  #
  # @param [TLog enum] loglevel desired (see getLogger())
  # @param [Bool] whether to print to the console
  #
  setOptions: (loglevel, want_to_print = true, log_user = true, log_http = true, log_DDP = true) ->
    if (loglevel>=0) and (loglevel<=TLog.LOGLEVEL_MAX)
      @_currentLogLevel = loglevel
    @_printToConsole = want_to_print
    @_log_user = log_user
    @_log_http = log_http
    @_log_DDP = log_DDP
    TLog._log_http = log_http
    TLog._log_DDP = log_DDP
    @verbose "Setting log options with level #{TLog.LOGLEVEL_NAMES[@_currentLogLevel]}, print to console: #{@_printToConsole}, log user: #{@_log_user}, http logging: #{TLog._log_http}", "Observatory"

  

  # inspects an object, stringifies it and prints out
  @dir: (obj, message, module)->
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
      ###
      @debug(msg, module)
      @_log("Methods: " + EJSON.stringify(methods),TLog.LOGLEVEL_DEBUG, module)
      @_log("Properties: " + EJSON.stringify(props),TLog.LOGLEVEL_DEBUG, module)
      ###

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

(exports ? this).TLog = TLog
(exports ? this).Inspect = Inspect
(exports ? this).Observatory = @Observatory
