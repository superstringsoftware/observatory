Template.logs_bootstrap.events
  #Trying to make "~" work but it's not working...
  ###
  "keydown": (evt)->
    #$("#id_logs_bootstrap").toggle("fast")
    console.log("key pressed: " + evt.which)
  ###

  #showing the source code for the chosen event
  "mouseenter .lb_template_events_list": (evt)->
    func = Template[evt.target.getAttribute("templateName")]._tmpl_data.events[evt.target.getAttribute("eventName")]
    $("#lb_code_console").text(func.toString())

  #switching main tabs in the panel
  "click #lb_main_tab": (evt)->
    tg = evt.target.getAttribute("href")
    #TLog.getLogger().warn("Clicked on " + tg)
    if tg
      $(".tab-pane").hide()
      $(tg).show()

  ###
  "click #lb_btn_switch_dynamic": ->
    s = if Session.get "bl_is_dynamic" then false else true
    Session.set "bl_is_dynamic", s
  ###

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
        #Meteor.flush()
        #$("#id_logs_bootstrap").addClass("lb_hidden")
        #console.dir $("#id_logs_bootstrap")
        $("#id_logs_bootstrap").hide("fast")
        Session.set "bl_is_visible", false

      when "height25"
        #Meteor.flush()
        Session.set("bl_panel_height_class","height50")
        Session.set("bl_full_featured_panel",true)
      when ""
        Session.set "bl_is_dynamic", true
        Session.set("bl_panel_height_class","height25")
        Session.set("bl_full_featured_panel",false)
        Session.set "bl_is_visible", true
        #Meteor.flush()
        $("#id_logs_bootstrap").removeClass("lb_hidden")
        $("#id_logs_bootstrap").show("slow")
    ###
    if Session.get("bl_panel_height_class") is "height50"
      Session.set("bl_panel_height_class","height90")
      Session.set("bl_full_featured_panel",true)
    else
      if Session.get("bl_panel_height_class") is "height90"
        Session.set("bl_panel_height_class","")
        Meteor.flush()
        $("#id_logs_bootstrap").hide("fast")

      else
        if Session.get("bl_panel_height_class") is "height25"
          Session.set("bl_panel_height_class","height50")
          Session.set("bl_full_featured_panel",true)
        else
          Session.set("bl_panel_height_class","height25")
          Session.set("bl_full_featured_panel",false)
          Meteor.flush()
          $("#id_logs_bootstrap").show("slow")
    ###
    Meteor.flush()




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


#Twitter Bootstrap formatted template
_.extend Template.logs_bootstrap,

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

#setting initial sort order for the logs  
  created: ->
    Session.set("bl_sort_desc", true)
    Session.set("bl_sort_by","timestamp")
    Session.set("bl_full_featured_panel",false)
    Session.set("bl_panel_height_class","")
    Session.set("bl_current_theme", "lb_theme_dark")
    Session.set "bl_is_dynamic", false  # defaults for hidden. for showing: change height_class to height25, dynamic & visible - to true
    Session.set "bl_is_visible", false


    

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
