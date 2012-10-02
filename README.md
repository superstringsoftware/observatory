What is it?
-------------
This is Telescope Logger v0.1.1 - a [Meteorite](https://github.com/oortcloud/meteorite) package that provides simple, efficient and pretty logging for the [Meteor framework](http://meteor.com). 

Why?
------
We got frustrated with the need to switch between the terminal and Chrome's js console to keep track of the Meteor app logs, 
plus needed a basic standard logging package that can support different log levels and present all that in one place in a nice format.

What does it do?
------------------
Supports different log levels (currently FATAL, ERROR, WARNING, INFO, VERBOSE) with corresponding methods for message output, optional 
logging to console, pretty output of both Client and Server logs using Twitter Bootstrap right in the browser.

[See for yourself!](http://telescope-logger.meteor.com)

Installation
-----------------
#### With meteorite:

	mrt add telescope

#### Manually:
Copy telescope.coffee and client/ folder from the repo to your project. Add the Meteor packages this depends on (bootstrap, coffeescript, less, underscore). You should be up and running.

Usage
---------
Somewhere in the common code of your meteor app call:
```coffeescript
TL = TLog.getLogger(TLog.LOGLEVEL_MAX,true)
#for other options, see API section below
```
and then when you want to log a message of a certain log level:
```coffeescript
TL.fatal("your message")
TL.error("your message")
TL.warn("your message")
TL.info("your message")
TL.verbose("your message")
```
To actually display the logs, plugin "logs_bootstrap" template anywhere in your Handlebars templates. E.g.:
```html
<div class="span8">
  <h1>My cool logs</h1>

  {{>logs_bootstrap}}
</div>
```

Everything else is done automagically, as always is the case with Meteor. See how it's done in [the sample app](https://github.com/jhoxray/telescope) and how it looks in the 
[live demo](http://telescope-logger.meteor.com).


API
---------
In addition to the functions above here's a short description of what else you may need.
```coffeescript
class TLog
  #setting desired log level and whether you also want to output your log messages to the console (true or false)
  @getLogger: (currentLogLevel, printToConsole)->
  
  #log levels are defined as follows, so use TLog.LOGLEVEL_... when calling get Logger()
  @LOGLEVEL_FATAL = 0
  @LOGLEVEL_ERROR = 1
  @LOGLEVEL_WARNING = 2
  @LOGLEVEL_INFO = 3
  @LOGLEVEL_VERBOSE = 4
  @LOGLEVEL_MAX = 5

  #to change log level and console printing, use
  setOptions: (loglevel, want_to_print = true)
```

Feedback
----------
We'd love to hear what you think, whether it's useful and which other features you'd want to see in a proper Meteor logging framework - 
so please submit issues here on github to share your thoughts and ideas!

Revision history
-----------------
####0.1.1 
Clean up for visibility / encapsulation, now need to use TLog.getLogger() instead of constructing directly

####0.1
Initial commit of the sample app deployed to telescope-logger.meteor.com

