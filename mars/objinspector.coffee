
######################################################################################################################
# Object Inspector
######################################################################################################################

#
# UTILITY
#

_.extend Template.observatoryjsObjectInspector, 

  isObject: (vl) ->
    if _.isObject(vl)
      not(_.isString(vl) or _.isNumber(vl) or _.isBoolean(vl) or _.isDate(vl) or _.isRegExp(vl))
    else
      false

  getType: (vl) ->
    if _.isObject(vl) then /function\s*(.+)\s*\(/.exec(vl.constructor.toString())[1] else typeof(vl)

  objectInfo: (ar) ->
    obj = if Meteor.isClient then window else global
    for i in ar
      break unless obj[i]?
      obj = obj[i]
    
    info = { p: [], f: [] }
    for itemName of obj
      if _.has(obj, itemName)
        if _.isFunction(obj[itemName])
          info.f.push
            i: itemName
            v: obj[itemName].toString()
        else
          info.p.push
            i: itemName
            t: @getType(obj[itemName])
            o: @isObject(obj[itemName])
            v: if @isObject(obj[itemName]) then undefined else "" + obj[itemName]
    info
  
  beginItem: ->
    ol = Session.get('oi_object_list')
    if _.isArray(ol) and ol.length > 0 then [ol[0][0],ol[0][1]] else []

  setObjectInfo: ->
    b = Session.get('oi_breadcrumbs')
    i = _.find Session.get('oi_object_list'), (item) ->
          b[1] == item[1] and b[0] == item[0]
    if i
      objectPath = i.slice(2).concat(b.slice(2))
      if i[0] == 'c'
        Session.set('oi_object_info', Template.observatoryjsObjectInspector.objectInfo(objectPath))
      else
        Meteor.call 'oiObjectInfo', objectPath, (e,r) ->
          Session.set('oi_object_info', r)
    true

  rendered: ->
    @myCodeMirror = null
    if not @myCodeMirror?
      @myCodeMirror = CodeMirror(document.getElementById("oi_property_view"),
        value: ""
        mode:  "javascript"
        theme: Session.get("bl_current_codemirror_theme")
        readOnly: true
      )
      true

  created: ->
    Session.set('oi_object_info', {})
    Session.set('oi_breadcrumbs', Template.observatoryjsObjectInspector.beginItem())
    Template.observatoryjsObjectInspector.setObjectInfo()

#
# HELPERS
#

Template.observatoryjsObjectInspector.helpers
  getType: (it,i) ->
    Template.observatoryjsObjectInspector.getType(it[i])
  
  objectList: ->
    _.map Session.get('oi_object_list'), (item) ->
      { t: item[0] + ':' + item[1], n: item[1] }

  infoObject: ->
    Session.get('oi_object_info')
      
  breadcrumbsItems: ->
    br = Session.get('oi_breadcrumbs')
    if _.isArray(br) and br.length > 0 then {k:k,v:v} for k,v of _.initial(br).slice(1) else []
  
  breadcrumbsLast: ->
    br = Session.get('oi_breadcrumbs')
    if _.isArray(br) and br.length > 0 then _.last(br) else ''

#
# EVENTS
#

Template.observatoryjsObjectInspector.events
  'mouseenter .oi_property_list_item': (e,t) ->
    $('.oi_property_list_item').removeClass('selected')
    $(e.target).addClass('selected')
    t.myCodeMirror.setValue(if this.o then "" else this.v)
    true
  
  'click .oi_property_list_item': () ->
    if this.o
      br = Session.get('oi_breadcrumbs')
      br.push(this.i)
      Session.set('oi_breadcrumbs',br)
      Template.observatoryjsObjectInspector.setObjectInfo()
    true
  
  'click .oi_breadcrumb a': (e) ->
    br = Session.get('oi_breadcrumbs')
    i = parseInt($(e.target).data('index'))
    Session.set('oi_breadcrumbs', br.slice(0,i+1))
    Template.observatoryjsObjectInspector.setObjectInfo()
    true
  
  'change select.oi_object_selector': (e) ->
    v = $(e.target).val().split(':')
    Session.set('oi_breadcrumbs', [v[0],v[1]])
    Template.observatoryjsObjectInspector.setObjectInfo()
    true

#
# METHODS
#

if Meteor.isServer
  Meteor.methods
    oiObjectInfo: (objectPath) ->
      Template.observatoryjsObjectInspector.objectInfo(objectPath)

if Meteor.isClient
  Meteor.startup ->

    #
    # INIT 
    #
    # The item of oi_object_list has a type, a name, a path from global object.
    # The type can be 'c' or 's'. 'c' is browser object, 's' is server object.
    # The global object in browser is Window but in server is Global.
    # Don't use colon in the name.
    #

    Session.set('oi_object_list', 
     [['c','Meteor','Meteor'],
      ['c','Template','Template'],
      ['c','c Session','Session'],
      ['c','c Deps','Deps'],
      ['s','s Deps','Deps'],
      ['s','s Session','Session']]);
