Observatory = @Observatory ? {}

###
  Automagical Http logging - via connect middleware
###

class Observatory.HttpEmitter extends @Observatory.MessageEmitter
  
  httpLogger: (req, res, next) =>
    return next() unless @isOn

    req._startTime = Date.now()
    end = res.end

    res.end = (chunk, encoding) =>
      res.end = end
      res.end chunk, encoding

      # TODO: LOG HERE!!!
      timeElaspsed = Date.now() - req._startTime
      obj =
        url: req.originalUrl or req.url
        method: req.method
        referrer: req.headers["referer"] or req.headers["referrer"]
        remoteAddress:
          if req.ip
            req.ip
          else
            if req.socket.socket
              req.socket.socket.remoteAddress
            else
              req.socket.remoteAddress
        status: res.statusCode
        httpVersion: req.httpVersionMajor + "." + req.httpVersionMinor
        userAgent: req.headers["user-agent"]
        #contentLength: parseInt(res.getHeader('Content-Length'), 10)
        responseHeader: res._header
        acceptLanguage: req.headers['accept-language']
        forwardedFor: req.headers['x-forwarded-for']
        #requestHeaders: req.headers
        timestamp: new Date
        responseTime: timeElaspsed
        timeElaspsed: timeElaspsed
        type: 'http'

      #console.dir obj
      @emitFormattedMessage obj, true
    next()

  constructor: (name)->
    

    formatter = (l)->
      #"#{l.method} #{l.url}: #{l.status} in #{l.responseTime} ms\n#{l.userAgent}\n#{l.responseHeader}\nreferrer: #{l.referrer?}"
      msg = "#{l.method} #{l.url}: #{l.status} from #{l.forwardedFor} in #{l.responseTime} ms"
      severity = Observatory.LOGLEVEL.VERBOSE
      if l.status >= 500 then severity = Observatory.LOGLEVEL.FATAL
      else
        if l.status >= 400
          severity = Observatory.LOGLEVEL.ERROR
        else
          if l.status >= 300 then severity = Observatory.LOGLEVEL.WARNING
      options =
        isServer: true
        textMessage: msg
        module: "HTTP"
        timestamp: l.timestamp
        type: 'profile'
        severity: severity
        ip: l.forwardedFor #l.remoteAddress
        #elapsedTime: l.responseTime # e.g., response time for http or method running time for profiling functions
        object: l # recording original message in full
      options

    super name, formatter
    @turnOff()
    @name = name
    @formatter = formatter
    # hooking up into Connect middleware
    WebApp.connectHandlers.use @httpLogger
    
    
        


(exports ? this).Observatory = Observatory