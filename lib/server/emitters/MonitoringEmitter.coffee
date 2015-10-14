util = Npm.require 'util'
os = Npm.require 'os'

Observatory = @Observatory ? {}

class Observatory.MonitoringEmitter extends @Observatory.MessageEmitter
  # doesn't belong here!!!
  sysInfo: ->
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
    @mi = new Observatory.MeteorInternals
    # collection for storing non persistent monitoring events for publishing
    # when a client is connected
    @Monitors = new Mongo.Collection null
    super @name

    cur = Observatory.settingsController.col.find
      type: "SERVER"
    self = @
    cur.observe
      added: (s) ->
        self.switchPowerMonitor s.settings.monitoring
      changed: (s) ->
        self.switchPowerMonitor s.settings.monitoring

  switchPowerMonitor: (power = false) ->
    console.log "Server monitoring is #{power}"
    if power is true
      @startMonitor 10000
    else
      @stopMonitor()

  # Starting the monitoring process with timePeriod
  # Restarts in case it's already running
  # TODO: write the actual logic
  startMonitor: (timePeriod)->
    @stopMonitor if @isRunning
    @isRunning = true
    timePeriod = timePeriod ? 60000
    @_monitorHandle = Meteor.setInterval =>
      obj = @measure()
      obj.currentSessionNumber = @mi.getSessionCount()
      #console.dir obj
      msg =
        isServer: true
        timestamp: new Date
        module: 'Monitor'
        type: 'monitor'
        severity: Observatory.LOGLEVEL.INFO
        object: obj
        textMessage: "Monitoring every #{timePeriod / 1000}s"

      @emitMessage msg
    , timePeriod

  # Stopping the monitoring process
  stopMonitor: ->
    if @isRunning
      Meteor.clearInterval @_monitorHandle
      @isRunning = false

  startNonpersistentMonitor: (timePeriod = 5000)->
    @_persistentMonitorHandle = Meteor.setInterval =>
      o = @measure()
      o.currentSessionNumber = @mi.getSessionCount()
      o.timestamp = Date.now()
      @Monitors.insert o
    , timePeriod

  stopNonpersistentMonitor: ->
    #console.log "stopping non-persistent"
    Meteor.clearInterval @_persistentMonitorHandle
    @Monitors.remove {}

  # converting session into logging options
  sessionToLoggingOptions: (session)->
    timestamp: null

(exports ? this).Observatory = Observatory