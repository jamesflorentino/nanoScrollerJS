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
        e.preventDefault();
        me.sliderY += e.wheelDeltaY || e.wheelDelta || e.detail;
        me.scroll();
        e = $.event.fix(e);
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
      /*
          @handler.onTouchStart = (e) ->
            touch       = e.touches[0] || e.touches
            me.offsetY  = touch.clientY - me.slider.offset().top
            me.target[0].removeEventListener 'touchstart', me.handler.onTouchStart
            me.target[0].addEventListener 'touchmove', me.handler.onTouchMove
            me.target[0].addEventListener 'touchend', me.handler.onTouchEnd
          
          @handler.onTouchMove = (e) ->
            e.preventDefault()
            touch = e.touches[0] || e.touches
            me.sliderY  = touch.clientY -  me.target.offset().top - me.offsetY
            me.scroll()
      
          @handler.onTouchEnd = (e) ->
            me.target[0].addEventListener 'touchstart', me.handler.onTouchStart
            me.target[0].removeEventListener 'touchmove', me.handler.onTouchMove
            me.target[0].removeEventListener 'touchend', me.handler.onTouchEnd
          */
    };
    NanoScroll.prototype.assignListeners = function() {
      var me;
      me = this;
      $(window).bind('resize', this.handler.onResize);
      this.slider.bind('mousedown', this.handler.onDown);
      this.pane.bind('mousedown', this.handler.onDragPane);
      this.target[0].addEventListener('DOMMouseScroll', this.handler.onWheel, false);
      this.target[0].addEventListener('mousewheel', this.handler.onWheel, false);
    };
    NanoScroll.prototype.removeEventListeners = function() {
      $(window).unbind('resize', this.handler.onResize);
      this.slider.unbind('mousedown', this.handler.onDown);
      this.pane.unbind('mousedown', this.handler.onDragPane);
      this.target[0].removeEventListener('DOMMouseScroll', this.handler.onWheel, false);
      this.target[0].removeEventListener('mousewheel', this.handler.onWheel, false);
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
      var scrollValue, version;
      if (this.sliderY < 0) {
        this.sliderY = 0;
      }
      if (this.sliderY > this.scrollHeight) {
        this.sliderY = this.scrollHeight;
      }
      scrollValue = this.paneHeight - this.contentHeight;
      scrollValue = scrollValue * this.sliderY / this.scrollHeight;
      version = 'old';
      switch (version) {
        case 'old':
          this.target.addClass('old');
          this.content.scrollTop(-scrollValue);
          this.slider.css({
            top: this.sliderY
          });
          break;
        default:
          this.content.css({
            '-webkit-transform': 'translateY(' + scrollValue + 'px)',
            '-moz-transform': 'translateY(' + scrollValue + 'px)',
            '-o-transform': 'translateY(' + scrollValue + 'px)',
            '-transform': 'translateY(' + scrollValue + 'px)'
          });
          this.slider.css({
            '-webkit-transform': 'translateY(' + this.sliderY + 'px)',
            '-moz-transform': 'translateY(' + this.sliderY + 'px)',
            '-o-transform': 'translateY(' + this.sliderY + 'px)',
            '-transform': 'translateY(' + this.sliderY + 'px)'
          });
      }
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
