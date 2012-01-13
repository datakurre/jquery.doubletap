$ = jQuery  # See: http://stackoverflow.com/a/4534417

defaults = swipeTolerance: 40

touches = {}
latestTap = null


class touchStatus

  constructor: (target, @touch=touch, @options=options) ->
    @target = $(target)
    @startX = @currentX = @touch.screenX
    @startY = @currentY = @touch.screenY
    @eventType = null

  move: (touch) ->
    @currentX = touch.screenX
    @currentY = touch.screenY

  process: ->
    offsetX = @currentX - @startX
    offsetY = @currentY - @startY
    absOffsetX = Math.abs offsetX
    absOffsetY = Math.abs offsetY

    if offsetX == 0 and offsetY == 0
      do @checkForDoubleTap
    else if absOffsetY > @options.swipeTolerance and absOffsetY > absOffsetX
      @eventType = offsetY > 0 and "swipedown" or "swipeup"
      @target.trigger "swipe", [@]
    else if absOffsetX > @options.swipeTolerance
      @eventType = offsetX > 0 and "swiperight" or "swipeleft"
      @target.trigger "swipe", [@]

    if @eventType then @target.trigger @eventType, [@]
    @target.trigger "touch", [@]

  checkForDoubleTap: ->
    if latestTap and (new Date() - latestTap) < 400
      @eventType = "doubletap"
    if not @eventType then @eventType = "tap"
    latestTap = new Date()


class swipeEvents

  constructor: (elements, options) ->
    @options = $.extend defaults, options
    elements.bind "touchstart", (evt) => @touchStart evt
    elements.bind "touchmove", (evt) => @touchMove evt
    elements.bind "touchcancel", (evt) => @touchCancel evt
    elements.bind "touchend", (evt) => @touchEnd evt

  touchStart: (evt) -> @eachTouch evt, (touch) =>
    touches[touch.identifier] = new touchStatus evt.target, touch, @options

  touchMove: (evt) -> @eachTouch evt, (touch) =>
    touches[touch.identifier]?.move touch

  touchCancel: (evt) -> @eachTouch evt, (touch) =>
    @purge touch, true

  touchEnd: (evt) -> @eachTouch evt, (touch) =>
    @purge touch

  purge: (touch, cancelled) ->
    if not cancelled then do touches[touch.identifier]?.process
    delete touches[touch.identifier]

  eachTouch: (evt, callback) ->
    evt = evt.originalEvent
    num = evt.changedTouches.length
    callback evt.changedTouches[i] for i in [0...num]


###
Adds custom events:
-------------------

- touch      # all events
- swipe      # only swipe* events
- swipeleft
- swiperight
- swipeup
- swipedown
- tap
- doubletap
###

$.fn.addSwipeEvents = (options, callback) ->
  if not callback and $.isFunction options
    callback = options
    options = null
  if callback then @.bind "touch", callback
  new swipeEvents @, options
  return @
