/*! nanoScrollerJS - v0.7.2
* http://jamesflorentino.github.com/nanoScrollerJS/
* Copyright (c) 2013 James Florentino; Licensed MIT */


(function($, window, document) {
  "use strict";

  var BROWSER_IS_IE7, BROWSER_SCROLLBAR_HEIGHT, BROWSER_SCROLLBAR_WIDTH, DOMSCROLL, DOWN, DRAG, KEYDOWN, KEYUP, LEFT, MOUSEDOWN, MOUSEMOVE, MOUSEUP, MOUSEWHEEL, NanoScroll, PANEDOWN, PANERIGHT, RESIZE, RIGHT, SCROLL, SCROLLBAR, TOUCHMOVE, UP, WHEEL, defaults, getBrowserScrollbarSizes;
  defaults = {
    /**
      a classname for the pane element.
      @property paneClass
      @type String
      @default 'pane'
    */

    paneClass: 'pane',
    /**
      a classname for the pane-y element.
      @property paneClassY
      @type String
      @default 'pane-y'
    */

    paneClassY: 'pane-y',
    /**
      a classname for the pane-x element.
      @property paneClassX
      @type String
      @default 'pane-x'
    */

    paneClassX: 'pane-x',
    /**
      a classname for the slider element.
      @property sliderClass
      @type String
      @default 'slider'
    */

    sliderClass: 'slider',
    /**
      a classname for the slider-y element.
      @property sliderClassY
      @type String
      @default 'slider-y'
    */

    sliderClassY: 'slider-y',
    /**
      a classname for the slider-x element.
      @property sliderClassX
      @type String
      @default 'slider-x'
    */

    sliderClassX: 'slider-x',
    /**
      a classname for the content element.
      @property contentClass
      @type String
      @default 'content'
    */

    contentClass: 'content',
    /**
      a setting to enable native scrolling in iOS devices.
      @property iOSNativeScrolling
      @type Boolean
      @default false
    */

    iOSNativeScrolling: false,
    /**
      a setting to prevent the rest of the page being
      scrolled when user scrolls the `.content` element.
      @property preventPageScrolling
      @type Boolean
      @default false
    */

    preventPageScrolling: false,
    /**
      a setting to disable binding to the resize event.
      @property disableResize
      @type Boolean
      @default false
    */

    disableResize: false,
    /**
      a setting to make the scrollbar always visible.
      @property alwaysVisible
      @type Boolean
      @default false
    */

    alwaysVisible: false,
    /**
      a default timeout for the `flash()` method.
      @property flashDelay
      @type Number
      @default 1500
    */

    flashDelay: 1500,
    /**
      a minimum height for the `.slider` element.
      @property sliderMinHeight
      @type Number
      @default 20
    */

    sliderMinHeight: 20,
    /**
      a maximum height for the `.slider` element.
      @property sliderMaxHeight
      @type Number
      @default null
    */

    sliderMaxHeight: null
  };
  /**
    @property SCROLLBAR
    @type String
    @static
    @final
    @private
  */

  SCROLLBAR = 'scrollbar';
  /**
    @property SCROLL
    @type String
    @static
    @final
    @private
  */

  SCROLL = 'scroll';
  /**
    @property MOUSEDOWN
    @type String
    @final
    @private
  */

  MOUSEDOWN = 'mousedown';
  /**
    @property MOUSEMOVE
    @type String
    @static
    @final
    @private
  */

  MOUSEMOVE = 'mousemove';
  /**
    @property MOUSEWHEEL
    @type String
    @final
    @private
  */

  MOUSEWHEEL = 'mousewheel';
  /**
    @property MOUSEUP
    @type String
    @static
    @final
    @private
  */

  MOUSEUP = 'mouseup';
  /**
    @property RESIZE
    @type String
    @final
    @private
  */

  RESIZE = 'resize';
  /**
    @property DRAG
    @type String
    @static
    @final
    @private
  */

  DRAG = 'drag';
  /**
    @property UP
    @type String
    @static
    @final
    @private
  */

  UP = 'up';
  /**
    @property PANEDOWN
    @type String
    @static
    @final
    @private
  */

  PANEDOWN = 'panedown';
  /**
    @property LEFT
    @type String
    @static
    @final
    @private
  */

  LEFT = 'left';
  /**
    @property PANERIGHT
    @type String
    @static
    @final
    @private
  */

  PANERIGHT = 'paneright';
  /**
    @property DOMSCROLL
    @type String
    @static
    @final
    @private
  */

  DOMSCROLL = 'DOMMouseScroll';
  /**
    @property DOWN
    @type String
    @static
    @final
    @private
  */

  DOWN = 'down';
  /**
    @property RIGHT
    @type String
    @static
    @final
    @private
  */

  RIGHT = 'right';
  /**
    @property WHEEL
    @type String
    @static
    @final
    @private
  */

  WHEEL = 'wheel';
  /**
    @property KEYDOWN
    @type String
    @static
    @final
    @private
  */

  KEYDOWN = 'keydown';
  /**
    @property KEYUP
    @type String
    @static
    @final
    @private
  */

  KEYUP = 'keyup';
  /**
    @property TOUCHMOVE
    @type String
    @static
    @final
    @private
  */

  TOUCHMOVE = 'touchmove';
  /**
    @property BROWSER_IS_IE7
    @type Boolean
    @static
    @final
    @private
  */

  BROWSER_IS_IE7 = window.navigator.appName === 'Microsoft Internet Explorer' && /msie 7./i.test(window.navigator.appVersion) && window.ActiveXObject;
  /**
    @property BROWSER_SCROLLBAR_WIDTH
    @type Number
    @static
    @default null
    @private
  */

  BROWSER_SCROLLBAR_WIDTH = null;
  /**
    @property BROWSER_SCROLLBAR_HEIGHT
    @type Number
    @static
    @default null
    @private
  */

  BROWSER_SCROLLBAR_HEIGHT = null;
  /**
    Returns browser's native scrollbar width
    @method getBrowserScrollbarSizes
    @return {Number} the scrollbar width in pixels
    @static
    @private
  */

  getBrowserScrollbarSizes = function() {
    var outer, outerStyle, scrollbarHeight, scrollbarWidth;
    outer = document.createElement('div');
    outerStyle = outer.style;
    outerStyle.position = 'absolute';
    outerStyle.width = '100px';
    outerStyle.height = '100px';
    outerStyle.overflow = SCROLL;
    outerStyle.top = '-9999px';
    document.body.appendChild(outer);
    scrollbarWidth = outer.offsetWidth - outer.clientWidth;
    scrollbarHeight = outer.offsetHeight - outer.clientHeight;
    document.body.removeChild(outer);
    return [scrollbarWidth, scrollbarHeight];
  };
  /**
    @class NanoScroll
    @param element {HTMLElement|Node} the main element
    @param options {Object} nanoScroller's options
    @constructor
  */

  NanoScroll = (function() {

    function NanoScroll(el, options) {
      var _ref;
      this.el = el;
      this.options = options;
      if (!BROWSER_SCROLLBAR_WIDTH || !BROWSER_SCROLLBAR_HEIGHT) {
        _ref = getBrowserScrollbarSizes(), BROWSER_SCROLLBAR_WIDTH = _ref[0], BROWSER_SCROLLBAR_HEIGHT = _ref[1];
      }
      this.$el = $(this.el);
      this.doc = $(document);
      this.win = $(window);
      this.$content = this.$el.children("." + options.contentClass);
      this.$content.attr('tabindex', 0);
      this.content = this.$content[0];
      if (this.options.iOSNativeScrolling && (this.el.style.WebkitOverflowScrolling != null)) {
        this.nativeScrolling();
      } else {
        this.generate();
      }
      this.createEvents();
      this.addEvents();
      this.reset();
    }

    /**
      Prevents the rest of the page being scrolled
      when user scrolls the `.content` element.
      @method preventVerticalScrolling
      @param event {Event}
      @param direction {String} Scroll direction (up or down)
      @private
    */


    NanoScroll.prototype.preventVerticalScrolling = function(e, direction) {
      if (!this.isActiveY) {
        return;
      }
      return;
      if (e.type === DOMSCROLL) {
        if (direction === DOWN && e.originalEvent.detail > 0 || direction === UP && e.originalEvent.detail < 0) {
          e.preventDefault();
        }
      } else if (e.type === MOUSEWHEEL) {
        if (!e.originalEvent || !e.originalEvent.wheelDelta) {
          return;
        }
        if (direction === DOWN && e.originalEvent.wheelDelta < 0 || direction === UP && e.originalEvent.wheelDelta > 0) {
          e.preventDefault();
        }
      }
    };

    /**
      Prevents the rest of the page being scrolled
      when user scrolls the `.content` element.
      @method preventHorizontalScrolling
      @param event {Event}
      @param direction {String} Scroll direction (left or right)
      @private
    */


    NanoScroll.prototype.preventHorizontalScrolling = function(e, direction) {
      if (!this.isActiveX) {
        return;
      }
      return;
      if (e.type === DOMSCROLL) {
        if (direction === RIGHT && e.originalEvent.detail > 0 || direction === LEFT && e.originalEvent.detail < 0) {
          e.preventDefault();
        }
      } else if (e.type === MOUSEWHEEL) {
        if (!e.originalEvent || !e.originalEvent.wheelDelta) {
          return;
        }
        if (direction === RIGHT && e.originalEvent.wheelDelta < 0 || direction === LEFT && e.originalEvent.wheelDelta > 0) {
          e.preventDefault();
        }
      }
    };

    /**
      Enable iOS native scrolling
    */


    NanoScroll.prototype.nativeScrolling = function() {
      this.$content.css({
        WebkitOverflowScrolling: 'touch'
      });
      this.iOSNativeScrolling = true;
      this.isActiveX = true;
      this.isActiveY = true;
    };

    /**
      Updates those nanoScroller properties that
      are related to current scrollbar position.
      @method updateVerticalScrollValues
      @private
    */


    NanoScroll.prototype.updateVerticalScrollValues = function() {
      var content;
      content = this.content;
      this.maxScrollTop = content.scrollHeight - content.clientHeight;
      this.contentScrollTop = content.scrollTop;
      if (!this.iOSNativeScrolling) {
        this.maxSliderTop = this.yPaneHeight - this.ySliderHeight;
        this.ySliderTop = this.contentScrollTop * this.maxSliderTop / this.maxScrollTop;
      }
    };

    /**
      Updates those nanoScroller properties that
      are related to current scrollbar position.
      @method updateVerticalScrollValues
      @private
    */


    NanoScroll.prototype.updateHorizontalScrollValues = function() {
      var content;
      content = this.content;
      this.maxScrollLeft = content.scrollWidth - content.clientWidth;
      this.contentScrollLeft = content.scrollLeft;
      if (!this.iOSNativeScrolling) {
        this.maxSliderLeft = this.xPaneWidth - this.xSliderWidth;
        this.xSliderLeft = this.contentScrollLeft * this.maxSliderLeft / this.maxScrollLeft;
      }
    };

    /**
      Creates event related methods
      @method createEvents
      @private
    */


    NanoScroll.prototype.createEvents = function() {
      var _this = this;
      this.yEvents = {
        down: function(e) {
          _this.isYBeingDragged = true;
          _this.offsetY = e.pageY - _this.ySlider.offset().top;
          _this.yPane.addClass('active');
          _this.doc.bind(MOUSEMOVE, _this.yEvents[DRAG]).bind(MOUSEUP, _this.yEvents[UP]);
          return false;
        },
        drag: function(e) {
          _this.ySliderY = e.pageY - _this.$el.offset().top - _this.offsetY;
          _this.scrollY();
          _this.updateVerticalScrollValues();
          if (_this.contentScrollTop >= _this.maxScrollTop) {
            _this.$el.trigger('scrollend');
          } else if (_this.contentScrollTop === 0) {
            _this.$el.trigger('scrolltop');
          }
          return false;
        },
        up: function(e) {
          _this.isYBeingDragged = false;
          _this.yPane.removeClass('active');
          _this.doc.unbind(MOUSEMOVE, _this.yEvents[DRAG]).unbind(MOUSEUP, _this.yEvents[UP]);
          return false;
        },
        resize: function(e) {
          _this.reset();
        },
        panedown: function(e) {
          _this.ySliderY = (e.offsetY || e.originalEvent.layerY) - (_this.ySliderHeight * 0.5);
          _this.scrollY();
          _this.yEvents.down(e);
          return false;
        },
        scroll: function(e) {
          if (_this.isYBeingDragged) {
            return;
          }
          _this.updateVerticalScrollValues();
          if (!_this.iOSNativeScrolling) {
            _this.ySliderY = _this.ySliderTop;
            _this.ySlider.css({
              top: _this.ySliderTop
            });
          }
          if (e == null) {
            return;
          }
          if (_this.contentScrollTop >= _this.maxScrollTop) {
            if (_this.options.preventPageScrolling) {
              _this.preventVerticalScrolling(e, DOWN);
            }
            _this.$el.trigger('scrollend');
          } else if (_this.contentScrollTop === 0) {
            if (_this.options.preventPageScrolling) {
              _this.preventVerticalScrolling(e, UP);
            }
            _this.$el.trigger('scrolltop');
          }
        },
        wheel: function(e) {
          if (e == null) {
            return;
          }
          _this.ySliderY += -e.wheelDeltaY || -e.delta;
          _this.scrollY();
          return false;
        }
      };
      this.xEvents = {
        down: function(e) {
          _this.isXBeingDragged = true;
          _this.offsetX = e.pageX - _this.xSlider.offset().left;
          _this.xPane.addClass('active');
          _this.doc.bind(MOUSEMOVE, _this.xEvents[DRAG]).bind(MOUSEUP, _this.xEvents[UP]);
          return false;
        },
        drag: function(e) {
          _this.xSliderX = e.pageX - _this.$el.offset().left - _this.offsetX;
          _this.scrollX();
          _this.updateHorizontalScrollValues();
          if (_this.contentScrollLeft >= _this.maxScrollLeft) {
            _this.$el.trigger('scrollend');
          } else if (_this.contentScrollLeft === 0) {
            _this.$el.trigger('scrollleft');
          }
          return false;
        },
        up: function(e) {
          _this.isXBeingDragged = false;
          _this.xPane.removeClass('active');
          _this.doc.unbind(MOUSEMOVE, _this.xEvents[DRAG]).unbind(MOUSEUP, _this.xEvents[UP]);
          return false;
        },
        resize: function(e) {
          _this.reset();
        },
        panedown: function(e) {
          _this.xSliderX = (e.offsetX || e.originalEvent.layerX) - (_this.xSliderWidth * 0.5);
          _this.scrollX();
          _this.xEvents.down(e);
          return false;
        },
        scroll: function(e) {
          if (_this.isXBeingDragged) {
            return;
          }
          _this.updateHorizontalScrollValues();
          if (!_this.iOSNativeScrolling) {
            _this.xSliderX = _this.xSliderLeft;
            _this.xSlider.css({
              left: _this.xSliderLeft
            });
          }
          if (e == null) {
            return;
          }
          if (_this.contentScrollLeft >= _this.maxScrollLeft) {
            if (_this.options.preventPageScrolling) {
              _this.preventHorizontalScrolling(e, RIGHT);
            }
            _this.$el.trigger('scrollend');
          } else if (_this.contentScrollLeft === 0) {
            if (_this.options.preventPageScrolling) {
              _this.preventHorizontalScrolling(e, LEFT);
            }
            _this.$el.trigger('scrollleft');
          }
        },
        wheel: function(e) {
          if (e == null) {
            return;
          }
          _this.xSliderX += -e.wheelDeltaX || -e.delta;
          _this.scrollX();
          return false;
        }
      };
    };

    /**
      Adds event listeners with jQuery.
      @method addEvents
      @private
    */


    NanoScroll.prototype.addEvents = function() {
      var xEvents, yEvents;
      this.removeEvents();
      yEvents = this.yEvents;
      xEvents = this.xEvents;
      if (!this.options.disableResize) {
        this.win.bind(RESIZE, yEvents[RESIZE].bind(RESIZE, xEvents[RESIZE]));
      }
      if (!this.iOSNativeScrolling) {
        this.ySlider.bind(MOUSEDOWN, yEvents[DOWN]);
        this.xSlider.bind(MOUSEDOWN, xEvents[DOWN]);
        this.yPane.bind(MOUSEDOWN, yEvents[PANEDOWN]).bind("" + MOUSEWHEEL + " " + DOMSCROLL, yEvents[WHEEL]);
        this.xPane.bind(MOUSEDOWN, xEvents[PANEDOWN]).bind("" + MOUSEWHEEL + " " + DOMSCROLL, xEvents[WHEEL]);
      }
      this.$content.bind("" + SCROLL + " " + MOUSEWHEEL + " " + DOMSCROLL + " " + TOUCHMOVE, yEvents[SCROLL]).bind("" + SCROLL + " " + MOUSEWHEEL + " " + DOMSCROLL + " " + TOUCHMOVE, xEvents[SCROLL]);
    };

    /**
      Removes event listeners with jQuery.
      @method removeEvents
      @private
    */


    NanoScroll.prototype.removeEvents = function() {
      var xEvents, yEvents;
      yEvents = this.yEvents;
      xEvents = this.xEvents;
      this.win.unbind(RESIZE, yEvents[RESIZE]).unbind(RESIZE, xEvents[RESIZE]);
      if (!this.iOSNativeScrolling) {
        this.ySlider.unbind();
        this.xSlider.unbind();
        this.yPane.unbind();
        this.xPane.unbind();
      }
      this.$content.unbind("" + SCROLL + " " + MOUSEWHEEL + " " + DOMSCROLL + " " + TOUCHMOVE, yEvents[SCROLL]).unbind("" + SCROLL + " " + MOUSEWHEEL + " " + DOMSCROLL + " " + TOUCHMOVE, xEvents[SCROLL]);
    };

    /**
      Generates nanoScroller's scrollbar and elements for it.
      @method generate
      @chainable
      @private
    */


    NanoScroll.prototype.generate = function() {
      var contentClass, cssRuleX, cssRuleY, options, paneClass, paneClassX, paneClassY, sliderClass, sliderClassX, sliderClassY;
      options = this.options;
      paneClass = options.paneClass, paneClassY = options.paneClassY, paneClassX = options.paneClassX, sliderClass = options.sliderClass, sliderClassY = options.sliderClassY, sliderClassX = options.sliderClassX, contentClass = options.contentClass;
      if (!this.$el.find("" + paneClassY).length && !this.$el.find("" + sliderClassY).length) {
        this.$el.append("<div class=\"" + paneClass + " " + paneClassY + "\"><div class=\"" + sliderClass + " " + sliderClassY + "\" /></div>");
      }
      if (!this.$el.find("" + paneClassX).length && !this.$el.find("" + sliderClassX).length) {
        this.$el.append("<div class=\"" + paneClass + " " + paneClassX + "\"><div class=\"" + sliderClass + " " + sliderClassX + "\" /></div>");
      }
      this.yPane = this.$el.children("." + paneClassY);
      this.xPane = this.$el.children("." + paneClassX);
      this.ySlider = this.yPane.find("." + sliderClassY);
      this.xSlider = this.xPane.find("." + sliderClassX);
      if (BROWSER_SCROLLBAR_WIDTH) {
        cssRuleY = this.$el.css('direction') === 'rtl' ? {
          left: -BROWSER_SCROLLBAR_WIDTH
        } : {
          right: -BROWSER_SCROLLBAR_WIDTH
        };
        this.$el.addClass('has-scrollbar');
        this.$content.css(cssRuleY);
      }
      if (BROWSER_SCROLLBAR_HEIGHT) {
        cssRuleX = {
          bottom: -BROWSER_SCROLLBAR_HEIGHT
        };
        this.$el.addClass('has-scrollbar');
        this.$content.css(cssRuleX);
      }
      return this;
    };

    /**
      @method restore
      @private
    */


    NanoScroll.prototype.restore = function() {
      this.stopped = false;
      this.yPane.show();
      this.xPane.show();
      this.addEvents();
    };

    /**
      Resets nanoScroller's scrollbar.
      @method reset
      @chainable
      @example
          $(".nano").nanoScroller();
    */


    NanoScroll.prototype.reset = function() {
      var content, contentHeight, contentStyle, contentStyleOverflowX, contentStyleOverflowY, contentWidth, paneBottom, paneHeight, paneLeft, paneOuterHeight, paneOuterWidth, paneRight, paneTop, paneWidth, sliderHeight, sliderWidth;
      if (this.iOSNativeScrolling) {
        this.contentHeight = this.content.scrollHeight;
        this.contentWidth = this.content.scrollWidth;
        return;
      }
      this.$el.removeClass('has-scrollbar-x');
      this.$el.removeClass('has-scrollbar-y');
      if (!this.$el.find("." + this.options.paneClassY).length && !this.$el.find("." + this.options.paneClassX).length) {
        this.generate().stop();
      }
      if (this.stopped) {
        this.restore();
      }
      content = this.content;
      contentStyle = content.style;
      contentStyleOverflowY = contentStyle.overflowY;
      contentStyleOverflowX = contentStyle.overflowX;
      if (BROWSER_IS_IE7) {
        this.$content.css({
          height: this.$content.height(),
          width: this.$content.height()
        });
      }
      contentHeight = content.scrollHeight + BROWSER_SCROLLBAR_WIDTH;
      contentWidth = content.scrollWidth + BROWSER_SCROLLBAR_HEIGHT;
      if (content.scrollWidth > this.xPane.outerWidth(true)) {
        this.$el.addClass('has-scrollbar-x');
      }
      if (content.scrollHeight > this.yPane.outerHeight(true)) {
        this.$el.addClass('has-scrollbar-y');
      }
      paneHeight = this.yPane.outerHeight();
      paneTop = parseInt(this.yPane.css('top'), 10);
      paneBottom = parseInt(this.yPane.css('bottom'), 10);
      paneOuterHeight = paneHeight + paneTop + paneBottom;
      paneWidth = this.xPane.outerWidth();
      paneLeft = parseInt(this.xPane.css('left'), 10);
      paneRight = parseInt(this.xPane.css('right'), 10);
      paneOuterWidth = paneWidth + paneLeft + paneRight;
      sliderHeight = Math.round(paneOuterHeight / contentHeight * paneOuterHeight);
      if (sliderHeight < this.options.sliderMinHeight) {
        sliderHeight = this.options.sliderMinHeight;
      } else if ((this.options.sliderMaxHeight != null) && sliderHeight > this.options.sliderMaxHeight) {
        sliderHeight = this.options.sliderMaxHeight;
      }
      if (contentStyleOverflowY === SCROLL && contentStyle.overflowX !== SCROLL) {
        sliderHeight += BROWSER_SCROLLBAR_WIDTH;
      }
      sliderWidth = Math.round(paneOuterWidth / contentWidth * paneOuterWidth);
      if (sliderWidth < this.options.sliderMinWidth) {
        sliderWidth = this.options.sliderMinWidth;
      } else if ((this.options.sliderMaxWidth != null) && sliderWidth > this.options.sliderMaxWidth) {
        sliderWidth = this.options.sliderMaxWidth;
      }
      if (contentStyleOverflowX === SCROLL && contentStyle.overflowY !== SCROLL) {
        sliderWidth += BROWSER_SCROLLBAR_HEIGHT;
      }
      this.maxSliderTop = paneOuterHeight - sliderHeight;
      this.maxSliderLeft = paneOuterWidth - sliderWidth;
      this.contentHeight = contentHeight;
      this.contentWidth = contentWidth;
      this.yPaneHeight = paneHeight;
      this.xPaneWidth = paneWidth;
      this.yPaneOuterHeight = paneOuterHeight;
      this.xPaneOuterWidth = paneOuterWidth;
      this.ySliderHeight = sliderHeight;
      this.xSliderWidth = sliderWidth;
      this.ySlider.height(sliderHeight);
      this.xSlider.width(sliderWidth);
      this.yEvents.scroll();
      this.xEvents.scroll();
      this.yPane.show();
      this.isActiveY = true;
      if ((content.scrollHeight === content.clientHeight) || (this.yPane.outerHeight(true) >= content.scrollHeight && contentStyleOverflowY !== SCROLL)) {
        this.yPane.hide();
        this.$el.removeClass('has-scrollbar-y');
        this.isActiveY = false;
      } else if (this.el.clientHeight === content.scrollHeight && contentStyleOverflowY === SCROLL) {
        this.ySlider.hide();
      } else {
        this.ySlider.show();
      }
      this.xPane.show();
      this.isActiveX = true;
      if ((content.scrollWidth === content.clientWidth) || (this.xPane.outerWidth(true) >= content.scrollWidth && contentStyleOverflowX !== SCROLL)) {
        this.xPane.hide();
        this.$el.removeClass('has-scrollbar-x');
        this.isActiveX = false;
      } else if (this.el.clientWidth === content.scrollWidth && contentStyleOverflowX === SCROLL) {
        this.xSlider.hide();
      } else {
        this.xSlider.show();
      }
      this.yPane.css({
        opacity: (this.options.alwaysVisible ? 1 : ''),
        visibility: (this.options.alwaysVisible ? 'visible' : '')
      });
      this.xPane.css({
        opacity: (this.options.alwaysVisible ? 1 : ''),
        visibility: (this.options.alwaysVisible ? 'visible' : '')
      });
      return this;
    };

    /**
      @method scroll
      @private
      @example
          $(".nano").nanoScroller({ scroll: 'top' });
    */


    NanoScroll.prototype.scroll = function() {
      return this.scrollY();
    };

    /**
      @method scrollY
      @private
      @example
          $(".nano").nanoScroller({ scrollY: 'top' });
    */


    NanoScroll.prototype.scrollY = function() {
      if (!this.isActiveY) {
        return;
      }
      this.ySliderY = Math.max(0, this.ySliderY);
      this.ySliderY = Math.min(this.maxSliderTop, this.ySliderY);
      this.$content.scrollTop((this.yPaneHeight - this.contentHeight + BROWSER_SCROLLBAR_WIDTH) * this.ySliderY / this.maxSliderTop * -1);
      if (!this.iOSNativeScrolling) {
        this.ySlider.css({
          top: this.ySliderY
        });
      }
      return this;
    };

    /**
      @method scrollX
      @private
      @example
          $(".nano").nanoScroller({ scrollX: 'top' });
    */


    NanoScroll.prototype.scrollX = function() {
      if (!this.isActiveX) {
        return;
      }
      this.xSliderX = Math.max(0, this.xSliderX);
      this.xSliderX = Math.min(this.maxSliderLeft, this.xSliderX);
      this.$content.scrollLeft((this.xPaneWidth - this.contentWidth + BROWSER_SCROLLBAR_HEIGHT) * this.xSliderX / this.maxSliderLeft * -1);
      if (!this.iOSNativeScrolling) {
        this.xSlider.css({
          left: this.xSliderX
        });
      }
      return this;
    };

    /**
      Scroll at the bottom with an offset value
      @method scrollBottom
      @param offsetY {Number}
      @chainable
      @example
          $(".nano").nanoScroller({ scrollBottom: value });
    */


    NanoScroll.prototype.scrollBottom = function(offsetY) {
      if (!this.isActiveY) {
        return;
      }
      this.reset();
      this.$content.scrollTop(this.contentHeight - this.$content.height() - offsetY).trigger(MOUSEWHEEL);
      return this;
    };

    /**
      Scroll at the right with an offset value
      @method scrollRight
      @param offsetX {Number}
      @chainable
      @example
          $(".nano").nanoScroller({ scrollRight: value });
    */


    NanoScroll.prototype.scrollRight = function(offsetX) {
      if (!this.isActiveX) {
        return;
      }
      this.reset();
      this.$content.scrollLeft(this.contentWidth - this.$content.width() - offsetX).trigger(MOUSEWHEEL);
      return this;
    };

    /**
      Scroll at the top with an offset value
      @method scrollTop
      @param offsetY {Number}
      @chainable
      @example
          $(".nano").nanoScroller({ scrollTop: value });
    */


    NanoScroll.prototype.scrollTop = function(offsetY) {
      if (!this.isActiveY) {
        return;
      }
      this.reset();
      this.$content.scrollTop(+offsetY).trigger(MOUSEWHEEL);
      return this;
    };

    /**
      Scroll at the left with an offset value
      @method scrollLeft
      @param offsetX {Number}
      @chainable
      @example
          $(".nano").nanoScroller({ scrollLeft: value });
    */


    NanoScroll.prototype.scrollLeft = function(offsetX) {
      if (!this.isActiveX) {
        return;
      }
      this.reset();
      this.$content.scrollLeft(+offsetX).trigger(MOUSEWHEEL);
      return this;
    };

    /**
      Scroll to an element
      @method scrollTo
      @param node {Node} A node to scroll to.
      @chainable
      @example
          $(".nano").nanoScroller({ scrollTo: $('#a_node') });
    */


    NanoScroll.prototype.scrollTo = function(node) {
      var n;
      if (!(this.isActiveY || this.isActiveX)) {
        return;
      }
      this.reset();
      n = $(node).get(0);
      if (this.isActiveY) {
        this.scrollTop(n.offsetTop);
      }
      if (this.isActiveX) {
        this.scrollLeft(n.offsetLeft);
      }
      return this;
    };

    /**
      To stop the operation.
      This option will tell the plugin to disable all event bindings and hide the gadget scrollbar from the UI.
      @method stop
      @chainable
      @example
          $(".nano").nanoScroller({ stop: true });
    */


    NanoScroll.prototype.stop = function() {
      this.stopped = true;
      this.removeEvents();
      this.yPane.hide();
      this.xPane.hide();
      return this;
    };

    /**
      To flash the scrollbar gadget for an amount of time defined in plugin settings (defaults to 1,5s).
      Useful if you want to show the user (e.g. on pageload) that there is more content waiting for him.
      @method flash
      @chainable
      @example
          $(".nano").nanoScroller({ flash: true });
    */


    NanoScroll.prototype.flash = function() {
      var _this = this;
      if (!(this.isActiveY || this.isActiveX)) {
        return;
      }
      this.reset();
      if (this.isActiveY) {
        this.yPane.addClass('flashed');
      }
      if (this.isActiveX) {
        this.xPane.addClass('flashed');
      }
      setTimeout(function() {
        if (_this.isActiveY) {
          _this.yPane.removeClass('flashed');
        }
        if (_this.isActiveX) {
          _this.xPane.removeClass('flashed');
        }
      }, this.options.flashDelay);
      return this;
    };

    return NanoScroll;

  })();
  $.fn.nanoScroller = function(settings) {
    return this.each(function() {
      var options, scrollbar;
      if (!(scrollbar = this.nanoscroller)) {
        if (settings.paneClass) {
          if (!settings.paneClassX) {
            settings.paneClassX = "" + settings.paneClass + "-x";
          }
          if (!settings.paneClassY) {
            settings.paneClassY = "" + settings.paneClass + "-y";
          }
        }
        if (settings.sliderClass) {
          if (!settings.sliderClassX) {
            settings.sliderClassX = "" + settings.sliderClass + "-x";
          }
          if (!settings.sliderClassY) {
            settings.sliderClassY = "" + settings.sliderClass + "-y";
          }
        }
        options = $.extend({}, defaults, settings);
        this.nanoscroller = scrollbar = new NanoScroll(this, options);
      }
      if (settings && typeof settings === "object") {
        $.extend(scrollbar.options, settings);
        if (settings.scrollBottom) {
          return scrollbar.scrollBottom(settings.scrollBottom);
        }
        if (settings.scrollTop) {
          return scrollbar.scrollTop(settings.scrollTop);
        }
        if (settings.scrollRight) {
          return scrollbar.scrollRight(settings.scrollRight);
        }
        if (settings.scrollLeft) {
          return scrollbar.scrollLeft(settings.scrollLeft);
        }
        if (settings.scrollTo) {
          return scrollbar.scrollTo(settings.scrollTo);
        }
        if (settings.scroll === 'bottom') {
          return scrollbar.scrollBottom(0);
        }
        if (settings.scroll === 'top') {
          return scrollbar.scrollTop(0);
        }
        if (settings.scroll === 'right') {
          return scrollbar.scrollRight(0);
        }
        if (settings.scroll === 'left') {
          return scrollbar.scrollLeft(0);
        }
        if (settings.scroll && settings.scroll instanceof $) {
          return scrollbar.scrollTo(settings.scroll);
        }
        if (settings.stop) {
          return scrollbar.stop();
        }
        if (settings.flash) {
          return scrollbar.flash();
        }
      }
      return scrollbar.reset();
    });
  };
})(jQuery, window, document);
