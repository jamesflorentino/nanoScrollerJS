(($, window, document) ->

  SCROLLBAR  = 'scrollbar'
  SCROLL     = 'scroll'
  MOUSEDOWN  = 'mousedown'
  MOUSEMOVE  = 'mousemove'
  MOUSEWHEEL = 'mousewheel'
  MOUSEUP    = 'mouseup'
  RESIZE     = 'resize'
  DRAG       = 'drag'
  UP         = 'up'
  PANEDOWN   = 'panedown'
  DOMSCROLL  = 'DOMMouseScroll'
  DOWN       = 'down'
  WHEEL      = 'wheel'

  defaults =
    paneClass: 'pane'
    sliderClass: 'slider'
    sliderMinHeight: 20
    contentClass: 'content'
    iOSNativeScrolling: false
    preventPageScrolling: false

  getScrollbarWidth = ->
    outer                = document.createElement 'div'
    outerStyle = outer.style
    outerStyle.position = 'absolute'
    outerStyle.width    = '100px'
    outerStyle.height   = '100px'
    outerStyle.overflow = SCROLL
    outerStyle.top      = '-9999px'
    document.body.appendChild outer
    scrollbarWidth = outer.offsetWidth - outer.clientWidth
    document.body.removeChild outer
    scrollbarWidth

  class NanoScroll

    constructor: (el, @options) ->
      @el = $(el)
      @doc = $(document)
      @win = $(window)
      @generate()
      @createEvents()
      @addEvents()
      @reset()

    createEvents: ->
      ## filesize reasons
      @events =
        down: (e) =>
          @isDrag  = true
          @offsetY = e.clientY - @slider.offset().top
          @pane.addClass 'active'
          @doc.bind(MOUSEMOVE, @events[DRAG]).bind MOUSEUP, @events[UP]
          false

        drag: (e) =>
          @sliderY = e.clientY - @el.offset().top - @offsetY
          @scroll()
          false

        up: (e) =>
          @isDrag = false
          @pane.removeClass 'active'
          @doc.unbind(MOUSEMOVE, @events[DRAG]).unbind MOUSEUP, @events[UP]
          false

        resize: (e) =>
          @reset()
          return

        panedown: (e) =>
          @sliderY = e.clientY - @el.offset().top - @sliderH * 0.5
          @scroll()
          @events.down e
          return

        scroll: (e) =>
          return if @isDrag is true
          content = @content[0]
          top = content.scrollTop / (content.scrollHeight - content.clientHeight) * (@paneH - @sliderH)

          if top + @sliderH is @paneH
            if @options.preventPageScrolling and e.originalEvent.wheelDelta < 0 then e.preventDefault()
            @el.trigger('scrollend')
          else if top is 0
            if @options.preventPageScrolling and e.originalEvent.wheelDelta > 0 then e.preventDefault()
            @el.trigger('scrolltop')

          @slider.css top: top + 'px'
          
          return

        wheel: (e) =>
          @sliderY +=  -e.wheelDeltaY || -e.delta
          @scroll()
          return false
      return

    addEvents: ->
      events = @events
      pane = @pane
      @win.bind RESIZE         , events[RESIZE]
      @slider.bind MOUSEDOWN   , events[DOWN]
      pane.bind MOUSEDOWN      , events[PANEDOWN]
      @content.bind MOUSEWHEEL , events[SCROLL]

      if window.addEventListener
        pane = pane[0]
        pane.addEventListener MOUSEWHEEL , events[WHEEL] , false
        pane.addEventListener DOMSCROLL  , events[WHEEL] , false
      return

    removeEvents: ->
      events = @events
      pane = @pane
      @win.unbind RESIZE  , events[RESIZE]
      @slider.unbind MOUSEDOWN , events[DOWN]
      pane.unbind MOUSEDOWN    , events[PANEDOWN]
      @content.unbind SCROLL   , events[SCROLL]

      if window.addEventListener
        pane = pane[0]
        pane.removeEventListener MOUSEWHEEL , events[WHEEL] , false
        pane.removeEventListener DOMSCROLL  , events[WHEEL] , false
      return

    generate: ->
      options = @options
      @el.append '<div class="' + options.paneClass + '"><div class="' + options.sliderClass + '" /></div>'
      @content = $ @el.children(".#{options.contentClass}")[0]
      @slider  = @el.find ".#{options.sliderClass}"
      @pane    = @el.find ".#{options.paneClass}"
      @scrollW = getScrollbarWidth()

      if options.iOSNativeScrolling
        @content.css
          right  : -@scrollW + 'px'
          WebkitOverflowScrolling: 'touch'
      else
        @content.css
          right  : -@scrollW + 'px'

      return

    reset: ->
      if not @el.find(".#{@options.paneClass}").length
        @generate()
        @stop()
      if @isDead is true
        @isDead = false
        @pane.show()
        @addEvents()

      content = @content[0]
      contentStyle = content.style
      contentStyleOverflowY = contentStyle.overflowY
      # try to detect IE7 and IE7 compatibility mode.
      # this sniffing is done to fix a IE7 related bug.
      if window.navigator.appName is 'Microsoft Internet Explorer' and (/msie 7./i).test(window.navigator.appVersion) and window.ActiveXObject
        @content.css height: @content.height()
      @contentH  = content.scrollHeight + @scrollW
      @paneH     = @pane.outerHeight()
      paneTop    = parseInt(@pane.css('top'), 10)
      paneBottom = parseInt(@pane.css('bottom'), 10)
      @paneOuterH = @paneH + paneTop + paneBottom
      @sliderH   = Math.round @paneOuterH / @contentH * @paneOuterH
      @sliderH   = if @sliderH > @options.sliderMinHeight then @sliderH else @options.sliderMinHeight # set min height
      @sliderH  += @scrollW if contentStyleOverflowY is SCROLL and contentStyle.overflowX isnt SCROLL
      @scrollH   = @paneOuterH - @sliderH
      @slider.height  @sliderH
      @diffH = content.scrollHeight - content.clientHeight

      @pane.show()
      if @paneOuterH >= content.scrollHeight and contentStyleOverflowY isnt SCROLL
        @pane.hide() 
      else if @el.height() is content.scrollHeight and contentStyleOverflowY is SCROLL
        @slider.hide()
      else
        @slider.show() 
      return

    scroll: ->
      @sliderY    = Math.max 0, @sliderY
      @sliderY    = Math.min @scrollH, @sliderY
      scrollValue = (@paneH - @contentH + @scrollW) * @sliderY / @scrollH
      # scrollvalue = (paneh - ch + sw) * sy / sw
      @content.scrollTop -scrollValue
      @slider.css top: @sliderY
      return

    scrollBottom: (offsetY) ->
      diffH = @diffH
      scrollTop = @content[0].scrollTop
      @reset()
      return if scrollTop < diffH and scrollTop isnt 0
      @content.scrollTop @contentH - @content.height() - offsetY
      return

    scrollTop: (offsetY) ->
      @reset()
      @content.scrollTop +offsetY
      return

    scrollTo: (node) ->
      @reset()
      offset = $(node).offset().top

      if offset > @scrollH
        fraction = offset / @contentH
        new_slider = @scrollH * fraction
        @sliderY = new_slider
        @scroll()
      return

    stop: ->
      @isDead = true
      @removeEvents()
      @pane.hide()
      return


  $.fn.nanoScroller = (settings) ->
    options = $.extend({}, defaults, settings)
    @each ->
      me = this
      scrollbar = $.data me, SCROLLBAR
      if not scrollbar
        scrollbar = new NanoScroll me, options
        $.data me, SCROLLBAR, scrollbar

      return scrollbar.scrollBottom(options.scrollBottom) if options.scrollBottom
      return scrollbar.scrollTop(options.scrollTop)       if options.scrollTop
      return scrollbar.scrollTo(options.scrollTo)         if options.scrollTo
      return scrollbar.scrollBottom(0)                    if options.scroll is 'bottom'
      return scrollbar.scrollTop(0)                       if options.scroll is 'top'
      return scrollbar.scrollTo(options.scroll)           if options.scroll instanceof $
      return scrollbar.stop()                             if options.stop
      scrollbar.reset()
    return
  return

)(jQuery, window, document)
