What is it?
-------------
This is Observatory v0.3.0 - a [Meteorite](https://github.com/oortcloud/meteorite) package that provides powerful, efficient
and pretty logging and monitoring for [Meteor framework](http://meteor.com) application development.
[See it in action and read full usage docs!](http://observatoryjs.com/).

What does it do?
------------------
* Easy logging with different log levels with corresponding methods for message output, optional 
logging to console, pretty output of both Client and Server logs right in the browser, optional logging of
the currently logged-in user for additional control.

* Augomagical logging, profiling and error handling for DDP, http, Collections, Subscriptions, Template lifecycle methods and any custom code

* Monitoring of your application internals: currently, Templates with all events and a Session object; much more to come.

* Coming up soon! Full-featured cloud-based monitoring and management of your Meteor applications.

Installation
-----------------
#### With meteorite:

	mrt add observatory

Usage
---------

[Read full docs](http://observatoryjs.com).



Feedback
----------
We'd love to hear what you think, whether it's useful and which other features you'd want to see -- so please submit issues here on github or [leave a comment on our blog](http://meteorology.io) 
to share your thoughts and ideas!

Revision history
-----------------
####0.3.0: September, 10, 2013
* Completely new modular architecture, based on Meteor-independent coffee-script
* Added monitoring, profiling and alpha automagical logging for Collections, Subscriptions and Templates
* Backward-compatible

####0.2.7: August, 31, 2013
* DDP server logging added
* Bug fixes in the client monitoring part
* Got rid of dependency on the bootstrap, fixed main panel, session needs more work

####0.2.6: August, 28, 2013
* Added Meteor.settings support
* Better user logging options
* Weak dependency on the bootstrap

####0.2.53: August, 19, 2013
* Updated to work with Meteor 0.6.5

####0.2.1: March 25, 2013
* Added http requests logging via connect middleware hook
* Changed UI behavior so that Observatory modifies last child of &lt;body&gt; to be able to scroll main site content up
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

