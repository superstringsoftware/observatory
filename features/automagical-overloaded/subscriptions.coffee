###
Template.newPost.rendered = _.wrap Template.newPost.rendered, (func)->
  console.log "Injection successful!!!"
  console.log this
  func.apply this
###

Observatory = @Observatory ? {}

Observatory.automagical = Observatory.automagical ? {}

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
      if last.onError?
        origOnError = last.onError
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
        tl.forceDumbProfile  "Subscription ready for #{name} in #{t} ms", t, {subscription: name, type: 'subscription'}
        args = _.rest arguments
        f.apply @, args
    else
      cb.onReady = ->
        #console.log "OnReady callback no arguments"
        t = Date.now() - Session.get "_obs.subscription.#{name}.profileStart"
        tl.forceDumbProfile "Subscription ready for #{name} in #{t} ms", t, {subscription: name, type: 'subscription'}

    if origOnError?
      cb.onError = _.wrap origOnError, (f)->
        #console.log "OnError callback"
        #console.log arguments
        t = Date.now() - Session.get "_obs.subscription.#{name}.profileStart"
        tl._error "Error while subscribing to #{name}: " + err.reason, {error: err, subscription: name, timeElapsed: t, type: 'subscription'}
        args = _.rest _.rest arguments
        f.apply @, args
    else
      cb.onError = (err)->
        #console.log "OnError callback no arguments"
        t = Date.now() - Session.get "_obs.subscription.#{name}.profileStart"
        tl._error "Error while subscribing to #{name}: " + err.reason, {error: err, subscription: name, timeElapsed: t, type: 'subscription'}

    args = _.rest arguments

    if changeLast then args[args.length - 1] = cb # replacing original callbacks
    else args.push cb # adding callbacks

    #console.log args

    Session.set "_obs.subscription.#{name}.profileStart", Date.now()
    tl._verbose "Subscribing to #{name}", "Meteor"
    f.apply this, args



