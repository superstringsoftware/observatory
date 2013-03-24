Inspect =
  TYPE_FUNCTION: "function"

  # Returns an array of (the names of) all methods
  methods: (obj) ->
    testObj = obj or self
    methods = []
    for prop of testObj
      methods.push prop  if typeof testObj[prop] is Inspect.TYPE_FUNCTION and typeof Inspect[prop] isnt Inspect.TYPE_FUNCTION
    methods


  # Returns an array of (the names of) all properties
  properties: (obj) ->
    testObj = obj or self
    properties = []
    for prop of testObj
      properties.push prop  if typeof testObj[prop] isnt Inspect.TYPE_FUNCTION and typeof Inspect[prop] isnt Inspect.TYPE_FUNCTION
    properties

(exports ? this).Inspect = Inspect