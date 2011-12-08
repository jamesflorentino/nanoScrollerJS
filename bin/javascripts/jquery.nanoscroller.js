(function() {
  var $, NanoScroll;
  $ = this.jQuery;
  NanoScroll = (function() {
    function NanoScroll(target, options) {
      this.slider = null;
      this.pane = null;
      this.content = null;
      this.scrollHeight = 0;
      this.sliderHeight = 0;
      this.paneHeight = 0;
      this.sliderY = 0;
      this.offsetY = 0;
      this.contentHeight = 0;
      this.contentY = 0;
      this.isDragging = false;
      options = options || {};
      this.target = target;
      this.generateElements();
      this.createEventHandlers();
      this.assignListeners();
      this.reset();
      return;
    }
    NanoScroll.prototype.createEventHandlers = function() {
      var me;
      me = this;
      this.handler = [];
      this.handler.onDown = function(e) {
        me.isDragging = true;
        me.offsetY = e.clientY - me.slider.offset().top;
        me.pane.addClass('active');
        $(document).bind('mousemove', me.handler.onDrag);
        $(document).bind('mouseup', me.handler.onUp);
        return false;
      };
      this.handler.onDrag = function(e) {
        me.sliderY = e.clientY - me.target.offset().top - me.offsetY;
        me.scroll();
        return false;
      };
      this.handler.onUp = function(e) {
        me.isDragging = false;
        me.pane.removeClass('active');
        $(document).unbind('mousemove', me.handler.onDrag);
        $(document).unbind('mouseup', me.handler.onUp);
        return false;
      };
      this.handler.onResize = function(e) {
        me.reset();
        return me.scroll();
      };
      this.handler.onDownPane = function(e) {
        me.sliderY = e.clientY - me.target.offset().top - me.sliderHeight * .5;
        me.scroll();
        return me.handler.onDown(e);
      };
      return this.handler.onScroll = function(e) {
        var top;
        if (me.isDragging === true) {
          return;
        }
        top = me.content[0].scrollTop / me.content[0].scrollHeight * (me.paneHeight + 5);
        return me.slider.css({
          top: Math.floor(top)
        });
      };
    };
    NanoScroll.prototype.assignListeners = function() {
      $(window).bind('resize', this.handler.onResize);
      this.slider.bind('mousedown', this.handler.onDown);
      this.pane.bind('mousedown', this.handler.onDownPane);
      return this.content.bind('scroll', this.handler.onScroll);
    };
    NanoScroll.prototype.removeEventListeners = function() {
      $(window).unbind('resize', this.handler.onResize);
      this.slider.unbind('mousedown', this.handler.onDown);
      this.pane.unbind('mousedown', this.handler.onDownPane);
      return this.content.unbind('scroll', this.handler.onScroll);
    };
    NanoScroll.prototype.getScrollbarWidth = function() {
      var inner, noscrollWidth, outer, yesscrollWidth;
      outer = document.createElement('div');
      inner = document.createElement('div');
      outer.style.position = 'absolute';
      outer.style.width = '100px';
      outer.style.height = '50px';
      outer.style.overflow = 'scroll';
      document.body.appendChild(outer);
      noscrollWidth = outer.offsetWidth;
      yesscrollWidth = outer.scrollWidth;
      document.body.removeChild(outer);
      return noscrollWidth - yesscrollWidth;
    };
    NanoScroll.prototype.generateElements = function() {
      this.target.append('<div class="pane"><div class="slider"></div></div>');
      this.content = $(this.target.children()[0]);
      this.slider = this.target.find('.slider');
      this.pane = this.target.find('.pane');
      this.scrollbarWidth = this.getScrollbarWidth();
      if (this.scrollbarWidth === 0) {
        this.scrollbarWidth = 0;
      }
      this.content.css({
        right: -this.scrollbarWidth + 'px'
      });
      if ($.browser.msie != null) {
        if (parseInt($.browser.version) < 8) {
          this.pane.hide();
        }
      }
    };
    NanoScroll.prototype.reset = function() {
      this.contentHeight = this.content[0].scrollHeight;
      this.paneHeight = this.pane.height();
      this.sliderHeight = this.paneHeight / this.contentHeight * this.paneHeight;
      this.scrollHeight = this.paneHeight - this.sliderHeight;
      this.slider.height(this.sliderHeight);
    };
    NanoScroll.prototype.scroll = function() {
      var scrollValue;
      if (this.sliderY < 0) {
        this.sliderY = 0;
      }
      if (this.sliderY > this.scrollHeight) {
        this.sliderY = this.scrollHeight;
      }
      scrollValue = this.paneHeight - this.contentHeight + this.scrollbarWidth;
      scrollValue = scrollValue * this.sliderY / this.scrollHeight;
      this.content.scrollTop(-scrollValue);
      return this.slider.css({
        top: this.sliderY
      });
    };
    NanoScroll.prototype.scrollBottom = function(offsetY) {
      this.reset();
      this.sliderY = this.scrollHeight;
      this.scroll();
    };
    NanoScroll.prototype.scrollTop = function(offsetY) {
      this.reset();
      this.sliderY = 0;
      this.scroll();
    };
    NanoScroll.prototype.stop = function() {
      this.removeEventListeners();
      return this.pane.hide();
    };
    return NanoScroll;
  })();
  $.fn.nanoScroller = function(options) {
    var scrollbar;
    options = options || {};
    scrollbar = this.data('scrollbar');
    if (scrollbar === void 0) {
      scrollbar = new NanoScroll(this, options);
      this.data({
        'scrollbar': scrollbar
      });
      return;
    }
    scrollbar.reset();
    if (options.scroll === 'bottom') {
      scrollbar.scrollBottom();
    }
    if (options.scroll === 'top') {
      scrollbar.scrollTop();
    }
    if (options.stop === true) {
      scrollbar.stop();
    }
    return false;
  };
}).call(this);
