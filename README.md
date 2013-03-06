What is it?
-------------
This is Observatory v0.1.9 - a [Meteorite](https://github.com/oortcloud/meteorite) package that provides powerful, efficient and pretty logging and monitoring for [Meteor framework](http://meteor.com) application development.
[See it in action!](http://observatoryjs.com/). This version added 2 new logging methods for tracing errors and quick-n-dirty object inspection,
as well as more configuration options for the Observatory Panel and experimental unit testing support.

What does it do?
------------------
* Easy logging with different log levels with corresponding methods for message output, optional 
logging to console, pretty output of both Client and Server logs right in the browser.

* Monitoring of your application internals: currently, Templates with all events and a Session object; more to come.

* 2 visual styles: "dark" for additional terminal coolness and "light" that may be easier on the eyes. Adding a new theme is pretty
easy even now and will be even easier soon - just look at observatory.less and theme() helper in observatoryTemplates.coffee.

* [experimental] Testing support for your Meteor app with BDD / TDD like syntax. This is currently in alpha.

Installation
-----------------
#### With meteorite:

	mrt add observatory

Usage
---------
Somewhere in the common code of your meteor app call:
```coffeescript
TL = TLog.getLogger(TLog.LOGLEVEL_MAX,true)
#for other options, see API section below
```
if you want to set logs removal permission, call allowRemove with allow function as an argument - it gets passed to
Collection.allow({remove: ...}) call. If you call allowRemove with no arguments, it simply sets "true" so use with care.
```coffeescript
TL.allowRemove (uid)->
    if Meteor.users.findOne(uid) == "admin"
        true
    else
        false
```
and then when you want to log a message of a certain log level:
```coffeescript
TL.fatal("your message","optional module name")
TL.error("your message","optional module name")
TL.warn("your message","optional module name")
TL.info("your message","optional module name")
TL.verbose("your message","optional module name")
TL.debug("your message","optional module name")

# tracing errors - correctly handles both Meteor and regular js errors
TL.trace(error, "your message", "optional module name")

# inspecting objects
TL.dir(object, "your message", "optional module name")
```
To actually display the logs and use monitoring capabilities, plugin "logs_bootstrap" template anywhere in your Handlebars templates. Preferably right before closing body tag:
```html
<body>
  ...
  {{>logs_bootstrap}}
</body>
```

To set the default panel to either hidden or half a screen, set the session variable:
```coffeescript
Session.set "bl_default_panel", "hidden" # or "half"
```

Everything else is done automagically, as always is the case with Meteor. See how it's done in [the sample app](https://github.com/jhoxray/telescope) and how it looks in the 
[live demo](http://observatory.meteor.com).


API
---------
In addition to the functions above here's a short description of what else you may need.
```coffeescript
class TLog
  #setting desired log level and whether you also want to output your log messages to the console (true or false)
  #Set log_user to true if you also want to log currently logged in user with every log message
  #userId is stored in the uid field of the log collection document.
  @getLogger: (currentLogLevel, printToConsole = true, log_user = false)->
  
  #log levels are defined as follows, so use TLog.LOGLEVEL_... when calling get Logger()
  @LOGLEVEL_FATAL = 0
  @LOGLEVEL_ERROR = 1
  @LOGLEVEL_WARNING = 2
  @LOGLEVEL_INFO = 3
  @LOGLEVEL_VERBOSE = 4
  @LOGLEVEL_DEBUG = 5
  @LOGLEVEL_MAX = 6

  #to change log level and console printing, use:
  setOptions: (loglevel, want_to_print = true, log_user = false)
```
Log levels work in a very straightforward way: TLog will record any message which log level is <= current log level set when calling 
getLogger() or setOptions().

Feedback
----------
We'd love to hear what you think, whether it's useful and which other features you'd want to see -- so please submit issues here on github or [leave a comment on our blog](http://superstringsoftware.com) 
to share your thoughts and ideas!

Revision history
-----------------
####0.1.9: March 6, 2013
Update to support Meteor 0.5.7:
* New logging methods (debug, trace, dir)
* Meteor Authorization support
* Some clean up of the logs display in the panel
* Fixing template methods inspection for the new Meteor syntax
* Preview version of unit testing

####0.1.8: Oct, 2012
Minor code clean up, ability to clear logs.

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

