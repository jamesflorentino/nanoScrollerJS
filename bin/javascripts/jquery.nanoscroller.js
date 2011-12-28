
(function($, window, document) {
  var DOMSCROLL, DOWN, DRAG, MOUSEDOWN, MOUSEMOVE, MOUSEUP, MOUSEWHEEL, NanoScroll, PANEDOWN, RESIZE, SCROLL, SCROLLBAR, UP, WHEEL, getScrollbarWidth;
  SCROLLBAR = 'scrollbar';
  SCROLL = 'scroll';
  MOUSEDOWN = 'mousedown';
  MOUSEMOVE = 'mousemove';
  MOUSEWHEEL = 'mousewheel';
  MOUSEUP = 'mouseup';
  RESIZE = 'resize';
  DRAG = 'drag';
  UP = 'up';
  PANEDOWN = 'panedown';
  DOMSCROLL = 'DOMMouseScroll';
  DOWN = 'down';
  WHEEL = 'wheel';
  getScrollbarWidth = function() {
    var noscrollWidth, outer, yesscrollWidth;
    outer = document.createElement('div');
    outer.style.position = 'absolute';
    outer.style.width = '100px';
    outer.style.height = '100px';
    outer.style.overflow = 'scroll';
    document.body.appendChild(outer);
    noscrollWidth = outer.offsetWidth;
    yesscrollWidth = outer.scrollWidth;
    document.body.removeChild(outer);
    return noscrollWidth - yesscrollWidth;
  };
  NanoScroll = (function() {

    function NanoScroll(el) {
      this.el = el;
      this.generate();
      this.createEvents();
      this.addEvents();
      this.reset();
    }

    NanoScroll.prototype.createEvents = function() {
      var _this = this;
      this.events = {
        down: function(e) {
          _this.isDrag = true;
          _this.offsetY = e.clientY - _this.slider.offset().top;
          _this.pane.addClass('active');
          $(document).bind(MOUSEMOVE, _this.events[DRAG]);
          $(document).bind(MOUSEUP, _this.events[UP]);
          return false;
        },
        drag: function(e) {
          _this.sliderY = e.clientY - _this.el.offset().top - _this.offsetY;
          _this.scroll();
          return false;
        },
        up: function(e) {
          _this.isDrag = false;
          _this.pane.removeClass('active');
          $(document).unbind(MOUSEMOVE, _this.events[DRAG]);
          $(document).unbind(MOUSEUP, _this.events[UP]);
          return false;
        },
        resize: function(e) {
          _this.reset();
        },
        panedown: function(e) {
          _this.sliderY = e.clientY - _this.el.offset().top - _this.sliderH * 0.5;
          _this.scroll();
          _this.events.down(e);
        },
        scroll: function(e) {
          var content, top;
          content = _this.content[0];
          if (_this.isDrag === true) return;
          top = content.scrollTop / (content.scrollHeight - content.clientHeight) * (_this.paneH - _this.sliderH);
          _this.slider.css({
            top: top + 'px'
          });
        },
        wheel: function(e) {
          _this.sliderY += -e.wheelDeltaY || -e.delta;
          _this.scroll();
          return false;
        }
      };
    };

    NanoScroll.prototype.addEvents = function() {
      var events, pane;
      events = this.events;
      pane = this.pane;
      $(window).bind(RESIZE, events[RESIZE]);
      this.slider.bind(MOUSEDOWN, events[DOWN]);
      pane.bind(MOUSEDOWN, events[PANEDOWN]);
      this.content.bind(SCROLL, events[SCROLL]);
      if (window.addEventListener) {
        pane = pane[0];
        pane.addEventListener(MOUSEWHEEL, events[WHEEL]);
        pane.addEventListener(DOMSCROLL, events[WHEEL]);
      }
    };

    NanoScroll.prototype.removeEvents = function() {
      var events, pane;
      events = this.events;
      pane = this.pane;
      $(window).unbind(RESIZE, events[RESIZE]);
      this.slider.unbind(MOUSEDOWN, events[DOWN]);
      pane.unbind(MOUSEDOWN, events[PANEDOWN]);
      this.content.unbind(SCROLL, events[SCROLL]);
      if (window.addEventListener) {
        pane = pane[0];
        pane.removeEventListener(MOUSEWHEEL, events[WHEEL]);
        pane.removeEventListener(DOMSCROLL, events[WHEEL]);
      }
    };

    NanoScroll.prototype.generate = function() {
      this.el.append('<div class="pane"><div class="slider"></div></div>');
      this.content = $(this.el.children()[0]);
      this.slider = this.el.find('.slider');
      this.pane = this.el.find('.pane');
      this.scrollW = getScrollbarWidth();
      if (this.scrollbarWidth === 0) this.scrollW = 0;
      this.content.css({
        right: -this.scrollW + 'px'
      });
      if ($.browser.msie != null) {
        if (parseInt($.browser.version, 10) < 8) this.pane.hide();
      }
    };

    NanoScroll.prototype.reset = function() {
      if (this.isDead === true) {
        this.isDead = false;
        this.pane.show();
        this.addEvents();
      }
      this.contentH = this.content[0].scrollHeight + this.scrollW;
      this.paneH = this.pane.outerHeight();
      this.sliderH = this.paneH / this.contentH * this.paneH;
      this.sliderH = Math.round(this.sliderH);
      this.scrollH = this.paneH - this.sliderH;
      this.slider.height(this.sliderH);
      if (this.paneH >= this.content[0].scrollHeight) {
        this.pane.hide();
      } else {
        this.pane.show();
      }
    };

    NanoScroll.prototype.scroll = function() {
      var scrollValue;
      this.sliderY = Math.max(0, this.sliderY);
      this.sliderY = Math.min(this.scrollH, this.sliderY);
      scrollValue = this.paneH - this.contentH + this.scrollW;
      scrollValue = scrollValue * this.sliderY / this.scrollH;
      this.content.scrollTop(-scrollValue);
      return this.slider.css({
        top: this.sliderY
      });
    };

    NanoScroll.prototype.scrollBottom = function(offsetY) {
      this.reset();
      this.content.scrollTop(this.contentH - this.content.height() - offsetY);
    };

    NanoScroll.prototype.scrollTop = function(offsetY) {
      this.reset();
      this.content.scrollTop(offsetY + 0);
    };

    NanoScroll.prototype.stop = function() {
      this.isDead = true;
      this.removeEvents();
      this.pane.hide();
    };

    return NanoScroll;

  })();
  return $.fn.nanoScroller = function(options) {
    var scrollbar;
    options || (options = {});
    scrollbar = this.data(SCROLLBAR);
    if (scrollbar === void 0) {
      scrollbar = new NanoScroll(this);
      this.data(SCROLLBAR, scrollbar);
    }
    if (options.scrollBottom) return scrollbar.scrollBottom(options.scrollBottom);
    if (options.scrollTop) return scrollbar.scrollTop(options.scrollTop);
    if (options.scroll === 'bottom') return scrollbar.scrollBottom(0);
    if (options.scroll === 'top') return scrollbar.scrollTop(0);
    if (options.stop) return scrollbar.stop();
    scrollbar.reset();
  };
})(jQuery, window, document);
