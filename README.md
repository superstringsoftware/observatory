What is it?
-------------
This is Observatory v0.1.7 - a [Meteorite](https://github.com/oortcloud/meteorite) package that provides powerful, efficient and pretty logging and monitoring for [Meteor framework](http://meteor.com) application development. 
[See it in action!](http://observatory.meteor.com)

What does it do?
------------------
* Easy logging with different log levels with corresponding methods for message output, optional 
logging to console, pretty output of both Client and Server logs using Twitter Bootstrap right in the browser.

* Monitoring of your application internals: currently, Templates with all events and a Session object; more to come.

* 2 visual styles: "dark" for additional terminal coolness and "light" that may be easier on the eyes. Adding a new theme is pretty
easy even now and will be even easier soon - just look at observatory.less and theme() helper in observatoryTemplates.coffee. 

Installation
-----------------
#### With meteorite:

	mrt add observatory

#### Manually:
Copy observatory.coffee, inspect.js and client/ folder from the repo to your project. Add the Meteor packages this depends on (bootstrap, coffeescript, less, underscore). You should be up and running.

Usage
---------
Somewhere in the common code of your meteor app call:
```coffeescript
TL = TLog.getLogger(TLog.LOGLEVEL_MAX,true)
#for other options, see API section below
```
and then when you want to log a message of a certain log level:
```coffeescript
TL.fatal("your message","optional module name")
TL.error("your message","optional module name")
TL.warn("your message","optional module name")
TL.info("your message","optional module name")
TL.verbose("your message","optional module name")
```
To actually display the logs and use monitoring capabilities, plugin "logs_bootstrap" template anywhere in your Handlebars templates. Preferably right before closing body tag:
```html
<body>
  ...
  {{>logs_bootstrap}}
</body>
```

Everything else is done automagically, as always is the case with Meteor. See how it's done in [the sample app](https://github.com/jhoxray/telescope) and how it looks in the 
[live demo](http://observatory.meteor.com).


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
Log levels work in a very straightforward way: TLog will record any message which log level is <= current log level set when calling 
getLogger() or setOptions().

Feedback
----------
We'd love to hear what you think, whether it's useful and which other features you'd want to see -- so please submit issues here on github to share your thoughts and ideas!

Revision history
-----------------
####0.1.7
Some styling changes, module names support:

* added 2 themes: dark and light, switchable on the fly.

* added module names support to easier sort through logs.

* some css cleanup, started restyling to get away from Bootstrap dependency (still dependent though so if you use css names that
are the same as Twitter Bootstrap is using you may get weird effects in your app - will remove in a future version).

####0.1.5, 0.1.6
Bottom sliding panel with tabs added, monitoring / inspection capabilities added, files renamed, some cleanup started

####0.1.1 
Clean up for visibility / encapsulation, now need to use TLog.getLogger() instead of constructing directly

####0.1
Initial commit 

