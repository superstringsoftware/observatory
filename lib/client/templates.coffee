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

  getEvents: (name)-> @getTemplate(name)?._tmpl_data.events
  getHelpers: (name)-> @getTemplate(name)?._tmpl_data.helpers

  logAll: ->
    @logTemplates()
    @logMeteor()

  logTemplates: ->
    console.log "logging templates now"
    names = @getTemplateNames()
    console.log names
    callbacks = ['created','rendered','destroyed']
    for t in names
      for c in callbacks
        if Template[t][c]?
          Template[t][c] = _.wrap Template[t][c], (f)->
            tl = TLog.getLogger()
            tl.debug "#{c} call started", "Template.#{t}"
            f.apply this
            tl.debug "#{c} call finished", "Template.#{t}"
        else
          Template[t][c] = ->
            tl = TLog.getLogger()
            tl.debug "#{c} called - not defined by user", "Template.#{t}"



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
    #console.log "logging Meteor"
    #console.log Meteor.subscribe

    Meteor.subscribe = _.wrap Meteor.subscribe, (f)->
      #console.log "hmm..."
      #console.log arguments
      tl = Observatory.getToolbox()
      name = arguments[1]
      tl.verbose "Subscribing to #{name}", "Meteor"

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

      cb =
        onReady: =>
          t = Date.now() - Session.get "_obs.subscription.#{name}.profileStart"
          tl.profile "Subscription ready for #{name} in #{t} ms", t, {subscription: name, type: 'subscription'}
          origOnReady() if origOnReady?
        onError: (err)=>
          t = Date.now() - Session.get "_obs.subscription.#{name}.profileStart"
          tl.error "Error while subscribing to #{name}: " + err.reason, {error: err, subscription: name, timeElapsed: t, type: 'subscription'}
          origOnError(err) if origOnError?

      args = _.rest arguments

      if changeLast then args[args.length - 1] = cb # replacing original callbacks
      else args.push cb # adding callbacks

      #console.log args

      Session.set "_obs.subscription.#{name}.profileStart", Date.now()
      f.apply this, args



(exports ? this).Observatory = Observatory