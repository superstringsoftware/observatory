###
                            { _session:
I20130905-05:17:30.934(2)?    { session_id: undefined,
I20130905-05:17:30.934(2)?      heartbeat_delay: 25000,
I20130905-05:17:30.934(2)?      disconnect_delay: 60000,
I20130905-05:17:30.934(2)?      prefix: '/sockjs',
I20130905-05:17:30.934(2)?      send_buffer: [],
I20130905-05:17:30.934(2)?      is_closing: false,
I20130905-05:17:30.935(2)?      readyState: 1,
I20130905-05:17:30.935(2)?      timeout_cb: [Function],
I20130905-05:17:30.935(2)?      to_tref:
I20130905-05:17:30.935(2)?       { _idleTimeout: 25000,
I20130905-05:17:30.935(2)?         _idlePrev: [Object],
I20130905-05:17:30.935(2)?         _idleNext: [Object],
I20130905-05:17:30.935(2)?         _onTimeout: [Function],
I20130905-05:17:30.936(2)?         _idleStart: Thu Sep 05 2013 05:17:30 GMT+0200 (CEST) },
I20130905-05:17:30.936(2)?      connection: [Circular],
I20130905-05:17:30.936(2)?      emit_open: null,
I20130905-05:17:30.936(2)?      recv:
I20130905-05:17:30.936(2)?       { ws: [Object],
I20130905-05:17:30.936(2)?         connection: [Object],
I20130905-05:17:30.936(2)?         thingy: [Object],
I20130905-05:17:30.936(2)?         thingy_end_cb: [Function],
I20130905-05:17:30.937(2)?         session: [Circular] } },
I20130905-05:17:30.937(2)?   id: '166cd531-78c6-46de-ab03-bcbbffcc211a',
I20130905-05:17:30.937(2)?   headers:
I20130905-05:17:30.937(2)?    { 'x-forwarded-for': '127.0.0.1',
I20130905-05:17:30.937(2)?      host: 'localhost:3000',
I20130905-05:17:30.937(2)?      'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1612.2 Safari/537.36' },
I20130905-05:17:30.937(2)?   prefix: '/sockjs',
I20130905-05:17:30.937(2)?   remoteAddress: '127.0.0.1',
I20130905-05:17:30.937(2)?   remotePort: 60091,
I20130905-05:17:30.938(2)?   address: { address: '127.0.0.1', family: 'IPv4', port: 3001 },
I20130905-05:17:30.938(2)?   url: '/sockjs/649/gd5r5hlq/websocket',
I20130905-05:17:30.938(2)?   pathname: '/sockjs/649/gd5r5hlq/websocket',
I20130905-05:17:30.938(2)?   protocol: 'websocket',
I20130905-05:17:30.938(2)?   send: [Function],
I20130905-05:17:30.938(2)?   _events:
I20130905-05:17:30.938(2)?    { close: [ [Function], [Function], [Function] ],
I20130905-05:17:30.938(2)?      data: [ [Function], [Function] ] },
I20130905-05:17:30.939(2)?   meteor_session:
I20130905-05:17:30.939(2)?    { id: 'D3zzXacJbKvnNTnnx',
I20130905-05:17:30.939(2)?      server:
I20130905-05:17:30.939(2)?       { publish_handlers: [Object],
I20130905-05:17:30.939(2)?         universal_publish_handlers: [Object],
I20130905-05:17:30.939(2)?         method_handlers: [Object],
I20130905-05:17:30.939(2)?         sessions: [Object],
I20130905-05:17:30.940(2)?         stream_server: [Object] },
I20130905-05:17:30.940(2)?      version: 'pre1',
I20130905-05:17:30.940(2)?      initialized: true,
I20130905-05:17:30.940(2)?      socket: [Circular],
I20130905-05:17:30.940(2)?      last_connect_time: 1378351050610,
I20130905-05:17:30.940(2)?      last_detach_time: 1378351050610,
I20130905-05:17:30.940(2)?      in_queue: [],
I20130905-05:17:30.940(2)?      blocked: false,
I20130905-05:17:30.941(2)?      worker_running: true,
I20130905-05:17:30.941(2)?      out_queue: [],
I20130905-05:17:30.941(2)?      result_cache: { '1': [Object] },
I20130905-05:17:30.941(2)?      _namedSubs:
I20130905-05:17:30.941(2)?       { DpAD9GEcSQbjS7fiP: [Object],
I20130905-05:17:30.941(2)?         fJ3Smtz87FD99ceTx: [Object],
I20130905-05:17:30.941(2)?         JbtrhYsje6wvaDWAv: [Object],
I20130905-05:17:30.941(2)?         gYELfh74gyrJjfkNo: [Object] },
I20130905-05:17:30.941(2)?      _universalSubs: [ [Object] ],
I20130905-05:17:30.942(2)?      userId: null,
I20130905-05:17:30.942(2)?      sessionData: {},
I20130905-05:17:30.942(2)?      collectionViews:
I20130905-05:17:30.942(2)?       { _observatory_logs: [Object],
I20130905-05:17:30.942(2)?         meteor_accounts_loginServiceConfiguration: [Object],
I20130905-05:17:30.942(2)?         posts: [Object] },
I20130905-05:17:30.942(2)?      _isSending: true,
I20130905-05:17:30.942(2)?      _dontStartNewUniversalSubs: false,
I20130905-05:17:30.942(2)?      _pendingReady: [] } }

###

Observatory = @Observatory ? {}

class Observatory.DDPEmitter extends @Observatory.MessageEmitter
  @messageStub: ->
    options =
      isServer: true
      severity: Observatory.LOGLEVEL.DEBUG
      module: "DDP"
      timestamp: new Date
    options

  @_instance = undefined

  # getter for the instance
  @de: -> @_instance?= new Observatory.DDPEmitter "DDP Emitter"

  constructor: (@name, @formatter)->
    if Observatory.DDPEmitter._instance? then throw new Error "Attempted to create another instance of DDPEmitter and it is a really bad idea"
    
    # registering to listen to socket events with Meteor
    Meteor.default_server.stream_server.register (socket)->
      return if Observatory.DDPEmitter.de.isOff
      msg = Observatory.DDPEmitter.messageStub()
      msg.socketId = socket.id
      msg.textMessage = "Connected socket #{socket.id}" 
      # emitting message and putting to the buffer for the sake of Meteor logging. Insensitive loggers, such as Console,
      # should actually ignore this
      Observatory.DDPEmitter.de.emitMessage msg, true

      socket.on 'data', (raw_msg)->
        return if Observatory.DDPEmitter.de.isOff
        msg = Observatory.DDPEmitter.messageStub()
        msg.socketId = @id
        msg.textMessage = "Got message in a socket #{@id}"
        msg.object = raw_msg
        msg.type = "DDP"
        Observatory.DDPEmitter.de.emitMessage msg, true
      
      socket.on 'close', ->
        return if Observatory.DDPEmitter.de.isOff
        msg = Observatory.DDPEmitter.messageStub()
        msg.socketId = socket.id
        msg.textMessage = "Closed socket #{socket.id}" 
        Observatory.DDPEmitter.de.emitMessage msg, true
        


(exports ? this).Observatory = Observatory