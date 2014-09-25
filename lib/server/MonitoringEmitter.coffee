util = Npm.require 'util'
os = Npm.require 'os'

Observatory = @Observatory ? {}

class Observatory.MonitoringEmitter extends @Observatory.MessageEmitter
  # doesn't belong here!!!
  sysInfo: ->
    o =
      cpus: os.cpus()
      host: os.hostname()
      os:
        type: os.type()
        platform: os.platform()
        arch: os.arch()
        release: os.release()
      network: os.networkInterfaces()
      url: Meteor.absoluteUrl()

  sysInfoShort: ->
    o = @sysInfo()
    o.cpuType = o.cpus[0]?.model
    o.cpus = o.cpus.length
    o.network = _.keys(o.network).length
    o

  measure: ->
    obj = 
      procMemUse: process.memoryUsage()
      osUptime: os.uptime()
      procUptime: process.uptime()
      loadavg: os.loadavg()
      totalmem: os.totalmem()
      freemem: os.freemem()
    
    
  secondsToString = (seconds) ->
    numdays = Math.floor(seconds / 86400)
    numhours = Math.floor((seconds % 86400) / 3600)
    numminutes = Math.floor(((seconds % 86400) % 3600) / 60)
    numseconds = ((seconds % 86400) % 3600) % 60
    numdays + " days " + numhours + " hours " + numminutes + " minutes " + numseconds + " seconds"


  constructor: (@name)->
    # Map of the current sessions
    @name = name ? 'Monitor'
    @_sessions = []
    @isRunning = false
    @_monitorHandle = null
    super @name

  # Starting the monitoring process with timePeriod
  # Restarts in case it's already running
  # TODO: write the actual logic
  startMonitor: (timePeriod)->
    @stopMonitor if @isRunning
    timePeriod = timePeriod ? 60000
    @_monitorHandle = Meteor.setInterval =>
      currentSessions = Meteor.call "_observatoryGetOpenSessions"
      obj = @measure()
      obj.currentSessionNumber = currentSessions?.length
      msg = 
        isServer: true
        timestamp: new Date
        module: 'Monitor'
        type: 'monitor'
        severity: Observatory.LOGLEVEL.INFO
        object: obj
        textMessage: "Monitoring every #{timePeriod / 1000}s"

      @emitMessage msg
      @isRunning = true
    , timePeriod

  # Stopping the monitoring process
  stopMonitor: ->
    if @isRunning
      Meteor.clearInterval @_monitorHandle
      @isRunning = false

  # converting session into logging options
  sessionToLoggingOptions: (session)->
    o =
      timestamp: null
    o


(exports ? this).Observatory = Observatory