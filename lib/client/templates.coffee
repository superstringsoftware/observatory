###
Template.newPost.rendered = _.wrap Template.newPost.rendered, (func)->
  console.log "Injection successful!!!"
  console.log this
  func.apply this
###

Observatory = @Observatory ? {}

_.extend Observatory,

  getTemplateNames: (includeHidden = false)->
    ret = []
    for k,v of Template
      ret.push k unless k.indexOf('_') is 0
    ret

  getTemplate: (name)->_.find Template, (k,v)-> v is name

  getEvents: (name)-> Template[name]?.__eventMaps
  getHelpers: (name)-> @getTemplate(name)?._tmpl_data.helpers

  logAll: ->
    @logTemplates()
    @logMeteor()

  logTemplates: ->
    console.log "logging templates now"
    names = @getTemplateNames()
    console.log names
    callbacks = ['created','rendered','destroyed']
    tl = Observatory.getToolbox()
    Observatory.ot = {}
    ###
    for t in names
      Observatory.ot[t] = {}
      for c in callbacks
        if Template[t][c]?
          #console.log Template[t][c].toString()
          Observatory.ot[t][c] = Template[t][c]
          #_.bind oldf, Template[t]
          #console.log "For #{t}.#{c}():"
          #console.log ot
          
          Template[t][c] = _.wrap Observatory.ot[t][c], (f)->
            tl = Observatory.getToolbox()
            tl.debug "#{c}() call started", "Template.#{t}"
            time1 = Date.now()
            #console.dir Observatory.ot
            #console.dir this
            #f.call this
            time2 = Date.now() - time1
            tl.profile "#{c}() call finished in #{time2} ms", time2, {template: t, type: 'template'}
            #ret
            #tl.debug "#{c} call finished", "Template.#{t}"
          
    console.dir Observatory.ot
    ###


  logCollection: ->
    sync = ['find','findOne']
    async = ['insert','update','remove']
    #console.log Meteor.Collection::

    # Ok, can't call insert etc inside collection methods - problem is, TLog collection
    # is created from Collection as well, so it goes crazy. Need to make sure we are not
    # applying this to TLog, but not sure how so far --
    # One option is just store this stuff in the buffer, as with http logs
    # and then process it, checking when processing not to add the logs if it's about TLog
    for m in sync
      Meteor.Collection::[m] = _.wrap Meteor.Collection::[m], (f)->
        console.log "#{m} call started", "Collection.#{@_name}"
        console.log arguments
        ret = f.apply this, _.rest(arguments)
        console.log "#{m} call finished", "Collection.#{@_name}"
        ret


  # for now, only subscribe
  logMeteor: ->
    console.log "logging Meteor - CALLED ALL DYNAMIC STUFF"
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
          tl._profile "Subscription ready for #{name} in #{t} ms", t, {subscription: name, type: 'subscription'}
          args = _.rest arguments
          f.apply @, args
      else
        cb.onReady = ->
          #console.log "OnReady callback no arguments"
          t = Date.now() - Session.get "_obs.subscription.#{name}.profileStart"
          tl._profile "Subscription ready for #{name} in #{t} ms", t, {subscription: name, type: 'subscription'}

      if origOnError?
        cb.onError = _.wrap origOnError, (f)->
          #console.log "OnError callback"
          #console.log arguments
          t = Date.now() - Session.get "_obs.subscription.#{name}.profileStart"
          tl._error "Error while subscribing to #{name}: " + err.reason, {error: err, subscription: name, timeElapsed: t, type: 'subscription'}
          args = _.rest _.rest arguments
          f.apply @, args
      else
        cb.onError = ->
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


    Meteor.call = _.wrap Meteor.call, (f)->
      console.log "hmm... call"
      console.log arguments
      tl = Observatory.getToolbox()
      name = arguments[1]
      #console.log Observatory.settings.maxSeverity

      # some funky stuff to wrap original callbacks
      last = _.last arguments
      changeLast = false
      if typeof last is 'function'
        origOnReady = last
        changeLast = true
        cb = _.wrap origOnReady, (f1)->
          console.log "OnReady callback"
          console.log arguments
          t = Date.now() - Session.get "_obs.methodCall.#{name}.profileStart"
          tl._profile "Method #{name} executed in #{t} ms", t, {method: name, type: 'method'}
          args = _.rest arguments
          f1.apply @, args
      else
        cb = (err, res)->
          console.log "OnReady callback no arguments"
          console.log err
          console.log res
          t = Date.now() - Session.get "_obs.methodCall.#{name}.profileStart"
          tl._profile "Method #{name} executed in #{t} ms", t, {method: name, type: 'method'}

      args = _.rest arguments

      if changeLast then args[args.length - 1] = cb # replacing original callbacks
      else args.push cb # adding callbacks

      #console.log args

      Session.set "_obs.methodCall.#{name}.profileStart", Date.now()
      tl._verbose "Starting execution of #{name}", "Meteor"
      console.dir @
      console.dir args
      f.apply this, args

    ###
    Meteor.apply = _.wrap Meteor.apply, (f)->
      console.log "hmm... apply"
      console.log arguments
      tl = Observatory.getToolbox()
      name = arguments[1]
      origArgs = arguments[2]
      #console.log Observatory.settings.maxSeverity

      # some funky stuff to wrap original callbacks
      last = _.last arguments
      changeLast = false
      if typeof last is 'function'
        origOnReady = last
        changeLast = true

      cb = =>
        t = Date.now() - Session.get "_obs.methodCall.#{name}.profileStart"
        tl._profile "Method #{name} executed in #{t} ms", t, {method: name, type: 'method'}
        origOnReady() if origOnReady? # TODO: what about the arguments???

      args = _.rest arguments

      if changeLast then args[args.length - 1] = cb # replacing original callbacks
      else args.push cb # adding callbacks

      #console.log args

      Session.set "_obs.methodCall.#{name}.profileStart", Date.now()
      tl._verbose "Starting execution of #{name}", "Meteor"
      f.apply this, args
    ###


(exports ? this).Observatory = Observatory