(function() {
  var $, NanoScroll;
  $ = this.jQuery;
  NanoScroll = (function() {
    function NanoScroll(target, options) {
      this.slider = null;
      this.pane = null;
      this.content = null;
      this.scrollH = 0;
      this.sliderH = 0;
      this.paneH = 0;
      this.sliderY = 0;
      this.offsetY = 0;
      this.contentH = 0;
      this.contentY = 0;
      this.isDrag = false;
      options = options || {};
      this.target = target;
      this.generate();
      this.createEvents();
      this.assignEvents();
      this.reset();
      return;
    }
    NanoScroll.prototype.createEvents = function() {
      var me;
      me = this;
      return this.handler = {
        down: function(e) {
          me.isDrag = true;
          me.offsetY = e.clientY - me.slider.offset().top;
          me.pane.addClass('active');
          $(document).bind('mousemove', me.handler.drag);
          $(document).bind('mouseup', me.handler.up);
          return false;
        },
        drag: function(e) {
          me.sliderY = e.clientY - me.target.offset().top - me.offsetY;
          me.scroll();
          return false;
        },
        up: function(e) {
          me.isDrag = false;
          me.pane.removeClass('active');
          $(document).unbind('mousemove', me.handler.drag);
          $(document).unbind('mouseup', me.handler.up);
          return false;
        },
        resize: function(e) {
          me.reset();
          return me.scroll();
        },
        panedown: function(e) {
          me.sliderY = e.clientY - me.target.offset().top - me.sliderH * .5;
          me.scroll();
          return me.handler.down(e);
        },
        scroll: function(e) {
          var top;
          if (me.isDrag === true) {
            return;
          }
          top = me.content[0].scrollTop / me.content[0].scrollHeight * (me.paneH + 5);
          return me.slider.css({
            top: Math.floor(top)
          });
        }
      };
    };
    NanoScroll.prototype.assignEvents = function() {
      $(window).bind('resize', this.handler.resize);
      this.slider.bind('mousedown', this.handler.down);
      this.pane.bind('mousedown', this.handler.panedown);
      return this.content.bind('scroll', this.handler.scroll);
    };
    NanoScroll.prototype.removeEventListeners = function() {
      $(window).unbind('resize', this.handler.resize);
      this.slider.unbind('mousedown', this.handler.down);
      this.pane.unbind('mousedown', this.handler.panedown);
      return this.content.unbind('scroll', this.handler.scroll);
    };
    NanoScroll.prototype.getScrollbarWidth = function() {
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
    NanoScroll.prototype.generate = function() {
      this.target.append('<div class="pane"><div class="slider"></div></div>');
      this.content = $(this.target.children()[0]);
      this.slider = this.target.find('.slider');
      this.pane = this.target.find('.pane');
      this.scrollW = this.getScrollbarWidth();
      if (this.scrollbarWidth === 0) {
        this.scrollW = 0;
      }
      this.content.css({
        right: -this.scrollW + 'px'
      });
      if ($.browser.msie != null) {
        if (parseInt($.browser.version) < 8) {
          this.pane.hide();
        }
      }
    };
    NanoScroll.prototype.reset = function() {
      if (this.isDead === true) {
        this.isDead = false;
        this.pane.show();
        this.assignEvents();
      }
      this.contentH = this.content[0].scrollHeight;
      this.paneH = this.pane.height();
      this.sliderH = this.paneH / this.contentH * this.paneH;
      this.scrollH = this.paneH - this.sliderH;
      this.slider.height(this.sliderH);
    };
    NanoScroll.prototype.scroll = function() {
      var scrollValue;
      if (this.sliderY < 0) {
        this.sliderY = 0;
      }
      if (this.sliderY > this.scrollH) {
        this.sliderY = this.scrollH;
      }
      scrollValue = this.paneH - this.contentH + this.scrollW;
      scrollValue = scrollValue * this.sliderY / this.scrollH;
      this.content.scrollTop(-scrollValue);
      return this.slider.css({
        top: this.sliderY
      });
    };
    NanoScroll.prototype.scrollBottom = function(offsetY) {
      this.reset();
      this.sliderY = this.scrollH;
      this.scroll();
    };
    NanoScroll.prototype.scrollTop = function(offsetY) {
      this.reset();
      this.sliderY = 0;
      this.scroll();
    };
    NanoScroll.prototype.stop = function() {
      this.isDead = true;
      this.removeEventListeners();
      this.pane.hide();
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
    if (options.scroll === 'bottom') {
      return scrollbar.scrollBottom();
    }
    if (options.scroll === 'top') {
      return scrollbar.scrollTop();
    }
    if (options.stop === true) {
      return scrollbar.stop();
    }
    return scrollbar.reset();
  };
}).call(this);
