_tlog = TLog.getLogger()

Meteor.startup ->
  Handlebars.registerHelper "blGetSession", (name) ->
    Session.get name


############################################################################################################
# EVENTS
# Main Observatory Panel Template
############################################################################################################
#Session.get "bl_default_panel" - "hidden" or "half"
Template.logs_bootstrap.events
  #switching main tabs in the panel
  "click #lb_main_tab": (evt)->
    tg = evt.target.getAttribute("data-target")
    #TLog.getLogger().warn("Clicked on " + tg)
    Session.set "observatoryjs-currentRender", tg if tg


  #switching themes
  "click #lb_btn_change_theme": ->
    if Session.get("bl_current_theme") is "lb_theme_dark"
      Session.set("bl_current_theme", "lb_theme_light")
      Session.set("bl_current_codemirror_theme", "solarized")
    else
      Session.set("bl_current_theme", "lb_theme_dark")
      Session.set("bl_current_codemirror_theme", "ambiance")

  #clearing the logs - DANGEROUS and insecure
  #TODO: once auth arrives, make sure it's properly protected
  "click #lb_btn_clear_logs": ->
    #alert "This is a demo app so no logs are in fact cleared! Install in your project and it will work properly :)"
    TLog._clear()

  "click #btn_toggle_session": ->
    w = Session.get "bl_current_session_width"
    switch w
      when "lb_invisible"
        Session.set "bl_current_session_width", "lb_width25"
      when "lb_width25"
        Session.set "bl_current_session_width", "lb_width50"
      when "lb_width50"
        Session.set "bl_current_session_width", "lb_invisible"


  #Switching modes of the observatory panel
  "click #btn_toggle_logs": (evt, tmpl)->
    Template.logs_bootstrap.toggleLogs()

############################################################################################################
# HELPERS
# Main Observatory Panel Template
############################################################################################################
Template.logs_bootstrap.helpers
  observatoryjsRenderCurrent: ->
    tmpl = Session.get "observatoryjs-currentRender"
    if Template[tmpl]
      new Handlebars.SafeString(Template[tmpl]())
    else
      new Handlebars.SafeString(Template["observatoryjsLogsTab"]())

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

############################################################################################################
# OTHER
# Main Observatory Panel Template
############################################################################################################
#Twitter Bootstrap formatted template
_.extend Template.logs_bootstrap,
  toggleLogs: ->
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


    #console.log "Setting margin-bottom of the last element to #{tt} px"
    #console.dir $("body").children().last()
    Deps.flush()

    if Session.equals "bl_is_visible", true
      tt = $('#id_logs_bootstrap').outerHeight()
      #console.dir "Current height is #{tt}"
      $("body").children().last().css('margin-bottom', tt + 20)
    else
      $("body").children().last().css('margin-bottom', 0) #Template.logs_bootstrap.originalMainMargin)



  destroyed: ->
    #Meteor.clearInterval @_handle

   #setting initial sort order for the logs
  created: ->
    #Template.logs_bootstrap.originalMainMargin = $("body").children().last().css('margin-bottom')
    #console.log "Remembering margin as #{Template.logs_bootstrap.originalMainMargin}"
    def = Session.get "bl_default_panel"
    if def? then Template.logs_bootstrap.setDefault def else Template.logs_bootstrap.setDefault "hidden"
    Session.setDefault "bl_current_codemirror_theme", "ambiance"
    Session.setDefault "bl_current_session_width", "lb_invisible"
    #Session.setDefault "observatoryjs-currentRender", "observatoryjsLogsTab"

    # checking connection status
    Deps.autorun ->
      #_tlog.debug "Calling function that polls connection status (supposedly)..."
      Session.set "observatoryjs.ConnectionStatus", Meteor.status()



  rendered: ->
    # setting whatever last elements bottom marging is to manipulate in observatory panel size changes
    Session.setDefault "observatoryjs-currentRender", "observatoryjsLogsTab"
    # handling key presses to toggle session and the panel
    $('body').on 'keydown', (evt)->
      #console.dir evt
      evt.stopImmediatePropagation()
      #console.log 'key pressed: ' + evt.which
      if evt.which == 192 and not $(evt.target).is "input"
        if evt.ctrlKey
          Template.logs_bootstrap.toggleLogs()
        else
          w = Session.get "bl_current_session_width"
          switch w
            when "lb_invisible"
              Session.set "bl_current_session_width", "lb_width25"
            when "lb_width25"
              Session.set "bl_current_session_width", "lb_width50"
            when "lb_width50"
              Session.set "bl_current_session_width", "lb_invisible"






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



######################################################################################################################
# Template handling application internals
# EVENTS
######################################################################################################################
Template.observatoryjsInternalsTab.events
  "mouseleave .lb_template_events_list": (evt, templ)->
    selTmpl = Template[evt.target.getAttribute("templateName")]
    method = evt.target.getAttribute("methodName")
    func = selTmpl._tmpl_data.events?[method]
    if func
      events = method.split ','
      for e in events
        k = e.split ' '
        $(k[1]).removeClass "lb_highlight_element"

  #showing the source code for the chosen event
  "mouseenter .lb_template_events_list": (evt, templ)->
    selTmpl = Template[evt.target.getAttribute("templateName")]
    method = evt.target.getAttribute("methodName")
    #console.log "Entered: " + evt.target.getAttribute("templateName") + " w/ method: " + method
    if method in ["created","rendered","destroyed"]
      func = selTmpl[method]
      strFunc = "// Template." + evt.target.getAttribute("templateName") + "." + method + ":\n" + func
      #_tlog.debug "Method is a key callback:\n" + strFunc
    else
      func = selTmpl._tmpl_data.events?[method]
      if func
        strFunc = "// EVENT: " + method + ":\n" + func
        #_tlog.debug "Method is an event:\n" + strFunc
        events = method.split ','
        for e in events
          k = e.split ' '
          $(k[1]).addClass "lb_highlight_element"
      else
        func = selTmpl._tmpl_data.helpers?[method]
        strFunc = "// HELPER: " + method + ":\n" + func
        #_tlog.debug "Method is a helper:\n" + strFunc
    #console.dir templ
    #console.log "Setting codemirror field with " + strFunc
    templ.myCodeMirror.setValue strFunc
    #templ.myCodeMirror.refresh()
    #console.dir templ.myCodeMirror.doc.children
    #$("#lb_code_console").html strFunc

    #console.log func.toString()

  "change #selTemplateNames": (evt)->
    _tlog.debug $(evt.target).val()
    Session.set "bl_selected_template_name", $(evt.target).val()


######################################################################################################################
# Template handling application internals
# HELPERS
######################################################################################################################
Template.observatoryjsInternalsTab.helpers
  selectedTemplateName: ->
    Session.get "bl_selected_template_name"

  #Templates
  templates: ->
    rt = Inspect.methods(Template)
    rt.sort()
    rt

  currentTemplateEvents: ->
    Template.observatoryjsInternalsTab.getMethodMap "events",Session.get "bl_selected_template_name"

  currentTemplateHelpers: ->
    Template.observatoryjsInternalsTab.getMethodMap "helpers",Session.get "bl_selected_template_name"


######################################################################################################################
# Template handling application internals
# OTHER
######################################################################################################################
_.extend Template.observatoryjsInternalsTab,
  destroyed: ->
    Meteor.clearInterval @_handle

  created: ->
    # monitoring state of collections and subscriptions
    # TODO: style it
    # TODO: create collection monitoring area
    @_handle = Meteor.setInterval =>
      @_subscriptions = (v for k,v of TLog._global_logs._manager._subscriptions)
      @_collections = Meteor._LocalCollectionDriver.collections
      Session.set "observatoryjs.CurrentSubscriptions", @_subscriptions
    , 5000

  rendered: ->
    $("#selTemplateNames").val Session.get "bl_selected_template_name"
    Session.set "bl_selected_template_name", $("#selTemplateNames").val()
    #tmp = $("#selTemplateNames").val()
    #console.log tmp + " and " + Session.get "bl_selected_template_name"
    @myCodeMirror = null
    if not @myCodeMirror?
      @myCodeMirror = CodeMirror document.getElementById("lb_code_console"),
        value: ""
        mode:  "javascript"
        theme: Session.get "bl_current_codemirror_theme"
        readOnly: true
      #Meteor.flush()

  getMethodMap: (type, tmpl)->
    rt = []
    rt.push tt for tt of Template[tmpl]?._tmpl_data[type]
    rt.sort()


######################################################################################################################
# Template handling Session
# HELPERS
######################################################################################################################
Template.observatoryjsSession.helpers
  sessionWidth: ->
    Session.get("bl_current_session_width")
  #returning current theme class
  theme: ->
    Session.get("bl_current_theme")
  #Filling Session keys
  session_keys: ->
    rt = []
    rt.push {"key": key, "value": JSON.stringify Session.get(key)} for key of Session.keys
    rt.sort()



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
Template.observatoryjsLogsTab.helpers
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
    #console.log "Formatting date: " + ts
    #ts
    d = new Date(ts)
    TLog._convertTime(d)

  getUser: (log)->
    uid = log.uid
    user = ""
    if uid
      u = Meteor.users.findOne(uid)
      if u and u.username
        user = u.username
      else
        if u and u.emails and u.emails[0]
          user = u.emails[0].address
        else
          user = uid
    else if log.ip then user = log.ip
    user


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
_.extend Template.observatoryjsLogsSimple,
  log_messages: ->
    TLog._getLogs()
