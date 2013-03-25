# Make an element draggable using jQuery
ObservatoryJS = {}
ObservatoryJS.makeDraggable = (element) ->
  element = jQuery(element)
  console.log "Called makeDraggable "
  console.dir element

  # Move the element by the amount of change in the mouse position
  move = (event) ->
    if element.data("mouseMove")
      changeX = event.clientX - element.data("mouseX")
      changeY = event.clientY - element.data("mouseY")
      newX = parseInt(element.css("left")) + changeX
      newY = parseInt(element.css("top")) + changeY
      element.css "left", newX
      element.css "top", newY
      element.data "mouseX", event.clientX
      element.data "mouseY", event.clientY

  element.mousedown (event) ->
    element.data "mouseMove", true
    element.data "mouseX", event.clientX
    element.data "mouseY", event.clientY

  element.parents(":last").mouseup ->
    element.data "mouseMove", false

  element.mouseout move
  element.mousemove move