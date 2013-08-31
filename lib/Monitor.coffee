tl = TLog.getLogger()

class Observatory.Monitor
  constructor: (@name)->
    # Map of the current sessions
    @_sessions = []
    @isRunning = false
    @_monitorHandle = null

  # Starting the monitoring process with timePeriod
  # Restarts in case it's already running
  # TODO: write the actual logic
  startMonitor: (timePeriod)->
    @stopMonitor if @isRunning
    @_monitorHandle = Meteor.setInterval =>
      currentSessions = Meteor.call "_observatoryGetOpenSessions"
      timestamp = new Date
      tl.debug "Running Monitor handle with #{currentSessions?.length} sessions currently open"

      newSessions = _.difference currentSessions, @_sessions
      closedSessions = _.difference @_sessions, currentSessions
      updatedSessions = _.intersection @_sessions, currentSessions

      ###
      console.log currentSessions?.length
      console.log newSessions?.length
      console.log closedSessions?.length
      console.log updatedSessions?.length
      ###
      
      @isRunning = true
    , timePeriod or 30000 # 30 sec by default

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