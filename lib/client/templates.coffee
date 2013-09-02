###
Template.newPost.rendered = _.wrap Template.newPost.rendered, (func)->
  console.log "Injection successful!!!"
  console.log this
  func.apply this
###

_.extend Observatory,

  getTemplateNames: (includeHidden = false)->
    ret = []
    for k,v of Template
      ret.push k unless k.indexOf('_') is 0
    ret

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

  logMeteor: ->
    console.log "logging Meteor"
    console.log Meteor.subscribe

    Meteor.subscribe = _.wrap Meteor.subscribe, (f)->
      #console.log "hmm..."
      #console.log arguments
      tl = TLog.getLogger()
      name = arguments[1]
      tl.debug "Subscribing to #{name}", "Meteor"

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
          tl.debug "Subscription ready for #{name} in #{t} ms"
          origOnReady() if origOnReady?
        onError: (err)=>
          tl.trace err
          origOnError() if origOnError?

      args = _.rest arguments

      if changeLast then args[args.length - 1] = cb # replacing original callbacks
      else args.push cb # adding callbacks

      #console.log args

      Session.set "_obs.subscription.#{name}.profileStart", Date.now()
      f.apply this, args



