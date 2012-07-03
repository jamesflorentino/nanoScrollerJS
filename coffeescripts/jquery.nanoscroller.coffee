(($, window, document) ->
  "use strict"

  defaults =
    paneClass: 'pane'
    sliderClass: 'slider'
    sliderMinHeight: 20
    contentClass: 'content'
    iOSNativeScrolling: false
    preventPageScrolling: false
    disableResize: false
    alwaysVisible: false
    flashDelay: 1500

  # constants
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
  KEYDOWN    = 'keydown'
  KEYUP      = 'keyup'
  TOUCHMOVE  = 'touchmove'
  BROWSER_IS_IE7 = window.navigator.appName is 'Microsoft Internet Explorer' and (/msie 7./i).test(window.navigator.appVersion) and window.ActiveXObject
  BROWSER_SCROLLBAR_WIDTH = null
  KEYSTATES = {}
  KEYS =
    up: 38
    down: 40
    pgup: 33
    pgdown: 34
    home: 36
    end: 35

  getBrowserScrollbarWidth = ->
    outer = document.createElement 'div'
    outerStyle = outer.style
    outerStyle.position = 'absolute'
    outerStyle.width = '100px'
    outerStyle.height = '100px'
    outerStyle.overflow = SCROLL
    outerStyle.top = '-9999px'
    document.body.appendChild outer
    scrollbarWidth = outer.offsetWidth - outer.clientWidth
    document.body.removeChild outer
    scrollbarWidth

  class NanoScroll
    constructor: (el, @options) ->
      BROWSER_SCROLLBAR_WIDTH or= getBrowserScrollbarWidth()
      @el = $(el)
      @doc = $(document)
      @win = $(window)
      @generate()
      @createEvents()
      @addEvents()
      @reset()

    preventScrolling: (e, direction) ->
      if e.type is DOMSCROLL # Gecko
        if direction is DOWN and e.originalEvent.detail > 0 or direction is UP and e.originalEvent.detail < 0 
          e.preventDefault()
      else if e.type is MOUSEWHEEL # WebKit, Trident and Presto
        return if not e.originalEvent or not e.originalEvent.wheelDelta
        if direction is DOWN and e.originalEvent.wheelDelta < 0 or direction is UP and e.originalEvent.wheelDelta > 0
          e.preventDefault()
      return

    updateScrollValues: ->
      content = @content[0]
      # Formula/ratio
      # `scrollTop / maxScrollTop = sliderTop / maxSliderTop`
      @maxScrollTop = content.scrollHeight - content.clientHeight
      @contentScrollTop = content.scrollTop
      @maxSliderTop = @paneHeight - @sliderHeight
      # `sliderTop = scrollTop / maxScrollTop * maxSliderTop
      @sliderTop = @contentScrollTop * @maxSliderTop / @maxScrollTop
      return

    handleKeyPress: (key) ->
      if key is KEYS.up or key is KEYS.pgup or key is KEYS.down or key is KEYS.pgdown
        scrollLength = if key is KEYS.up or key is KEYS.down then 40 else @paneHeight * 0.9
        percentage = scrollLength / (@contentHeight - @paneHeight) * 100
        sliderY = (percentage * @maxSliderTop) / 100
        @sliderY = if key is KEYS.up or key is KEYS.pgup then @sliderY - sliderY else @sliderY + sliderY
        @scroll()
      else if key is KEYS.home or key is KEYS.end
        @sliderY = if key is KEYS.home then 0 else @maxSliderTop
        @scroll()
      return

    createEvents: ->
      @events =
        down: (e) =>
          @isBeingDragged  = true
          @offsetY = e.pageY - @slider.offset().top
          @pane.addClass 'active'
          @doc.bind(MOUSEMOVE, @events[DRAG]).bind(MOUSEUP, @events[UP])
          false

        drag: (e) =>
          @sliderY = e.pageY - @el.offset().top - @offsetY
          @scroll()
          @updateScrollValues()
          if @contentScrollTop >= @maxScrollTop
            @el.trigger('scrollend')
          else if @contentScrollTop is 0
            @el.trigger('scrolltop')
          false

        up: (e) =>
          @isBeingDragged = false
          @pane.removeClass 'active'
          @doc.unbind(MOUSEMOVE, @events[DRAG]).unbind(MOUSEUP, @events[UP])
          false

        resize: (e) =>
          @reset()
          return

        panedown: (e) =>
          @sliderY = (e.offsetY or e.originalEvent.layerY) - (@sliderHeight * 0.5)
          @scroll()
          @events.down e
          false

        scroll: (e) =>
          # Don't operate if there is a dragging mechanism going on.
          # This is invoked when a user presses and moves the slider or pane
          return if @isBeingDragged
          @updateScrollValues()
          # update the slider position
          @sliderY = @sliderTop
          @slider.css top: @sliderTop
          # the succeeding code should be ignored if @events.scroll() wasn't
          # invoked by a DOM event. (refer to @reset)
          return unless e?
          # if it reaches the maximum and minimum scrolling point,
          # we dispatch an event.
          if @contentScrollTop >= @maxScrollTop
            @preventScrolling(e, DOWN) if @options.preventPageScrolling
            @el.trigger('scrollend')
          else if @contentScrollTop is 0
            @preventScrolling(e, UP) if @options.preventPageScrolling
            @el.trigger('scrolltop')
          return

        wheel: (e) =>
          return unless e?
          @sliderY +=  -e.wheelDeltaY or -e.delta
          @scroll()
          false

        keydown: (e) =>
          return unless e?
          key = e.which
          if key is KEYS.up or key is KEYS.pgup or key is KEYS.down or key is KEYS.pgdown or key is KEYS.home or key is KEYS.end
            @sliderY = if isNaN(@sliderY) then 0 else @sliderY
            KEYSTATES[key] = setTimeout =>
              @handleKeyPress(key)
              return
            , 100
            e.preventDefault()
          return

        keyup: (e) =>
          return unless e?
          key = e.which
          @handleKeyPress(key)
          clearTimeout KEYSTATES[key] if KEYSTATES[key]?
          return

      return

    addEvents: ->
      events = @events
      @win.bind RESIZE, events[RESIZE] if not @options.disableResize
      @slider.bind MOUSEDOWN, events[DOWN]
      @pane.bind(MOUSEDOWN, events[PANEDOWN])
        .bind("#{MOUSEWHEEL} #{DOMSCROLL}", events[WHEEL])
      @content.bind("#{SCROLL} #{MOUSEWHEEL} #{DOMSCROLL} #{TOUCHMOVE}", events[SCROLL])
        .bind(KEYDOWN, events[KEYDOWN])
        .bind(KEYUP, events[KEYUP])
      return

    removeEvents: ->
      events = @events
      @win.unbind(RESIZE, events[RESIZE]) if not @options.disableResize
      @slider.unbind MOUSEDOWN, events[DOWN]
      @pane.unbind(MOUSEDOWN, events[PANEDOWN])
        .unbind("#{MOUSEWHEEL} #{DOMSCROLL}", events[WHEEL])
      @content.unbind("#{SCROLL} #{MOUSEWHEEL} #{DOMSCROLL} #{TOUCHMOVE}", events[SCROLL])
        .unbind(KEYDOWN, events[KEYDOWN])
        .unbind(KEYUP, events[KEYUP])
      return

    generate: ->
      # For reference:
      # http://msdn.microsoft.com/en-us/library/windows/desktop/bb787527(v=vs.85).aspx#parts_of_scroll_bar
      options = @options
      {paneClass, sliderClass, contentClass} = options
      @el.append """<div class="#{paneClass}"><div class="#{sliderClass}" /></div>"""
      @content = @el.children(".#{contentClass}")
      @content.attr 'tabindex', 0
      # slider is the name for the  scrollbox or thumb of the scrollbar gadget
      @slider  = @el.find ".#{sliderClass}"
      # pane is the name for the actual scrollbar.
      @pane    = @el.find ".#{paneClass}"
      if BROWSER_SCROLLBAR_WIDTH
        cssRule = right: -BROWSER_SCROLLBAR_WIDTH
        @el.addClass('has-scrollbar')
      if options.iOSNativeScrolling
        cssRule ?= {}
        cssRule.WebkitOverflowScrolling = 'touch' 
      @content.css cssRule if cssRule?
      @pane.css opacity: 1, visibility: 'visible' if options.alwaysVisible
      this

    restore: ->
      @stopped = false
      @pane.show()
      @addEvents()

    reset: ->
      @generate().stop() if not @el.find(".#{@options.paneClass}").length
      @restore() if @stopped
      content = @content[0]
      contentStyle = content.style
      contentStyleOverflowY = contentStyle.overflowY
      # try to detect IE7 and IE7 compatibility mode.
      # this sniffing is done to fix a IE7 related bug.
      @content.css height: @content.height() if BROWSER_IS_IE7
      # set the scrollbar UI's height
      # the target content
      contentHeight = content.scrollHeight + BROWSER_SCROLLBAR_WIDTH
      # set the pane's height.
      paneHeight = @pane.outerHeight()
      paneTop = parseInt(@pane.css('top'), 10)
      paneBottom = parseInt(@pane.css('bottom'), 10)
      paneOuterHeight = paneHeight + paneTop + paneBottom
      # set the slider's height
      sliderHeight = Math.round paneOuterHeight / contentHeight * paneOuterHeight
      sliderHeight = if sliderHeight > @options.sliderMinHeight then sliderHeight else @options.sliderMinHeight # set min height
      sliderHeight += BROWSER_SCROLLBAR_WIDTH if contentStyleOverflowY is SCROLL and contentStyle.overflowX isnt SCROLL
      # the maximum top value for the slider
      @maxSliderTop = paneOuterHeight - sliderHeight
      # set into properties for further use
      @contentHeight = contentHeight
      @paneHeight = paneHeight
      @paneOuterHeight = paneOuterHeight
      @sliderHeight = sliderHeight
      # set the values to the gadget
      @slider.height sliderHeight
      # scroll sets the position of the @slider
      @events.scroll()
      @pane.show()
      if @paneOuterHeight >= content.scrollHeight and contentStyleOverflowY isnt SCROLL
        @pane.hide()
      else if @el.height() is content.scrollHeight and contentStyleOverflowY is SCROLL
        @slider.hide()
      else
        @slider.show()
      this

    scroll: ->
      @sliderY = Math.max 0, @sliderY
      @sliderY = Math.min @maxSliderTop, @sliderY
      @content.scrollTop (@paneHeight - @contentHeight + BROWSER_SCROLLBAR_WIDTH) * @sliderY / @maxSliderTop * -1
      @slider.css top: @sliderY
      this

    scrollBottom: (offsetY) ->
      @reset()
      @content.scrollTop(@contentHeight - @content.height() - offsetY).trigger(MOUSEWHEEL) # Update scrollbar position by triggering one of the scroll events
      this

    scrollTop: (offsetY) ->
      @reset()
      @content.scrollTop(+offsetY).trigger(MOUSEWHEEL) # Update scrollbar position by triggering one of the scroll events
      this

    scrollTo: (node) ->
      @reset()
      offset = $(node).offset().top
      if offset > @maxSliderTop
        fraction = offset / @contentHeight
        new_slider = @maxSliderTop * fraction
        @sliderY = new_slider
        @scroll()
      this

    stop: ->
      @stopped = true
      @removeEvents()
      @pane.hide()
      this

    flash: ->
      @pane.addClass 'flashed'
      setTimeout =>
        @pane.removeClass 'flashed'
        return
      , @options.flashDelay
      this

  $.fn.nanoScroller = (settings) ->
    {scrollBottom, scrollTop, scrollTo, scroll, stop, flash} = settings if settings?
    options = $.extend({}, defaults, settings)
    @each ->
      me = this
      scrollbar = $.data me, SCROLLBAR
      if not scrollbar
        scrollbar = new NanoScroll me, options
        $.data me, SCROLLBAR, scrollbar
      else
        # if the developer wishes to apply the settings on a later phase.
        $.extend scrollbar.options, settings
      return scrollbar.scrollBottom(scrollBottom) if scrollBottom
      return scrollbar.scrollTop(scrollTop) if scrollTop
      return scrollbar.scrollTo(scrollTo) if scrollTo
      return scrollbar.scrollBottom(0) if scroll is 'bottom'
      return scrollbar.scrollTop(0) if scroll is 'top'
      return scrollbar.scrollTo(scroll) if scroll instanceof $
      return scrollbar.stop() if stop
      return scrollbar.flash() if flash
      scrollbar.reset()
    return
  return

)(jQuery, window, document)
