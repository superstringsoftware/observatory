Meteor.methods
  # TODO: add authorization!
  _observatoryGetOpenSockets: ->
    # console.log "======================================== called observatoryGetOpenSockets ======================================"
    ret = []
    #console.dir Meteor.default_server.sessions
    for k, os of Meteor.default_server.sessions #Meteor.default_server?.stream_server?.open_sockets
      # TODO: DO NOT delete the below as if Meteor internal API changes we'll need to look at it again!!!
      # console.dir os.collectionViews
      o =
        ddpVersion: os.version
        sessionId: os.id
        initialized: os.initialized
        lastConnect: os.last_connect_time
        lastDetach: os.last_detach_time
        blocked: os.blocked
        workerRunning: os.worker_running
        userId: os.userId
        sessionData: os.sessionData
        # namedSubs: os._namedSubs - needs more work as it's not JSONable

        collectionViews: ({name: v.collectionName, id: k, docNumber: Object.keys(v.documents).length} for k,v of os.collectionViews)

        headers: os.socket?.headers
        protocol: os.socket?.protocol
        address: os.socket?.address
        remoteAddress: os.socket?.remoteAddress
        remotePort: os.socket?.remotePort

        isSending: os._isSending
        pendingReady: os._pendingReady

      ret.push o
      #console.dir os.socket._events
      #console.dir Meteor.default_server.sessions
    ret

  _observatoryGetCurrentServer: ->
    #console.log "======================================== called observatoryGetOpenSockets ======================================"
    #console.dir Meteor.default_server
    publishHandlers = ({name: k, func: v.toString()} for k,v of Meteor.default_server?.publish_handlers)
    methodHandlers = ({name: k, func: v.toString()} for k,v of Meteor.default_server?.method_handlers)
    {publishHandlers: publishHandlers, methodHandlers: methodHandlers}



