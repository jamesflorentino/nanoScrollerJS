(($, window, document) ->
  "use strict"

  defaults =
    paneClass: 'pane'
    sliderClass: 'slider'
    contentClass: 'content'
    iOSNativeScrolling: false
    preventPageScrolling: false
    disableResize: false
    alwaysVisible: false
    flashDelay: 1500
    sliderMinHeight: 20
    sliderMaxHeight: null

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
    constructor: (@el, @options) ->
      BROWSER_SCROLLBAR_WIDTH or= do getBrowserScrollbarWidth
      @$el = $ @el
      @doc = $ document
      @win = $ window
      do @generate
      do @createEvents
      do @addEvents
      do @reset

    preventScrolling: (e, direction) ->
      return unless @isActive
      if e.type is DOMSCROLL # Gecko
        if direction is DOWN and e.originalEvent.detail > 0 or direction is UP and e.originalEvent.detail < 0
          do e.preventDefault
      else if e.type is MOUSEWHEEL # WebKit, Trident and Presto
        return if not e.originalEvent or not e.originalEvent.wheelDelta
        if direction is DOWN and e.originalEvent.wheelDelta < 0 or direction is UP and e.originalEvent.wheelDelta > 0
          do e.preventDefault
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

    createEvents: ->
      @events =
        down: (e) =>
          @isBeingDragged  = true
          @offsetY = e.pageY - @slider.offset().top
          @pane.addClass 'active'
          @doc
            .bind(MOUSEMOVE, @events[DRAG])
            .bind(MOUSEUP, @events[UP])
          false

        drag: (e) =>
          @sliderY = e.pageY - @$el.offset().top - @offsetY
          do @scroll
          do @updateScrollValues
          if @contentScrollTop >= @maxScrollTop
            @$el.trigger 'scrollend'
          else if @contentScrollTop is 0
            @$el.trigger 'scrolltop'
          false

        up: (e) =>
          @isBeingDragged = false
          @pane.removeClass 'active'
          @doc
            .unbind(MOUSEMOVE, @events[DRAG])
            .unbind(MOUSEUP, @events[UP])
          false

        resize: (e) =>
          do @reset
          return

        panedown: (e) =>
          @sliderY = (e.offsetY or e.originalEvent.layerY) - (@sliderHeight * 0.5)
          do @scroll
          @events.down e
          false

        scroll: (e) =>
          # Don't operate if there is a dragging mechanism going on.
          # This is invoked when a user presses and moves the slider or pane
          return if @isBeingDragged
          do @updateScrollValues
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
            @$el.trigger 'scrollend'
          else if @contentScrollTop is 0
            @preventScrolling(e, UP) if @options.preventPageScrolling
            @$el.trigger 'scrolltop'
          return

        wheel: (e) =>
          return unless e?
          @sliderY +=  -e.wheelDeltaY or -e.delta
          do @scroll
          false

      return

    addEvents: ->
      do @removeEvents
      events = @events
      if not @options.disableResize
        @win
          .bind RESIZE, events[RESIZE]
      @slider
        .bind MOUSEDOWN, events[DOWN]
      @pane
        .bind(MOUSEDOWN, events[PANEDOWN])
        .bind("#{MOUSEWHEEL} #{DOMSCROLL}", events[WHEEL])
      @content
        .bind("#{SCROLL} #{MOUSEWHEEL} #{DOMSCROLL} #{TOUCHMOVE}", events[SCROLL])
      return

    removeEvents: ->
      events = @events
      @win
        .unbind(RESIZE, events[RESIZE])
      do @slider.unbind
      do @pane.unbind
      @content
        .unbind("#{SCROLL} #{MOUSEWHEEL} #{DOMSCROLL} #{TOUCHMOVE}", events[SCROLL])
        .unbind(KEYDOWN, events[KEYDOWN])
        .unbind(KEYUP, events[KEYUP])
      return

    generate: ->
      # For reference:
      # http://msdn.microsoft.com/en-us/library/windows/desktop/bb787527(v=vs.85).aspx#parts_of_scroll_bar
      options = @options
      {paneClass, sliderClass, contentClass} = options
      if not @$el.find("#{paneClass}").length and not @$el.find("#{sliderClass}").length
        @$el.append """<div class="#{paneClass}"><div class="#{sliderClass}" /></div>"""
      @content = @$el.children(".#{contentClass}")
      @content.attr 'tabindex', 0

      # slider is the name for the  scrollbox or thumb of the scrollbar gadget
      @slider = @$el.find ".#{sliderClass}"

      # pane is the name for the actual scrollbar.
      @pane = @$el.find ".#{paneClass}"

      if BROWSER_SCROLLBAR_WIDTH
        cssRule = right: -BROWSER_SCROLLBAR_WIDTH
        @$el.addClass 'has-scrollbar'
      if options.iOSNativeScrolling
        cssRule ?= {}
        cssRule.WebkitOverflowScrolling = 'touch'
      @content.css cssRule if cssRule?
      this

    restore: ->
      @stopped = false
      do @pane.show
      do @addEvents

    reset: ->
      @generate().stop() if not @$el.find(".#{@options.paneClass}").length
      do @restore if @stopped
      content = @content[0]
      contentStyle = content.style
      contentStyleOverflowY = contentStyle.overflowY

      # try to detect IE7 and IE7 compatibility mode.
      # this sniffing is done to fix a IE7 related bug.
      @content.css height: do @content.height if BROWSER_IS_IE7

      # set the scrollbar UI's height
      # the target content
      contentHeight = content.scrollHeight + BROWSER_SCROLLBAR_WIDTH

      # set the pane's height.
      paneHeight = do @pane.outerHeight
      paneTop = parseInt @pane.css('top'), 10
      paneBottom = parseInt @pane.css('bottom'), 10
      paneOuterHeight = paneHeight + paneTop + paneBottom

      # set the slider's height
      sliderHeight = Math.round paneOuterHeight / contentHeight * paneOuterHeight
      if sliderHeight < @options.sliderMinHeight
        sliderHeight = @options.sliderMinHeight # set min height
      else if @options.sliderMaxHeight? and sliderHeight > @options.sliderMaxHeight
        sliderHeight = @options.sliderMaxHeight # set max height
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
      do @events.scroll

      do @pane.show
      @isActive = true
      if @pane.outerHeight(true) >= content.scrollHeight and contentStyleOverflowY isnt SCROLL
        do @pane.hide
        @isActive = false
      else if @el.clientHeight is content.scrollHeight and contentStyleOverflowY is SCROLL
        do @slider.hide
      else
        do @slider.show

      # allow the pane element to stay visible
      if @options.alwaysVisible
        @pane.css opacity: 1, visibility: 'visible'
      else
        @pane.css opacity: '', visibility: ''

      this

    scroll: ->
      @sliderY = Math.max 0, @sliderY
      @sliderY = Math.min @maxSliderTop, @sliderY
      @content.scrollTop (@paneHeight - @contentHeight + BROWSER_SCROLLBAR_WIDTH) * @sliderY / @maxSliderTop * -1
      @slider.css top: @sliderY
      this

    scrollBottom: (offsetY) ->
      do @reset
      @content.scrollTop(@contentHeight - @content.height() - offsetY).trigger(MOUSEWHEEL) # Update scrollbar position by triggering one of the scroll events
      this

    scrollTop: (offsetY) ->
      do @reset
      @content.scrollTop(+offsetY).trigger(MOUSEWHEEL) # Update scrollbar position by triggering one of the scroll events
      this

    scrollTo: (node) ->
      do @reset
      offset = $(node).offset().top
      if offset > @maxSliderTop
        fraction = offset / @contentHeight
        new_slider = @maxSliderTop * fraction
        @sliderY = new_slider
        do @scroll
      this

    stop: ->
      @stopped = true
      do @removeEvents
      do @pane.hide
      this

    flash: ->
      do @reset
      @pane.addClass 'flashed'
      setTimeout =>
        @pane.removeClass 'flashed'
        return
      , @options.flashDelay
      this

  $.fn.nanoScroller = (settings) ->
    @each ->
      if not scrollbar = @nanoscroller
        options = $.extend {}, defaults, settings
        @nanoscroller = scrollbar = new NanoScroll this, options
      
      # scrollbar settings
      if settings and typeof settings is "object"
        $.extend scrollbar.options, settings # update scrollbar settings
        return scrollbar.scrollBottom settings.scrollBottom if settings.scrollBottom
        return scrollbar.scrollTop settings.scrollTop if settings.scrollTop
        return scrollbar.scrollTo settings.scrollTo if settings.scrollTo
        return scrollbar.scrollBottom 0 if settings.scroll is 'bottom'
        return scrollbar.scrollTop 0 if settings.scroll is 'top'
        return scrollbar.scrollTo settings.scroll if settings.scroll and settings.scroll instanceof $
        return do scrollbar.stop if settings.stop
        return do scrollbar.flash if settings.flash

      do scrollbar.reset
  return

)(jQuery, window, document)
