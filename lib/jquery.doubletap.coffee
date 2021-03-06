# jquery.doubletap.coffee
#   Copyright (c) 2012- Asko Soukka <asko.soukka@iki.fi>
#
# based on jquery.doubletap.js
#   Copyright (c) 2010-* rick olson
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

$ = jQuery  # See: http://stackoverflow.com/a/4534417

defaults = swipeTolerance: 40, preventDefault: []

allTouches = {}
latestTap = null


class touchStatus

  constructor: (target, @touch, @options) ->
    @target = $(target)
    @startX = @currentX = @touch.screenX
    @startY = @currentY = @touch.screenY

  move: (touch) ->
    @currentX = touch.screenX
    @currentY = touch.screenY
    return

  process: ->
    offsetX = @currentX - @startX
    offsetY = @currentY - @startY
    absOffsetX = Math.abs offsetX
    absOffsetY = Math.abs offsetY

    if offsetX == 0 and offsetY == 0
      # "doubletap" or "tap"
      if latestTap and (new Date() - latestTap) < 400
        @eventType = "doubletap"
        latestTap = null
      else
        @eventType = "tap"
        latestTap = new Date()
    else if absOffsetY > @options.swipeTolerance and absOffsetY > absOffsetX
      # "swipedown" or "swipeup"
      @eventType = offsetY > 0 and "swipedown" or "swipeup"
      @target.trigger "swipe", [@]
    else if absOffsetX > @options.swipeTolerance
      # "swiperight" or "swipeleft"
      @eventType = offsetX > 0 and "swiperight" or "swipeleft"
      @target.trigger "swipe", [@]
    else
      @eventType = null

    if @eventType then @target.trigger @eventType, [@]
    @target.trigger "touch", [@]
    return


class swipeEvents

  constructor: (elements, options) ->
    @options = $.extend defaults, options
    elements.bind "touchstart", (evt) => @touchStart evt
    elements.bind "touchmove", (evt) => @touchMove evt
    elements.bind "touchcancel", (evt) => @touchCancel evt
    elements.bind "touchend", (evt) => @touchEnd evt

  touchStart: (evt) -> @eachTouch evt, (touch) =>
    allTouches[touch.identifier] = new touchStatus evt.target, touch, @options
    return

  touchMove: (evt) -> @eachTouch evt, (touch) =>
    allTouches[touch.identifier]?.move touch
    return

  touchCancel: (evt) -> @eachTouch evt, (touch) =>
    @purge touch, true
    return

  touchEnd: (evt) -> @eachTouch evt, (touch) =>
    @purge touch
    return

  purge: (touch, cancelled) ->
    if not cancelled then do allTouches[touch.identifier]?.process
    delete allTouches[touch.identifier]
    return

  eachTouch: (evt, callback) ->
    evt = evt.originalEvent
    num = evt.changedTouches.length
    callback evt.changedTouches[i] for i in [0...num]
    return evt.type not in @options.preventDefault


# Adds custom events:
# -------------------
#
# - touch      # all events
# - swipe      # only swipe* events
# - swipeleft
# - swiperight
# - swipeup
# - swipedown
# - tap
# - doubletap

$.fn.addSwipeEvents = (options, callback) ->
  if not callback and $.isFunction options
    callback = options
    options = null
  if callback then @.bind "touch", callback
  new swipeEvents @, options
  return @
