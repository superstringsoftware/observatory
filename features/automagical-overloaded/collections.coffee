Observatory = @Observatory ? {}

Observatory.automagical = Observatory.automagical ? {}


# automagical collection logging
Observatory.automagical.logCollections = ->

  sync = ['find','findOne']
  async = ['insert','update','remove','upsert']

  #_forceEmitWithSeverity: (severity, message, obj, module, type, buffer = false)

  # OK, this took A WHILE to figure out - partial application, wrapping...
  g = (m,f)->
    tb = Observatory.getToolbox()
    args = _.rest (_.rest arguments)
    t1 = Date.now()
    ret = f.apply this, args
    # not logging null collections (TODO: should be configurable?)
    # not logging observatory collections (TODO: should be configurable?)
    if @_name? and @_name.indexOf('_observatory') < 0
      t2 = Date.now() - t1
      # determine with which level to log
      loglevel = tb._determineProfilingLevel t2
      #console.log "loglevel is ", loglevel
      # only logging if thresholds are ok, otherwise simply returning
      if loglevel <= Observatory.settings.profiling.maxProfilingLevel
        options =
          message: "collection.#{@_name}"
          method: m
        tb._forceEmitWithSeverity loglevel, tb._prepareMessage t2, options, args
    ret

  for m in sync
    Mongo.Collection::[m] = _.wrap Mongo.Collection::[m], _.partial g, m


  # the same for async:
  h = (m,f)->
    tb = Observatory.getToolbox()

    args = _.rest (_.rest arguments)
    #sargs = EJSON.stringify args
    orig_callback = args.pop()

    callback = (err,res)=>
      t2 = Date.now() - @__startTime
      if @_name? and @_name.indexOf('_observatory') < 0
        # determine with which level to log
        loglevel = tb._determineProfilingLevel t2
        # only logging if thresholds are ok, otherwise simply returning
        if loglevel <= Observatory.settings.profiling.maxProfilingLevel
          options =
            message: "collection.#{@_name}"
            method: m
          tb._forceEmitWithSeverity loglevel, tb._prepareMessage t2, options, args

      orig_callback err, res if typeof orig_callback is 'function'

    if typeof orig_callback is 'function'
      args.push callback
    else
      args.push orig_callback
      args.push callback

    ###
    if @_name? and @_name.indexOf('_observatory') < 0
      msg = "#{m} call started for collection #{@_name}"
      object =
        method: m
        arguments: sargs
        collectionName: @_name
        type: "profile.start"
      tb._verbose msg, object, 'profiler', 'profile', true

    ###

    @__startTime = Date.now()
    f.apply this, args

  for m in async
    Mongo.Collection::[m] = _.wrap Mongo.Collection::[m], _.partial h, m



