(function() {
  var $, NanoScroll;
  $ = this.jQuery;
  NanoScroll = (function() {
    NanoScroll.prototype.slider = null;
    NanoScroll.prototype.pane = null;
    NanoScroll.prototype.content = null;
    NanoScroll.prototype.scrollHeight = 0;
    NanoScroll.prototype.sliderHeight = 0;
    NanoScroll.prototype.paneHeight = 0;
    NanoScroll.prototype.sliderY = 0;
    NanoScroll.prototype.offsetY = 0;
    NanoScroll.prototype.contentHeight = 0;
    NanoScroll.prototype.contentY = 0;
    function NanoScroll(target, options) {
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
        me.offsetY = e.clientY - me.slider.offset().top;
        $(document).bind('mousemove', me.handler.onDrag);
        $(document).bind('mouseup', me.handler.onUp);
        return false;
      };
      this.handler.onWheel = function(e) {
        me.sliderY += e.wheelDeltaY * -.5 || e.wheelDelta || e.detail;
        me.scroll();
        e = $.event.fix(e);
        e.preventDefault();
        return false;
      };
      this.handler.onDrag = function(e) {
        me.sliderY = e.clientY - me.target.offset().top - me.offsetY;
        me.scroll();
        return false;
      };
      this.handler.onUp = function(e) {
        $(document).unbind('mousemove', me.handler.onDrag);
        $(document).unbind('mouseup', me.handler.onUp);
        return false;
      };
      this.handler.onResize = function(e) {
        me.reset();
        return me.scroll();
      };
      return this.handler.onDragPane = function(e) {
        me.sliderY = e.clientY - me.target.offset().top - me.sliderHeight * .5;
        me.scroll();
        return me.handler.onDown(e);
      };
    };
    NanoScroll.prototype.assignListeners = function() {
      this.slider.bind('mousedown', this.handler.onDown);
      this.pane.bind('mousedown', this.handler.onDragPane);
      $(window).bind('resize', this.handler.onResize);
      this.content[0].addEventListener('DOMMouseScroll', this.handler.onWheel, false);
      this.content[0].addEventListener('mousewheel', this.handler.onWheel, false);
    };
    NanoScroll.prototype.removeEventListeners = function() {
      this.slider.unbind('mousedown', this.handler.onDown);
      $(window).unbind('resize', this.handler.onResize);
      this.content[0].removeEventListener('DOMMouseScroll', this.handler.onWheel, false);
      return this.content[0].removeEventListener('mousewheel', this.handler.onWheel, false);
    };
    NanoScroll.prototype.generateElements = function() {
      this.target.append('<div class="pane"><div class="slider"></div></div>');
      this.content = $(this.target.children()[0]);
      this.slider = this.target.find('.slider');
      this.pane = this.target.find('.pane');
    };
    NanoScroll.prototype.reset = function() {
      this.contentHeight = this.content[0].scrollHeight;
      this.paneHeight = this.pane.innerHeight();
      this.sliderHeight = this.paneHeight / this.contentHeight;
      this.sliderHeight *= this.paneHeight;
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
      scrollValue = this.paneHeight - this.contentHeight;
      scrollValue = scrollValue * this.sliderY / this.scrollHeight;
      this.content.scrollTop(-scrollValue);
      this.slider.css({
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
    if (options.update === true) {
      scrollbar.reset();
    }
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
