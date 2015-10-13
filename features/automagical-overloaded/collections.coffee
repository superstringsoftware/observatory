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
      msg = "#{m} call finished in #{t2} ms for collection.#{@_name}"
      #console.log msg
      #console.log "2: ", args
      object =
        timeElapsed: t2
        method: m
        arguments: EJSON.stringify args
      tb._verbose msg, object, 'profiler', 'profile', true
    ret

  for m in sync
    Meteor.Collection::[m] = _.wrap Meteor.Collection::[m], _.partial g, m


  # the same for async:
  h = (m,f)->
    tb = Observatory.getToolbox()

    args = _.rest (_.rest arguments)
    orig_callback = args.pop()

    callback = (err,res)=>
      if @_name? and @_name.indexOf('_observatory') < 0
        t2 = Date.now() - t1
        msg = "#{m} call finished in #{t2} ms for collection.#{@_name}"
        #console.log msg
        #console.log "2: ", args
        object =
          timeElapsed: t2
          method: m
          arguments: EJSON.stringify args
        tb._verbose msg, object, 'profiler', 'profile', true

      orig_callback err, res if typeof orig_callback is 'function'

    if typeof orig_callback is 'function'
      args.push callback
    else
      args.push orig_callback
      args.push callback

    t1 = Date.now()
    f.apply this, args

  for m in async
    Meteor.Collection::[m] = _.wrap Meteor.Collection::[m], _.partial h, m



  ###
  for m in async
    Meteor.Collection::[m] = _.wrap Meteor.Collection::[m], (f)->
      tb = Observatory.getToolbox()
      t1 = Date.now()
      console.log "#{m} call started", "Collection.#{@_name}"
      console.log arguments
      args = _.rest arguments
      ret = f.apply this, args
      if @_name? # not logging null collections (TODO: should be configurable?)
        t2 = Date.now() - t1
        msg = "#{m} call finished in #{t2} ms for collection.#{@_name}"
        #console.log msg
        object =
          timeElapsed: t2
          method: m
          arguments: EJSON.stringify args
        tb._verbose msg, object, 'profiler', 'profile', true
      ret

  ###
