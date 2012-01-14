(function() {
  var $, allTouches, defaults, latestTap, swipeEvents, touchStatus;
  var __hasProp = Object.prototype.hasOwnProperty, __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (__hasProp.call(this, i) && this[i] === item) return i; } return -1; };

  $ = jQuery;

  defaults = {
    swipeTolerance: 40,
    preventDefault: []
  };

  allTouches = {};

  latestTap = null;

  touchStatus = (function() {

    function touchStatus(target, touch, options) {
      this.touch = touch;
      this.options = options;
      this.target = $(target);
      this.startX = this.currentX = this.touch.screenX;
      this.startY = this.currentY = this.touch.screenY;
    }

    touchStatus.prototype.move = function(touch) {
      this.currentX = touch.screenX;
      this.currentY = touch.screenY;
    };

    touchStatus.prototype.process = function() {
      var absOffsetX, absOffsetY, offsetX, offsetY;
      offsetX = this.currentX - this.startX;
      offsetY = this.currentY - this.startY;
      absOffsetX = Math.abs(offsetX);
      absOffsetY = Math.abs(offsetY);
      if (offsetX === 0 && offsetY === 0) {
        if (latestTap && (new Date() - latestTap) < 400) {
          this.eventType = "doubletap";
          latestTap = null;
        } else {
          this.eventType = "tap";
          latestTap = new Date();
        }
      } else if (absOffsetY > this.options.swipeTolerance && absOffsetY > absOffsetX) {
        this.eventType = offsetY > 0 && "swipedown" || "swipeup";
        this.target.trigger("swipe", [this]);
      } else if (absOffsetX > this.options.swipeTolerance) {
        this.eventType = offsetX > 0 && "swiperight" || "swipeleft";
        this.target.trigger("swipe", [this]);
      } else {
        this.eventType = null;
      }
      if (this.eventType) this.target.trigger(this.eventType, [this]);
      this.target.trigger("touch", [this]);
    };

    return touchStatus;

  })();

  swipeEvents = (function() {

    function swipeEvents(elements, options) {
      var _this = this;
      this.options = $.extend(defaults, options);
      elements.bind("touchstart", function(evt) {
        return _this.touchStart(evt);
      });
      elements.bind("touchmove", function(evt) {
        return _this.touchMove(evt);
      });
      elements.bind("touchcancel", function(evt) {
        return _this.touchCancel(evt);
      });
      elements.bind("touchend", function(evt) {
        return _this.touchEnd(evt);
      });
    }

    swipeEvents.prototype.touchStart = function(evt) {
      var _this = this;
      return this.eachTouch(evt, function(touch) {
        allTouches[touch.identifier] = new touchStatus(evt.target, touch, _this.options);
      });
    };

    swipeEvents.prototype.touchMove = function(evt) {
      var _this = this;
      return this.eachTouch(evt, function(touch) {
        var _ref;
        if ((_ref = allTouches[touch.identifier]) != null) _ref.move(touch);
      });
    };

    swipeEvents.prototype.touchCancel = function(evt) {
      var _this = this;
      return this.eachTouch(evt, function(touch) {
        _this.purge(touch, true);
      });
    };

    swipeEvents.prototype.touchEnd = function(evt) {
      var _this = this;
      return this.eachTouch(evt, function(touch) {
        _this.purge(touch);
      });
    };

    swipeEvents.prototype.purge = function(touch, cancelled) {
      var _ref;
      if (!cancelled) {
        if ((_ref = allTouches[touch.identifier]) != null) _ref.process();
      }
      delete allTouches[touch.identifier];
    };

    swipeEvents.prototype.eachTouch = function(evt, callback) {
      var i, num, _ref;
      evt = evt.originalEvent;
      num = evt.changedTouches.length;
      for (i = 0; 0 <= num ? i < num : i > num; 0 <= num ? i++ : i--) {
        callback(evt.changedTouches[i]);
      }
      return _ref = evt.type, __indexOf.call(this.options.preventDefault, _ref) < 0;
    };

    return swipeEvents;

  })();

  $.fn.addSwipeEvents = function(options, callback) {
    if (!callback && $.isFunction(options)) {
      callback = options;
      options = null;
    }
    if (callback) this.bind("touch", callback);
    new swipeEvents(this, options);
    return this;
  };

}).call(this);
