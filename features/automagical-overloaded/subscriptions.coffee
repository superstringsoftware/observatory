###
Template.newPost.rendered = _.wrap Template.newPost.rendered, (func)->
  console.log "Injection successful!!!"
  console.log this
  func.apply this
###

Observatory = @Observatory ? {}

Observatory.automagical = Observatory.automagical ? {}

Observatory.automagical.subsLogFunction = (t2, name, args)->
  tb = Observatory.getToolbox()
  loglevel = tb._determineProfilingLevel t2
  #console.log "loglevel is ", loglevel
  # only logging if thresholds are ok, otherwise simply returning
  if loglevel <= Observatory.settings.profiling.maxProfilingLevel
    options =
      message: "subscription: #{name}"
      method: 'Meteor.subscribe()'
      profileType: 'subscription'
      obj: subscription: name
    tb._forceEmitWithSeverity loglevel, tb._prepareMessage t2, options, args


Observatory.automagical.subsErrorFunction = (t2, name, args, err)->
  tb = Observatory.getToolbox()
  loglevel = Observatory.LOGLEVEL.ERROR
  #console.log "loglevel is ", loglevel
  # only logging if thresholds are ok, otherwise simply returning
  if loglevel <= Observatory.settings.profiling.maxProfilingLevel
    options =
      message: "Error while subscribing to #{name} - #{err?.reason}"
      method: 'Meteor.subscribe()'
      profileType: 'subscription'
      obj:
        subscription: name
        error: err
    tb._forceEmitWithSeverity loglevel, tb._prepareMessage t2, options, args


# automagical subscription logging
Observatory.automagical.logSubscriptions = ->
  #console.log "logging Meteor - CALLED ALL DYNAMIC STUFF"
  #console.log Meteor.subscribe

  Meteor.subscribe = _.wrap Meteor.subscribe, (f)->
    #console.log "hmm... subscribe"
    #console.log arguments
    tl = Observatory.getToolbox()
    name = arguments[1]
    #console.log Observatory.settings.maxSeverity

    # some funky stuff to wrap original callbacks
    last = _.last arguments
    changeLast = false
    if typeof last is 'object'
      if last.onReady?
        origOnReady = last.onReady
        changeLast = true
      if last.onStop?
        origOnStop = last.onStop
        changeLast = true
    else
      if typeof last is 'function'
        origOnReady = last
        changeLast = true


    cb = {}
    if origOnReady?
      cb.onReady = _.wrap origOnReady, (f)->
        #console.log "OnReady callback"
        #console.log arguments
        t = Date.now() - Session.get "_obs.subscription.#{name}.profileStart"
        #tl.forceDumbProfile  "Subscription ready for #{name} in #{t} ms", t, {subscription: name, type: 'subscription'}
        args = _.rest arguments
        Observatory.automagical.subsLogFunction t, name, args
        f.apply @, args
    else
      cb.onReady = ->
        #console.log "OnReady callback no arguments"
        t = Date.now() - Session.get "_obs.subscription.#{name}.profileStart"
        #tl.forceDumbProfile "Subscription ready for #{name} in #{t} ms", t, {subscription: name, type: 'subscription'}
        Observatory.automagical.subsLogFunction t, name, args

    if origOnStop?
      cb.onStop = _.wrap origOnStop, (f)->
        t = Date.now() - Session.get "_obs.subscription.#{name}.profileStart"
        #tl._error "Error while subscribing to #{name}: " + err.reason, {error: err, subscription: name, timeElapsed: t, type: 'subscription'}
        args = _.rest arguments
        Observatory.automagical.subsErrorFunction t, name, args, args[0] if args[0]?
        f.apply @, args
    else
      cb.onStop = (err)->
        #console.log "OnStop callback no arguments"
        t = Date.now() - Session.get "_obs.subscription.#{name}.profileStart"
        Observatory.automagical.subsErrorFunction t, name, args, err if err?
        #tl._error "Error while subscribing to #{name}: " + err.reason, {error: err, subscription: name, timeElapsed: t, type: 'subscription'}

    args = _.rest arguments

    if changeLast then args[args.length - 1] = cb # replacing original callbacks
    else args.push cb # adding callbacks

    Session.set "_obs.subscription.#{name}.profileStart", Date.now()
    tl.verbose "Subscribing to #{name}", "Meteor"
    f.apply this, args



