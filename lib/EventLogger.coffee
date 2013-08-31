# Generic EventLogger used to listen to specific types of messages, record them in the buffer
# and periodically log via system wide Observatory logger
Observatory = if Observatory? then Observatory else {}

class Observatory.EventLogger
  @logsBuffer = []

  # @name is a module name
  # func is a function to process and log every object in the buffer
  constructor: (@name, func)->
    @logsBuffer = []
    @func = func

  # adds an arbitrary object to the buffer
  addObjectToBuffer: (obj)->
    @logsBuffer.push obj

  # receives a function that formats & logs each object in the buffer in whatever way we need
  # and clears the buffer in the end
  processBuffer: (func)->
    return unless @logsBuffer.length > 0
    f = if func? then func else @func
    f obj for obj in @logsBuffer
    @logsBuffer = []


(exports ? this).Observatory = Observatory