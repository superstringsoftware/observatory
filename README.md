What is it?
-------------
This is Observatory - package that provides powerful, efficient
and pretty logging, monitoring and application management for [Meteor framework](http://meteor.com) application
development and deployment.
[See it in action and read full usage docs!](http://observatoryjs.com/)

What does it do?
------------------
* Easy but very versatile logging with different log levels with corresponding methods for message output, optional
logging to console

* All your logs in one place, including system and Meteor logs, Mongo coming soon

* Log any or all client activity along with server logs, automatically record user and session information
 for additional security review or debugging

* Automagical logging, profiling and error handling for DDP, http, Collections, Subscriptions,
Template lifecycle methods (*soon*) and any custom code

* Detailed review of your application internals: publish and methods handlers, active sessions, collections
and more

* Remotely inspect *any object or function* live in your app, both on the server and *any client*

* Full-featured cloud-based monitoring and management of your Meteor applications:
[Observatory Vega Website](http://observatoryjs.com/)

Installation
-----------------
#### As a Meteor package:

	meteor add superstringsoft:observatory

Basic API Usage
---------
###### Manual Logging:
```javascript
tb = Observatory.getToolbox();
tb.warn("This is a warning message");
// plus all other logging methods for every level / severity, and ability to override it

// Full logging methods signature (see full docs for detailed description):
// options may contain: obj: custom_object, module: module_name (there's more in the docs)
tb.<logging_method> (message, options);
```
*Read about and use automagical using the documentation link below*
###### Manual Profiling:
```javascript
// when you have functions you want to profile:
f = function(x) {/* do something potentially complicated and taking a long time synchronously */ }
g = function(x, callback) {/* do something potentially complicated and taking a long time asynchronously */ }

// profile their execution, respecting Warning and Error thresholds
tb = Observatory.getToolbox();
// instead of y = f(14):
y = tb.profile ({method: "common > f()", message: "hope it doesn't happen"}, thisArg, f, 14 /* x=14 */);
// for async function, instead of g(x, callback):
tb.profileAsync ({method: "call to API > g()", message: "hope it doesn't happen"}, thisArg, g, x, callback);
```

There's *much* more.
[Read full docs](http://observatoryjs.com) and start using our cloud solution!


Feedback
----------
We'd love to hear what you think, whether it's useful and which other features you'd want to see
-- so please submit issues here on github or [leave a comment on our blog](http://meteorology.io)
to share your thoughts and ideas!

Revision history
-----------------

#### 0.9.1: October, 18, 2015
* Significant clean up of profiling methods (in Galileo) and Emitter architecture
* Hook into all server collections for future management in Vega
* Automagical Collections and Subscriptions profiling respects thresholds

### MAJOR: 0.9.0: October, 4, 2015
*Major changes, enhancements and additions after Observatory team got some strong corporate backing
and returned to the project with renewed commitment*
* Proper remote authentication meteor-way
* Architecture clean up
* Automagical support for collections and subscriptions
* Command Processor framework to support remote client and server object inspection, paving way
for the full-featured remote console
* Performance improvements
* Reactive online session monitoring support
* Hooks into Mongo database monitoring
* Log publish architecture enhancements to allow for better sorting, filtering and search

Most of these changes are fully benefited from when using [Observatory Vega](http://observatoryjs.com/)
cloud solution - improvements there are too numerous to list here, but it has a dedicated user guide
so we encourage you to sign up and try it!


#### 0.4.8: October, 4, 2014
* Heartbeat monitors published 
* Code DRYed in publishes
* Publishing logs based on time span instead of counts
* Monitors record online sessions

#### 0.4.7: October, 2, 2014
* Authorization improvements: localhost does not require one, graceful handling on the client

#### 0.4.6: September, 29, 2014
* Visual wizards and management options: all current settings can be managed via UI now
* API setup for advanced monitoring support

#### 0.4.5: September, 26, 2014
* Major code improvements
* Authentication
* Session monitoring support

#### 0.4.0: September, 24, 2014
* Bump to Meteor 0.9 & some re-architecturing

#### 0.3.2: September, 14, 2013
* Additional enhancements for cloud support:
	* Versioning
	* Handshakes
	* Heartbeats
* Profiler methods, minor bug fixes in Galileo
* Better & profiled automagical subscription logging

#### 0.3.0: September, 10, 2013
* Completely new modular architecture, based on Meteor-independent coffee-script
* Added monitoring, profiling and alpha automagical logging for Collections, Subscriptions and Templates
* Backward-compatible

#### 0.2.7: August, 31, 2013
* DDP server logging added
* Bug fixes in the client monitoring part
* Got rid of dependency on the bootstrap, fixed main panel, session needs more work

#### 0.2.6: August, 28, 2013
* Added Meteor.settings support
* Better user logging options
* Weak dependency on the bootstrap

#### 0.2.53: August, 19, 2013
* Updated to work with Meteor 0.6.5

#### 0.2.1: March 25, 2013
* Added http requests logging via connect middleware hook
* Changed UI behavior so that Observatory modifies last child of &lt;body&gt; to be able to scroll main site content up
* Preparation for Meteor 0.6.0 in terms of variables scoping
* Internal package restructuring - moved core logger etc to a separate package (to be released separately soon)

#### 0.2.0: March 18, 2013
First minor release with "real" Meteor (auth, users, ui improvements).
* Properly logging currently logged-in user
* Works with Meteor 0.5.9
* Code highlighting in the Templates Internals
* Session as a separate panel
* Unit testing moved to a [separate package](https://github.com/superstringsoftware/observatory-testing)
* Keyboard based control of the panels ("~" and "ctrl + ~")
* Setting default panel states via Session

#### 0.1.9: March 6, 2013
Update to support Meteor 0.5.7:
* New logging methods (debug, trace, dir)
* Meteor Authorization support
* Some clean up of the logs display in the panel
* Fixing template methods inspection for the new Meteor syntax
* Preview version of unit testing

#### 0.1.8: Oct, 2012
Minor code clean up, ability to clear logs.

#### 0.1.7
Some styling changes, module names support:
* added 2 themes: dark and light, switchable on the fly.
* added module names support to easier sort through logs.
* some css cleanup, started restyling to get away from Bootstrap dependency (still dependent though so if you use css names that
are the same as Twitter Bootstrap is using you may get weird effects in your app - will remove in a future version).

#### 0.1.5, 0.1.6
Bottom sliding panel with tabs added, monitoring / inspection capabilities added, files renamed, some cleanup started

#### 0.1.1
Clean up for visibility / encapsulation, now need to use TLog.getLogger() instead of constructing directly

#### 0.1
Initial commit 

