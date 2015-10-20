###
Template.newPost.rendered = _.wrap Template.newPost.rendered, (func)->
  console.log "Injection successful!!!"
  console.log this
  func.apply this
###

Observatory = @Observatory ? {}

Observatory.automagical = Observatory.automagical ? {}

Observatory.automagical.subsLogFunction = (t2, name)->
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
      useBuffer: false
    #console.log "Calling _forceEmitWithSeverity() #{t2}, #{loglevel}", options
    tb._forceEmitWithSeverity loglevel, tb._prepareMessage(t2, options)


Observatory.automagical.subsErrorFunction = (t2, name, err)->
  tb = Observatory.getToolbox()
  loglevel = Observatory.LOGLEVEL.ERROR
  #console.log "loglevel is ", loglevel
  # only logging if thresholds are ok, otherwise simply returning
  if loglevel <= Observatory.settings.profiling.maxProfilingLevel
    options =
      message: "Error while subscribing to #{name} - #{err?.reason}"
      method: 'Meteor.subscribe()'
      profileType: 'subscription'
      useBuffer: false
      obj:
        subscription: name
        error: err
    tb._forceEmitWithSeverity loglevel, tb._prepareMessage(t2, options)


# automagical subscription logging
Observatory.automagical.logSubscriptions = ->
  #console.log "logging Meteor - CALLED ALL DYNAMIC STUFF"
  #console.log Meteor.subscribe

  Meteor.subscribe = _.wrap Meteor.subscribe, (f)->
    tl = Observatory.getToolbox()
    __name_p = arguments[1]
    #console.log __name_p
    args = (arguments[k] for k in [1...arguments.length])
    #console.log "hmm... subscribe #{__name_p}"
    #console.log args
    #console.log Observatory.settings.maxSeverity

    # some funky stuff to wrap original callbacks
    last = args.pop()
    changeLast = false
    #console.log "last is #{last}"
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
        #console.log "\n\nOnReady callback #{__name_p}"
        #console.log arguments
        t = Date.now() - Session.get "_obs.subscription.#{__name_p}.profileStart"
        #tl.forceDumbProfile  "Subscription ready for #{__name_p} in #{t} ms", t, {subscription: __name_p, type: 'subscription'}
        Observatory.automagical.subsLogFunction t, __name_p
        f.apply @
    else
      cb.onReady = ->
        #console.log arguments
        t = Date.now() - Session.get "_obs.subscription.#{__name_p}.profileStart"
        #console.log "\n\nOnReady callback no arguments #{__name_p}, #{t}"
        #tl.forceDumbProfile "Subscription ready for #{__name_p} in #{t} ms", t, {subscription: __name_p, type: 'subscription'}
        Observatory.automagical.subsLogFunction t, __name_p

    if origOnStop?
      cb.onStop = _.wrap origOnStop, (f)->
        #console.log "OnStop callback #{__name_p}"
        t = Date.now() - Session.get "_obs.subscription.#{__name_p}.profileStart"
        #tl._error "Error while subscribing to #{__name_p}: " + err.reason, {error: err, subscription: __name_p, timeElapsed: t, type: 'subscription'}
        if arguments[1]?
          Observatory.automagical.subsErrorFunction t, __name_p, arguments[1]
          f.apply @, arguments[1]
        else
          Observatory.automagical.subsErrorFunction t, __name_p
          f.apply @
    else
      cb.onStop = (err)->
        #console.log "OnStop callback no arguments #{__name_p}"
        t = Date.now() - Session.get "_obs.subscription.#{__name_p}.profileStart"
        Observatory.automagical.subsErrorFunction t, __name_p, err if err?
        #tl._error "Error while subscribing to #{__name_p}: " + err.reason, {error: err, subscription: __name_p, timeElapsed: t, type: 'subscription'}

    # args = _.rest arguments
    # args.shift() # taking out this function from arguments

    #if changeLast then args[args.length - 1] = cb # replacing original callbacks
    if changeLast
      args.push cb # adding callbacks
    else
      args.push last
      args.push cb


    Session.set "_obs.subscription.#{__name_p}.profileStart", Date.now()
    tl.verbose "Subscribing to #{__name_p}", "Meteor"

    #console.log "Calling original function with args: ", args
    f.apply this, args



