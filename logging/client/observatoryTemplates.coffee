Meteor.startup ->
  Handlebars.registerHelper "observatoryjsRender", (name, options) ->
    new Handlebars.SafeString(Template[name](options)) if Template[name]

#Session.get "bl_default_panel" - "hidden" or "half"
Template.logs_bootstrap.events
  #Trying to make "~" work but it's not working...
  ###
  "keydown": (evt)->
    #$("#id_logs_bootstrap").toggle("fast")
    console.log("key pressed: " + evt.which)
  ###

  #switching main tabs in the panel
  "click #lb_main_tab": (evt)->
    tg = evt.target.getAttribute("data-target")
    #TLog.getLogger().warn("Clicked on " + tg)
    Session.set "observatoryjs-currentRender", tg if tg


  #switching themes
  "click #lb_btn_change_theme": ->
    if Session.get("bl_current_theme") is "lb_theme_dark"
      Session.set("bl_current_theme", "lb_theme_light")
    else
      Session.set("bl_current_theme", "lb_theme_dark")

  #clearing the logs - DANGEROUS and insecure
  #TODO: once auth arrives, make sure it's properly protected
  "click #lb_btn_clear_logs": ->
    #alert "This is a demo app so no logs are in fact cleared! Install in your project and it will work properly :)"
    TLog._clear()

  #Switching modes of the observatory panel
  "click #btn_toggle_logs": ->
    switch Session.get("bl_panel_height_class")
      when "height50"
        Session.set "bl_is_dynamic", false
        Session.set("bl_panel_height_class","height90")
        Session.set("bl_full_featured_panel",true)
      when "height90"
        Session.set("bl_panel_height_class","")
        $("#id_logs_bootstrap").hide("fast")
        Session.set "bl_is_visible", false
      when "height25"
        Session.set("bl_panel_height_class","height50")
        Session.set("bl_full_featured_panel",true)
      when ""
        Session.set "bl_is_dynamic", true
        Session.set("bl_panel_height_class","height25")
        Session.set("bl_full_featured_panel",false)
        Session.set "bl_is_visible", true
        $("#id_logs_bootstrap").removeClass("lb_hidden")
        $("#id_logs_bootstrap").show("slow")

    Meteor.flush()


#Twitter Bootstrap formatted template
_.extend Template.logs_bootstrap,
   #setting initial sort order for the logs
  created: ->
   def = Session.get "bl_default_panel"
   if def? then Template.logs_bootstrap.setDefault def else Template.logs_bootstrap.setDefault "hidden"
   #Session.setDefault "observatoryjs-currentRender", "observatoryjsLogsTab"


  rendered: ->
   Session.setDefault "observatoryjs-currentRender", "observatoryjsLogsTab"


  observatoryjsRenderCurrent: ->
    tmpl = Session.get "observatoryjs-currentRender"
    console.log "Called render current with " + tmpl
    if Template[tmpl]
      new Handlebars.SafeString(Template[tmpl]())
    else
      new Handlebars.SafeString(Template["observatoryjsLogsTab"]())

  # setting default panel status - hidden or 50% of the screen
  setDefault: (option)->
    switch option
      when "hidden"
        Session.setDefault "bl_sort_desc", true
        Session.setDefault "bl_sort_by","timestamp"
        Session.setDefault "bl_full_featured_panel",false
        Session.setDefault "bl_panel_height_class",""
        Session.setDefault "bl_current_theme", "lb_theme_dark"
        Session.setDefault "bl_is_dynamic", false  # defaults for hidden. for showing: change height_class to height25, dynamic & visible - to true
        Session.setDefault "bl_is_visible", false
      when "half"
        Session.setDefault "bl_sort_desc", true
        Session.setDefault "bl_sort_by","timestamp"
        Session.setDefault "bl_full_featured_panel",false
        Session.setDefault "bl_panel_height_class","height25"
        Session.setDefault "bl_current_theme", "lb_theme_dark"
        Session.setDefault "bl_is_dynamic", true
        Session.setDefault "bl_is_visible", true


  isHidden: ->
    return !(Session.get "bl_is_visible")

  isDynamic: ->
    return Session.get "bl_is_dynamic"
  #helper to display either full panel or trimmed down version (e.g., just the logs)
  fullFeatured: ->
    Session.get("bl_full_featured_panel")

  #returning current theme class
  theme: ->
    Session.get("bl_current_theme")
    #"lb_theme_light"

  #helper returning the class that corresponds to needed height of the panel
  height: ->
    Session.get("bl_panel_height_class")



######################################################################################################################
# Template handling application internals
# HELPERS
######################################################################################################################
Template.observatoryjsInternalsTab.events
#showing the source code for the chosen event
  "mouseenter .lb_template_events_list": (evt, templ)->
    #Meteor.flush()
    #console.log evt.target
    func = Template[evt.target.getAttribute("templateName")]._tmpl_data.events[evt.target.getAttribute("eventName")]
    #console.dir templ
    templ.myCodeMirror.setValue func.toString()
    #Meteor.flush()
    #console.log func.toString()

_.extend Template.observatoryjsInternalsTab,

  rendered: ->
    @myCodeMirror = null
    if not @myCodeMirror?
      @myCodeMirror = CodeMirror document.getElementById("lb_code_console"),
        value: ""
        mode:  "javascript"
        theme: "ambiance"
        readOnly: true
      Meteor.flush()

  #Filling Session keys
  session_keys: ->
    rt = new Array()
    i = 0
    for key of Session.keys
      rt[i] = {"key": key, "value":Session.get(key)}
      i++
    rt

  #Templates
  templates: ->
    rt = Inspect.methods(Template)
    rt.sort()
    rt

  #events for a given template
  template_events: (tmpl)->

    rt = []
    i = 0
    for tt of Template[tmpl]._tmpl_data.events

      rt.push({_id:"id_event_no_"+i,name:tt})
      i++
    rt.sort()
    rt

######################################################################################################################
# Template handling log display
# EVENTS
######################################################################################################################
Template.observatoryjsLogsTab.events
  #Sort functions go below;
  #TODO: put them all in one and optimize
  "click #lbh_timestamp": ->
    #TLog._getLogger().verbose("clicked on timestamp")
    Session.set("bl_sort_by","timestamp")
    sort_desc = Session.get("bl_sort_desc")
    if sort_desc then Session.set("bl_sort_desc",false) else Session.set("bl_sort_desc",true)

  "click #lbh_module": ->
    #TLog._getLogger().verbose("clicked on severity")
    Session.set("bl_sort_by","module")
    sort_desc = Session.get("bl_sort_desc")
    if sort_desc then Session.set("bl_sort_desc",false) else Session.set("bl_sort_desc",true)

  "click #lbh_severity": ->
    #TLog._getLogger().verbose("clicked on severity")
    Session.set("bl_sort_by","severity")
    sort_desc = Session.get("bl_sort_desc")
    if sort_desc then Session.set("bl_sort_desc",false) else Session.set("bl_sort_desc",true)

  "click #lbh_source": ->
    #TLog._getLogger().verbose("clicked on source")
    Session.set("bl_sort_by","source")
    sort_desc = Session.get("bl_sort_desc")
    if sort_desc then Session.set("bl_sort_desc",false) else Session.set("bl_sort_desc",true)

######################################################################################################################
# Template handling log display
# HELPERS
######################################################################################################################
_.extend Template.observatoryjsLogsTab,
#filling relevant log messages based on the current sort parameters
  log_messages: ->
    sort_order = if Session.get("bl_sort_desc") then -1 else 1
    sort = {timestamp: sort_order}
    switch Session.get("bl_sort_by")
      when "severity" then sort = {loglevel: sort_order}
      when "source" then sort = {isServer: sort_order}
      when "module" then sort = {module: sort_order}
    TLog._getLogs(sort)

#helper to get log level / severity names
  loglevel_names: (i)->
      TLog.LOGLEVEL_NAMES[i]


#timestamp formatting helper for the display
  format_timestamp: (ts)->
    d = new Date(ts)
    TLog._convertTime(d)

#applying class to labels showing loglevel / severity
  lb_loglevel_decoration: ->
    switch @loglevel
      when TLog.LOGLEVEL_FATAL then cl = "label-inverse"
      when TLog.LOGLEVEL_ERROR then cl = "label-important"
      when TLog.LOGLEVEL_WARNING then cl = "label-warning"
      when TLog.LOGLEVEL_INFO then cl = "label-info"
      when TLog.LOGLEVEL_VERBOSE then cl = "label-success"

#apllying class to the message text (<td>) based on loglevel
  lb_loglevel_msg_decoration: ->
    switch @loglevel
      when TLog.LOGLEVEL_FATAL then cl = "lb_msg_error"
      when TLog.LOGLEVEL_ERROR then cl = "text-error"#"lb_msg_error"
      when TLog.LOGLEVEL_WARNING then cl = "lb_msg_warning"

#apllying class to the whole log row based on loglevel
  lb_loglevel_row_decoration: ->
    # Turning OFF for now as this is needed for the "light" scheme

    switch @loglevel
      when TLog.LOGLEVEL_FATAL then cl = "error"
      when TLog.LOGLEVEL_ERROR then cl = "error"
      when TLog.LOGLEVEL_WARNING then cl = "warning"

# very basic template
_.extend Template.logs_simple,
  log_messages: ->
    TLog._getLogs()
