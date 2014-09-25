# Abstraction of different hidden Meteor methods that help us in monitoring / management

Observatory = @Observatory ? {}

class Observatory.MeteorInternals

  # returns all currently open sessions
  getCurrentSessions: -> Meteor.server.sessions
  getSessionCount: -> _.keys(@getCurrentSessions()).length

  # finds session by id (is session id the same as connection?)
  findSession: (id) -> _.find @getCurrentSessions(), (v,k)-> k is id

  convertSessionToView: (ss)->
    session =
      id: ss.id
      connectionId: ss.connectionHandle.id
      ip: ss.connectionHandle.clientAddress
      headers: ss.connectionHandle.httpHeaders
      userId: ss.userId
      collectionViews: []
      namedSubs: []

    for k,v of ss.collectionViews
      cv =
        id: k
        name: v.collectionName
        documentCount: _.keys(v.documents).length
      session.collectionViews.push cv

    for k,v of ss._namedSubs
      ns =
        name: v._name
        params: v._params
        subscriptionHandle: v._subscriptionHandle
        deactivated: v._deactivated
        documentCount: _.keys(v._documents).length
        ready: v._ready
      session.namedSubs.push ns

    session





(exports ? this).Observatory = Observatory