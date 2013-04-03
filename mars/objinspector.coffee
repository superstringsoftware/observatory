
######################################################################################################################
# Object Isspector
######################################################################################################################

#
# UTILITY
#

_.extend Template.observatoryjsObjectInspector, 
  lastObject: (context) ->
    b = Session.get('object_inspector_breadcrumbs')
    if b
      obj = window[b[0]]
      for i in Session.get('object_inspector_breadcrumbs').slice(1)
        obj = obj[i] if obj[i]?
      obj
    else
      {}

  isObject: (vl) ->
    if _.isObject(vl)
      not(_.isString(vl) or _.isNumber(vl) or _.isBoolean(vl) or _.isDate(vl) or _.isRegExp(vl))
    else
      false

  itemType: (vl) ->
    unless @isObject(vl)
      if _.isObject(vl) then /function\s*(.+)\s*\(/.exec(vl.constructor.toString())[1] else typeof(vl)

  objectInfo: (obj) ->
    info = { p: [], f: [] }
    for itemName of obj
      if _.has(obj, itemName)
        if _.isFunction(obj[itemName])
          info.f.push({ i: itemName, it: obj })
        else
          info.p.push({ i: itemName, it: obj, o: @isObject(obj[itemName]) })
    info.f.sort()
    info.p.sort()
    info

  objectList: ->
    ['Template','Session']

  rendered: ->
    @myCodeMirror = null
    if not @myCodeMirror?
      @myCodeMirror = CodeMirror(document.getElementById("oi_property_view"),
        value: ""
        mode:  "javascript"
        theme: Session.get("bl_current_codemirror_theme")
        readOnly: true
      )
 
Session.set('object_inspector_breadcrumbs', [Template.observatoryjsObjectInspector.objectList()[0]])

#
# HELPERS
#

Template.observatoryjsObjectInspector.helpers
  itemType: (it,i) ->
    Template.observatoryjsObjectInspector.itemType(it[i])
  objectList: ->
    Template.observatoryjsObjectInspector.objectList
  infoLastObject: ->
    obj = Template.observatoryjsObjectInspector
    obj.objectInfo(obj.lastObject(window))
  breadcrumbsItems: ->
    br = Session.get('object_inspector_breadcrumbs')
    { k: k, v: v } for v,k in br.slice(0,-1)
  breadcrumbsLast: ->
    br = Session.get('object_inspector_breadcrumbs')
    if br then br.pop() else ''

#
# EVENTS
#

Template.observatoryjsObjectInspector.events
  'mouseenter .oi_property_list_item': (e,t) ->
    $('.oi_property_list_item').removeClass('selected')
    $(e.target).addClass('selected')
    t.myCodeMirror.setValue(if this.o then "" else this.it[this.i].toString())
    true
  'click .oi_property_list_item': () ->
    if typeof(this) == 'object' and this.o
      br = Session.get('object_inspector_breadcrumbs')
      br.push(this.i)
      Session.set('object_inspector_breadcrumbs',br)
  'click .oi_breadcrumb a': (e) ->
    br = Session.get('object_inspector_breadcrumbs')
    i = parseInt($(e.target).data('index'))
    Session.set('object_inspector_breadcrumbs', br.slice(0,i+1))
    true
  'change select.oi_object_selector': (e) ->
    Session.set('object_inspector_breadcrumbs', [$(e.target).val()])


