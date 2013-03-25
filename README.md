What is it?
-------------
This is Observatory v0.2.1 - a [Meteorite](https://github.com/oortcloud/meteorite) package that provides powerful, efficient
and pretty logging and monitoring for [Meteor framework](http://meteor.com) application development.
[See it in action!](http://observatoryjs.com/).

What does it do?
------------------
* Easy logging with different log levels with corresponding methods for message output, optional 
logging to console, pretty output of both Client and Server logs right in the browser, optional logging of
the currently logged-in user for additional control.

* NEW! Logging of http requests (yes, with client-side IP address - an infamous topic among Meteor devs :))

* Monitoring of your application internals: currently, Templates with all events and a Session object; much more to come.

* 2 visual styles: "dark" for additional "terminal" coolness and "light" that may be easier on the eyes. Adding a new theme is pretty
easy even now and will be even easier soon - just look at observatory.less and theme() helper in observatoryTemplates.coffee.

* [experimental] Testing support for your Meteor app with BDD / TDD like syntax. This is currently in alpha and moved to a
[separate package](https://github.com/superstringsoftware/observatory-testing)

Installation
-----------------
#### With meteorite:

	mrt add observatory

Usage
---------
Somewhere in the common code of your meteor app call:
```coffeescript
TL = TLog.getLogger(TLog.LOGLEVEL_MAX,true, true, true)
#for other options, see API section below
```
This will get you a logger that will log everything, will also output to the console (second parameter),
will log current user (third parameter) and http requests (last parameter).

If you want to set logs removal permission, call allowRemove with allow function as an argument - it gets passed to
Collection.allow({remove: ...}) call. If you call allowRemove with no arguments, it simply sets "true" so use with care.
```coffeescript
TLog.allowRemove (uid)->
    if Meteor.users.findOne(uid) == "admin"
        true
    else
        false
```

When you want to log a message of a certain log level:
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
[live demo](http://observatoryjs.com).


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

If you are into internals type of person, Observatory logs all info to the "_observatory_logs"
Meteor collection. Every document has the following fields:
```coffeescript
@_logs.insert
    isServer: srv # boolean, whether called on the server or on the client
    message: msg # message provided to any of the logging methods
    module: module # module name provided to any of the logging methods
    loglevel: loglevel # loglevel with which the message is logged
    timestamp_text: ts # textual representation of the timestamp
    timestamp: timestamp # timestamp as a Date()
    full_message: full_message # full textual log message (useful for quick export etc)
    uid: uid # currently logged in user id (if log_user option set to true)
```
This should be enough if you want to manipulate your logs in any way you want that Observatory
does not provide out of the box. Access the "_observatory_logs" collection directly via
```coffeescript
col = TLog._global_logs
```
and then all the usual Meteor Collection API is applicable.


Feedback
----------
We'd love to hear what you think, whether it's useful and which other features you'd want to see -- so please submit issues here on github or [leave a comment on our blog](http://superstringsoftware.com) 
to share your thoughts and ideas!

Revision history
-----------------
####0.2.1: March 25, 2013
* Added http requests logging via connect middleware hook
* Changed UI behavior so that Observatory modifies last child of <body> to be able to scroll main site content up
* Preparation for Meteor 0.6.0 in terms of variables scoping
* Internal package restructuring - moved core logger etc to a separate package (to be released separately soon)
####0.2.0: March 18, 2013
First minor release with "real" Meteor (auth, users, ui improvements).
* Properly logging currently logged-in user
* Works with Meteor 0.5.9
* Code highlighting in the Templates Internals
* Session as a separate panel
* Unit testing moved to a [separate package](https://github.com/superstringsoftware/observatory-testing)
* Keyboard based control of the panels ("~" and "ctrl + ~")
* Setting default panel states via Session

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

