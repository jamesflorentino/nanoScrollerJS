#  @project nanoScrollerJS
#  @url http://jamesflorentino.github.com/nanoScrollerJS/
#  @author James Florentino
#  @contributor Krister Kari

(($, window, document) ->
  "use strict"

  # Default settings

  defaults =
    ###*
      a classname for the pane element.
      @property paneClass
      @type String
      @default 'pane'
    ###
    paneClass: 'pane'

    ###*
      a classname for the pane-y element.
      @property paneClassY
      @type String
      @default 'pane-y'
    ###
    paneClassY: 'pane-y'

    ###*
      a classname for the pane-x element.
      @property paneClassX
      @type String
      @default 'pane-x'
    ###
    paneClassX: 'pane-x'

    ###*
      a classname for the slider element.
      @property sliderClass
      @type String
      @default 'slider'
    ###
    sliderClass: 'slider'

    ###*
      a classname for the slider-y element.
      @property sliderClassY
      @type String
      @default 'slider-y'
    ###
    sliderClassY: 'slider-y'

    ###*
      a classname for the slider-x element.
      @property sliderClassX
      @type String
      @default 'slider-x'
    ###
    sliderClassX: 'slider-x'

    ###*
      a classname for the content element.
      @property contentClass
      @type String
      @default 'content'
    ###
    contentClass: 'content'

    ###*
      a setting to enable native scrolling in iOS devices.
      @property iOSNativeScrolling
      @type Boolean
      @default false
    ###
    iOSNativeScrolling: false

    ###*
      a setting to prevent the rest of the page being
      scrolled when user scrolls the `.content` element.
      @property preventPageScrolling
      @type Boolean
      @default false
    ###
    preventPageScrolling: false

    ###*
      a setting to disable binding to the resize event.
      @property disableResize
      @type Boolean
      @default false
    ###
    disableResize: false

    ###*
      a setting to make the scrollbar always visible.
      @property alwaysVisible
      @type Boolean
      @default false
    ###
    alwaysVisible: false

    ###*
      a default timeout for the `flash()` method.
      @property flashDelay
      @type Number
      @default 1500
    ###
    flashDelay: 1500

    ###*
      a minimum height for the `.slider` element.
      @property sliderMinHeight
      @type Number
      @default 20
    ###
    sliderMinHeight: 20

    ###*
      a maximum height for the `.slider` element.
      @property sliderMaxHeight
      @type Number
      @default null
    ###
    sliderMaxHeight: null

  # Constants

  ###*
    @property SCROLLBAR
    @type String
    @static
    @final
    @private
  ###
  SCROLLBAR = 'scrollbar'

  ###*
    @property SCROLL
    @type String
    @static
    @final
    @private
  ###
  SCROLL = 'scroll'

  ###*
    @property MOUSEDOWN
    @type String
    @final
    @private
  ###
  MOUSEDOWN = 'mousedown'

  ###*
    @property MOUSEMOVE
    @type String
    @static
    @final
    @private
  ###
  MOUSEMOVE = 'mousemove'

  ###*
    @property MOUSEWHEEL
    @type String
    @final
    @private
  ###
  MOUSEWHEEL = 'mousewheel'

  ###*
    @property MOUSEUP
    @type String
    @static
    @final
    @private
  ###
  MOUSEUP = 'mouseup'

  ###*
    @property RESIZE
    @type String
    @final
    @private
  ###
  RESIZE = 'resize'

  ###*
    @property DRAG
    @type String
    @static
    @final
    @private
  ###
  DRAG = 'drag'

  ###*
    @property UP
    @type String
    @static
    @final
    @private
  ###
  UP = 'up'

  ###*
    @property PANEDOWN
    @type String
    @static
    @final
    @private
  ###
  PANEDOWN = 'panedown'

  ###*
    @property LEFT
    @type String
    @static
    @final
    @private
  ###
  LEFT = 'left'

  ###*
    @property PANERIGHT
    @type String
    @static
    @final
    @private
  ###
  PANERIGHT = 'paneright'

  ###*
    @property DOMSCROLL
    @type String
    @static
    @final
    @private
  ###
  DOMSCROLL  = 'DOMMouseScroll'

  ###*
    @property DOWN
    @type String
    @static
    @final
    @private
  ###
  DOWN = 'down'

  ###*
    @property RIGHT
    @type String
    @static
    @final
    @private
  ###
  RIGHT = 'right'

  ###*
    @property WHEEL
    @type String
    @static
    @final
    @private
  ###
  WHEEL = 'wheel'

  ###*
    @property KEYDOWN
    @type String
    @static
    @final
    @private
  ###
  KEYDOWN    = 'keydown'

  ###*
    @property KEYUP
    @type String
    @static
    @final
    @private
  ###
  KEYUP = 'keyup'

  ###*
    @property TOUCHMOVE
    @type String
    @static
    @final
    @private
  ###
  TOUCHMOVE = 'touchmove'

  ###*
    @property BROWSER_IS_IE7
    @type Boolean
    @static
    @final
    @private
  ###
  BROWSER_IS_IE7 = window.navigator.appName is 'Microsoft Internet Explorer' and (/msie 7./i).test(window.navigator.appVersion) and window.ActiveXObject
  
  ###*
    @property BROWSER_SCROLLBAR_WIDTH
    @type Number
    @static
    @default null
    @private
  ###
  BROWSER_SCROLLBAR_WIDTH = null

  ###*
    @property BROWSER_SCROLLBAR_HEIGHT
    @type Number
    @static
    @default null
    @private
  ###
  BROWSER_SCROLLBAR_HEIGHT = null

  ###*
    Returns browser's native scrollbar width
    @method getBrowserScrollbarSizes
    @return {Number} the scrollbar width in pixels
    @static
    @private
  ###
  getBrowserScrollbarSizes = ->
    outer = document.createElement 'div'
    outerStyle = outer.style
    outerStyle.position = 'absolute'
    outerStyle.width = '100px'
    outerStyle.height = '100px'
    outerStyle.overflow = SCROLL
    outerStyle.top = '-9999px'
    document.body.appendChild outer
    scrollbarWidth = outer.offsetWidth - outer.clientWidth
    scrollbarHeight = outer.offsetHeight - outer.clientHeight
    document.body.removeChild outer
    [scrollbarWidth, scrollbarHeight]

  ###*
    @class NanoScroll
    @param element {HTMLElement|Node} the main element
    @param options {Object} nanoScroller's options
    @constructor
  ###
  class NanoScroll
    constructor: (@el, @options) ->
      if not BROWSER_SCROLLBAR_WIDTH or not BROWSER_SCROLLBAR_HEIGHT
        [BROWSER_SCROLLBAR_WIDTH, BROWSER_SCROLLBAR_HEIGHT] = do getBrowserScrollbarSizes
      @$el = $ @el
      @doc = $ document
      @win = $ window
      @$content = @$el.children(".#{options.contentClass}")
      @$content.attr 'tabindex', 0
      @content = @$content[0]

      if @options.iOSNativeScrolling && @el.style.WebkitOverflowScrolling?
        do @nativeScrolling
      else
        do @generate
      do @createEvents
      do @addEvents
      do @reset

    ###*
      Prevents the rest of the page being scrolled
      when user scrolls the `.content` element.
      @method preventVerticalScrolling
      @param event {Event}
      @param direction {String} Scroll direction (up or down)
      @private
    ###
    preventVerticalScrolling: (e, direction) ->
      return unless @isActiveY
      return
      if e.type is DOMSCROLL # Gecko
        if direction is DOWN and e.originalEvent.detail > 0 or direction is UP and e.originalEvent.detail < 0
          do e.preventDefault
      else if e.type is MOUSEWHEEL # WebKit, Trident and Presto
        return if not e.originalEvent or not e.originalEvent.wheelDelta
        if direction is DOWN and e.originalEvent.wheelDelta < 0 or direction is UP and e.originalEvent.wheelDelta > 0
          do e.preventDefault
      return

    ###*
      Prevents the rest of the page being scrolled
      when user scrolls the `.content` element.
      @method preventHorizontalScrolling
      @param event {Event}
      @param direction {String} Scroll direction (left or right)
      @private
    ###
    preventHorizontalScrolling: (e, direction) ->
      return unless @isActiveX
      return
      if e.type is DOMSCROLL # Gecko
        if direction is RIGHT and e.originalEvent.detail > 0 or direction is LEFT and e.originalEvent.detail < 0
          do e.preventDefault
      else if e.type is MOUSEWHEEL # WebKit, Trident and Presto
        return if not e.originalEvent or not e.originalEvent.wheelDelta
        if direction is RIGHT and e.originalEvent.wheelDelta < 0 or direction is LEFT and e.originalEvent.wheelDelta > 0
          do e.preventDefault
      return

    ###*
      Enable iOS native scrolling
    ####
    nativeScrolling: ->
      # simply enable container
      @$content.css {WebkitOverflowScrolling: 'touch'}
      @iOSNativeScrolling = true
      # we are always active
      @isActiveX = true
      @isActiveY = true
      return

    ###*
      Updates those nanoScroller properties that
      are related to current scrollbar position.
      @method updateVerticalScrollValues
      @private
    ###
    updateVerticalScrollValues: ->
      content = @content
      # Formula/ratio
      # `scrollTop / maxScrollTop = sliderTop / maxSliderTop`
      @maxScrollTop = content.scrollHeight - content.clientHeight
      @contentScrollTop = content.scrollTop
      if not @iOSNativeScrolling
        @maxSliderTop = @yPaneHeight - @ySliderHeight
        # `sliderTop = scrollTop / maxScrollTop * maxSliderTop
        @ySliderTop = @contentScrollTop * @maxSliderTop / @maxScrollTop
      return

    ###*
      Updates those nanoScroller properties that
      are related to current scrollbar position.
      @method updateVerticalScrollValues
      @private
    ###
    updateHorizontalScrollValues: ->
      content = @content
      # Formula/ratio
      # `scrollTop / maxScrollTop = sliderTop / maxSliderTop`
      @maxScrollLeft = content.scrollWidth - content.clientWidth
      @contentScrollLeft = content.scrollLeft
      if not @iOSNativeScrolling
        @maxSliderLeft = @xPaneWidth - @xSliderWidth
        # `sliderTop = scrollTop / maxScrollTop * maxSliderTop
        @xSliderLeft = @contentScrollLeft * @maxSliderLeft / @maxScrollLeft
      return

    ###*
      Creates event related methods
      @method createEvents
      @private
    ###
    createEvents: ->
      @yEvents =
        down: (e) =>
          @isYBeingDragged  = true
          @offsetY = e.pageY - @ySlider.offset().top
          @yPane.addClass 'active'
          @doc
            .bind(MOUSEMOVE, @yEvents[DRAG])
            .bind(MOUSEUP, @yEvents[UP])
          false

        drag: (e) =>
          @ySliderY = e.pageY - @$el.offset().top - @offsetY
          do @scrollY
          do @updateVerticalScrollValues
          if @contentScrollTop >= @maxScrollTop
            @$el.trigger 'scrollend'
          else if @contentScrollTop is 0
            @$el.trigger 'scrolltop'
          false

        up: (e) =>
          @isYBeingDragged = false
          @yPane.removeClass 'active'
          @doc
            .unbind(MOUSEMOVE, @yEvents[DRAG])
            .unbind(MOUSEUP, @yEvents[UP])
          false

        resize: (e) =>
          do @reset
          return

        panedown: (e) =>
          @ySliderY = (e.offsetY or e.originalEvent.layerY) - (@ySliderHeight * 0.5)
          do @scrollY
          @yEvents.down e
          false

        scroll: (e) =>
          # Don't operate if there is a dragging mechanism going on.
          # This is invoked when a user presses and moves the slider or pane
          return if @isYBeingDragged
          do @updateVerticalScrollValues
          if not @iOSNativeScrolling
            # update the slider position
            @ySliderY = @ySliderTop
            @ySlider.css top: @ySliderTop
          # the succeeding code should be ignored if @yEvents.scroll() wasn't
          # invoked by a DOM event. (refer to @reset)
          return unless e?
          # if it reaches the maximum and minimum scrolling point,
          # we dispatch an event.
          if @contentScrollTop >= @maxScrollTop
            @preventVerticalScrolling(e, DOWN) if @options.preventPageScrolling
            @$el.trigger 'scrollend'
          else if @contentScrollTop is 0
            @preventVerticalScrolling(e, UP) if @options.preventPageScrolling
            @$el.trigger 'scrolltop'
          return

        wheel: (e) =>
          return unless e?
          @ySliderY +=  -e.wheelDeltaY or -e.delta
          do @scrollY
          false

      @xEvents =
        down: (e) =>
          @isXBeingDragged  = true
          @offsetX = e.pageX - @xSlider.offset().left
          @xPane.addClass 'active'
          @doc
            .bind(MOUSEMOVE, @xEvents[DRAG])
            .bind(MOUSEUP, @xEvents[UP])
          false

        drag: (e) =>
          @xSliderX = e.pageX - @$el.offset().left - @offsetX
          do @scrollX
          do @updateHorizontalScrollValues
          if @contentScrollLeft >= @maxScrollLeft
            @$el.trigger 'scrollend'
          else if @contentScrollLeft is 0
            @$el.trigger 'scrollleft'
          false

        up: (e) =>
          @isXBeingDragged = false
          @xPane.removeClass 'active'
          @doc
            .unbind(MOUSEMOVE, @xEvents[DRAG])
            .unbind(MOUSEUP, @xEvents[UP])
          false

        resize: (e) =>
          do @reset
          return

        panedown: (e) =>
          @xSliderX = (e.offsetX or e.originalEvent.layerX) - (@xSliderWidth * 0.5)
          do @scrollX
          @xEvents.down e
          false

        scroll: (e) =>
          # Don't operate if there is a dragging mechanism going on.
          # This is invoked when a user presses and moves the slider or pane
          return if @isXBeingDragged
          do @updateHorizontalScrollValues
          if not @iOSNativeScrolling
            # update the slider position
            @xSliderX = @xSliderLeft
            @xSlider.css left: @xSliderLeft
          # the succeeding code should be ignored if @xEvents.scroll() wasn't
          # invoked by a DOM event. (refer to @reset)
          return unless e?
          # if it reaches the maximum and minimum scrolling point,
          # we dispatch an event.
          if @contentScrollLeft >= @maxScrollLeft
            @preventHorizontalScrolling(e, RIGHT) if @options.preventPageScrolling
            @$el.trigger 'scrollend'
          else if @contentScrollLeft is 0
            @preventHorizontalScrolling(e, LEFT) if @options.preventPageScrolling
            @$el.trigger 'scrollleft'
          return

        wheel: (e) =>
          return unless e?
          @xSliderX +=  -e.wheelDeltaX or -e.delta
          do @scrollX
          false

      return

    ###*
      Adds event listeners with jQuery.
      @method addEvents
      @private
    ###
    addEvents: ->
      do @removeEvents
      yEvents = @yEvents
      xEvents = @xEvents
      if not @options.disableResize
        @win
          .bind RESIZE, yEvents[RESIZE]
          .bind RESIZE, xEvents[RESIZE]
      if not @iOSNativeScrolling
        @ySlider
          .bind MOUSEDOWN, yEvents[DOWN]
        @xSlider
          .bind MOUSEDOWN, xEvents[DOWN]
        @yPane
          .bind(MOUSEDOWN, yEvents[PANEDOWN])
          .bind("#{MOUSEWHEEL} #{DOMSCROLL}", yEvents[WHEEL])
        @xPane
          .bind(MOUSEDOWN, xEvents[PANEDOWN])
          .bind("#{MOUSEWHEEL} #{DOMSCROLL}", xEvents[WHEEL])
      @$content
        .bind("#{SCROLL} #{MOUSEWHEEL} #{DOMSCROLL} #{TOUCHMOVE}", yEvents[SCROLL])
        .bind("#{SCROLL} #{MOUSEWHEEL} #{DOMSCROLL} #{TOUCHMOVE}", xEvents[SCROLL])
      return

    ###*
      Removes event listeners with jQuery.
      @method removeEvents
      @private
    ###
    removeEvents: ->
      yEvents = @yEvents
      xEvents = @xEvents
      @win
        .unbind(RESIZE, yEvents[RESIZE])
        .unbind(RESIZE, xEvents[RESIZE])
      if not @iOSNativeScrolling
        do @ySlider.unbind
        do @xSlider.unbind
        do @yPane.unbind
        do @xPane.unbind
      @$content
        .unbind("#{SCROLL} #{MOUSEWHEEL} #{DOMSCROLL} #{TOUCHMOVE}", yEvents[SCROLL])
        .unbind("#{SCROLL} #{MOUSEWHEEL} #{DOMSCROLL} #{TOUCHMOVE}", xEvents[SCROLL])
      return

    ###*
      Generates nanoScroller's scrollbar and elements for it.
      @method generate
      @chainable
      @private
    ###
    generate: ->
      # For reference:
      # http://msdn.microsoft.com/en-us/library/windows/desktop/bb787527(v=vs.85).aspx#parts_of_scroll_bar
      options = @options
      {paneClass, paneClassY, paneClassX, sliderClass, sliderClassY, sliderClassX, contentClass} = options
      if not @$el.find("#{paneClassY}").length and not @$el.find("#{sliderClassY}").length
        @$el.append """<div class="#{paneClass} #{paneClassY}"><div class="#{sliderClass} #{sliderClassY}" /></div>"""

      if not @$el.find("#{paneClassX}").length and not @$el.find("#{sliderClassX}").length
        @$el.append """<div class="#{paneClass} #{paneClassX}"><div class="#{sliderClass} #{sliderClassX}" /></div>"""

      # pane is the name for the actual scrollbar.
      @yPane = @$el.children ".#{paneClassY}"
      @xPane = @$el.children ".#{paneClassX}"

      # slider is the name for the  scrollbox or thumb of the scrollbar gadget
      @ySlider = @yPane.find ".#{sliderClassY}"
      @xSlider = @xPane.find ".#{sliderClassX}"

      if BROWSER_SCROLLBAR_WIDTH
        cssRuleY = if @$el.css('direction') is 'rtl' then left: -BROWSER_SCROLLBAR_WIDTH else right: -BROWSER_SCROLLBAR_WIDTH
        @$el.addClass 'has-scrollbar'
        @$content.css cssRuleY

      if BROWSER_SCROLLBAR_HEIGHT
        cssRuleX = bottom: -BROWSER_SCROLLBAR_HEIGHT
        @$el.addClass 'has-scrollbar'
        @$content.css cssRuleX

      this

    ###*
      @method restore
      @private
    ###
    restore: ->
      @stopped = false
      do @yPane.show
      do @xPane.show
      do @addEvents
      return

    ###*
      Resets nanoScroller's scrollbar.
      @method reset
      @chainable
      @example
          $(".nano").nanoScroller();
    ###
    reset: ->
      if @iOSNativeScrolling
        @contentHeight = @content.scrollHeight
        @contentWidth = @content.scrollWidth
        return
      @$el.removeClass 'has-scrollbar-x'
      @$el.removeClass 'has-scrollbar-y'

      @generate().stop() if not @$el.find(".#{@options.paneClassY}").length and not @$el.find(".#{@options.paneClassX}").length
      do @restore if @stopped
      content = @content
      contentStyle = content.style
      contentStyleOverflowY = contentStyle.overflowY
      contentStyleOverflowX = contentStyle.overflowX

      # try to detect IE7 and IE7 compatibility mode.
      # this sniffing is done to fix a IE7 related bug.
      if BROWSER_IS_IE7
        @$content.css
          height: do @$content.height
          width: do @$content.height

      # set the scrollbar UI's height
      # the target content
      contentHeight = content.scrollHeight + BROWSER_SCROLLBAR_WIDTH

      # set the scrollbar UI's width
      # the target content
      contentWidth = content.scrollWidth + BROWSER_SCROLLBAR_HEIGHT

      # console.log contentWidth, contentHeight, @xPane.outerWidth(), @xPane.outerWidth(true), @yPane.outerHeight(), @yPane.outerHeight(true)
      if content.scrollWidth > @xPane.outerWidth(true)
        @$el.addClass 'has-scrollbar-x'

      if content.scrollHeight > @yPane.outerHeight(true)
        @$el.addClass 'has-scrollbar-y'


      # set the y pane's height.
      paneHeight = do @yPane.outerHeight
      paneTop = parseInt @yPane.css('top'), 10
      paneBottom = parseInt @yPane.css('bottom'), 10
      paneOuterHeight = paneHeight + paneTop + paneBottom

      # set the x pane's width.
      paneWidth = do @xPane.outerWidth
      paneLeft = parseInt @xPane.css('left'), 10
      paneRight = parseInt @xPane.css('right'), 10
      paneOuterWidth = paneWidth + paneLeft + paneRight

      # set the y slider's height
      sliderHeight = Math.round paneOuterHeight / contentHeight * paneOuterHeight
      if sliderHeight < @options.sliderMinHeight
        sliderHeight = @options.sliderMinHeight # set min height
      else if @options.sliderMaxHeight? and sliderHeight > @options.sliderMaxHeight
        sliderHeight = @options.sliderMaxHeight # set max height
      sliderHeight += BROWSER_SCROLLBAR_WIDTH if contentStyleOverflowY is SCROLL and contentStyle.overflowX isnt SCROLL

      # set the x slider's width
      sliderWidth = Math.round paneOuterWidth / contentWidth * paneOuterWidth
      if sliderWidth < @options.sliderMinWidth
        sliderWidth = @options.sliderMinWidth # set min height
      else if @options.sliderMaxWidth? and sliderWidth > @options.sliderMaxWidth
        sliderWidth = @options.sliderMaxWidth # set max height
      sliderWidth += BROWSER_SCROLLBAR_HEIGHT if contentStyleOverflowX is SCROLL and contentStyle.overflowY isnt SCROLL

      # the maximum top value for the slider
      @maxSliderTop = paneOuterHeight - sliderHeight

      # the maximum left value for the slider
      @maxSliderLeft = paneOuterWidth - sliderWidth

      # set into properties for further use
      @contentHeight = contentHeight
      @contentWidth = contentWidth
      @yPaneHeight = paneHeight
      @xPaneWidth = paneWidth
      @yPaneOuterHeight = paneOuterHeight
      @xPaneOuterWidth = paneOuterWidth
      @ySliderHeight = sliderHeight
      @xSliderWidth = sliderWidth

      # set the values to the gadget
      @ySlider.height sliderHeight
      @xSlider.width sliderWidth

      # scroll sets the position of the @ySlider and @xSlider
      do @yEvents.scroll
      do @xEvents.scroll

      do @yPane.show
      @isActiveY = true
      if (content.scrollHeight is content.clientHeight) or (
          @yPane.outerHeight(true) >= content.scrollHeight and contentStyleOverflowY isnt SCROLL)
        do @yPane.hide
        @$el.removeClass 'has-scrollbar-y'
        @isActiveY = false
      else if @el.clientHeight is content.scrollHeight and contentStyleOverflowY is SCROLL
        do @ySlider.hide
      else
        do @ySlider.show

      do @xPane.show
      @isActiveX = true
      if (content.scrollWidth is content.clientWidth) or (
          @xPane.outerWidth(true) >= content.scrollWidth and contentStyleOverflowX isnt SCROLL)
        do @xPane.hide
        @$el.removeClass 'has-scrollbar-x'
        @isActiveX = false
      else if @el.clientWidth is content.scrollWidth and contentStyleOverflowX is SCROLL
        do @xSlider.hide
      else
        do @xSlider.show

      # allow the pane elements to stay visible
      @yPane.css
        opacity: (if @options.alwaysVisible then 1 else '')
        visibility: (if @options.alwaysVisible then 'visible' else '')

      @xPane.css
        opacity: (if @options.alwaysVisible then 1 else '')
        visibility: (if @options.alwaysVisible then 'visible' else '')

      this

    ###*
      @method scroll
      @private
      @example
          $(".nano").nanoScroller({ scroll: 'top' });
    ###
    scroll: ->
      @scrollY() # Just for maintain compatibility

    ###*
      @method scrollY
      @private
      @example
          $(".nano").nanoScroller({ scrollY: 'top' });
    ###
    scrollY: ->
      return unless @isActiveY
      @ySliderY = Math.max 0, @ySliderY
      @ySliderY = Math.min @maxSliderTop, @ySliderY
      @$content.scrollTop (@yPaneHeight - @contentHeight + BROWSER_SCROLLBAR_WIDTH) * @ySliderY / @maxSliderTop * -1
      if not @iOSNativeScrolling
        @ySlider.css top: @ySliderY
      this

    ###*
      @method scrollX
      @private
      @example
          $(".nano").nanoScroller({ scrollX: 'top' });
    ###
    scrollX: ->
      return unless @isActiveX
      @xSliderX = Math.max 0, @xSliderX
      @xSliderX = Math.min @maxSliderLeft, @xSliderX
      @$content.scrollLeft (@xPaneWidth - @contentWidth + BROWSER_SCROLLBAR_HEIGHT) * @xSliderX / @maxSliderLeft * -1
      if not @iOSNativeScrolling
        @xSlider.css left: @xSliderX
      this

    ###*
      Scroll at the bottom with an offset value
      @method scrollBottom
      @param offsetY {Number}
      @chainable
      @example
          $(".nano").nanoScroller({ scrollBottom: value });
    ###
    scrollBottom: (offsetY) ->
      return unless @isActiveY
      do @reset
      @$content.scrollTop(@contentHeight - @$content.height() - offsetY).trigger(MOUSEWHEEL) # Update scrollbar position by triggering one of the scroll events
      this

    ###*
      Scroll at the right with an offset value
      @method scrollRight
      @param offsetX {Number}
      @chainable
      @example
          $(".nano").nanoScroller({ scrollRight: value });
    ###
    scrollRight: (offsetX) ->
      return unless @isActiveX
      do @reset
      @$content.scrollLeft(@contentWidth - @$content.width() - offsetX).trigger(MOUSEWHEEL) # Update scrollbar position by triggering one of the scroll events
      this

    ###*
      Scroll at the top with an offset value
      @method scrollTop
      @param offsetY {Number}
      @chainable
      @example
          $(".nano").nanoScroller({ scrollTop: value });
    ###
    scrollTop: (offsetY) ->
      return unless @isActiveY
      do @reset
      @$content.scrollTop(+offsetY).trigger(MOUSEWHEEL) # Update scrollbar position by triggering one of the scroll events
      this

    ###*
      Scroll at the left with an offset value
      @method scrollLeft
      @param offsetX {Number}
      @chainable
      @example
          $(".nano").nanoScroller({ scrollLeft: value });
    ###
    scrollLeft: (offsetX) ->
      return unless @isActiveX
      do @reset
      @$content.scrollLeft(+offsetX).trigger(MOUSEWHEEL) # Update scrollbar position by triggering one of the scroll events
      this

    ###*
      Scroll to an element
      @method scrollTo
      @param node {Node} A node to scroll to.
      @chainable
      @example
          $(".nano").nanoScroller({ scrollTo: $('#a_node') });
    ###
    scrollTo: (node) ->
      return unless (@isActiveY or @isActiveX)
      do @reset
      n = $(node).get(0)
      @scrollTop n.offsetTop if @isActiveY
      @scrollLeft n.offsetLeft if @isActiveX
      this

    ###*
      To stop the operation.
      This option will tell the plugin to disable all event bindings and hide the gadget scrollbar from the UI.
      @method stop
      @chainable
      @example
          $(".nano").nanoScroller({ stop: true });
    ###
    stop: ->
      @stopped = true
      do @removeEvents
      do @yPane.hide
      do @xPane.hide
      this

    ###*
      To flash the scrollbar gadget for an amount of time defined in plugin settings (defaults to 1,5s).
      Useful if you want to show the user (e.g. on pageload) that there is more content waiting for him.
      @method flash
      @chainable
      @example
          $(".nano").nanoScroller({ flash: true });
    ###
    flash: ->
      return unless (@isActiveY or @isActiveX)
      do @reset
      @yPane.addClass 'flashed' if @isActiveY
      @xPane.addClass 'flashed' if @isActiveX
      setTimeout =>
        @yPane.removeClass 'flashed' if @isActiveY
        @xPane.removeClass 'flashed' if @isActiveX
        return
      , @options.flashDelay
      this

  $.fn.nanoScroller = (settings) ->
    @each ->
      if not scrollbar = @nanoscroller
        # For maintain compatibility
        if settings.paneClass
          settings.paneClassX = "#{settings.paneClass}-x" if not settings.paneClassX
          settings.paneClassY = "#{settings.paneClass}-y" if not settings.paneClassY
        if settings.sliderClass
          settings.sliderClassX = "#{settings.sliderClass}-x" if not settings.sliderClassX
          settings.sliderClassY = "#{settings.sliderClass}-y" if not settings.sliderClassY

        options = $.extend {}, defaults, settings
        @nanoscroller = scrollbar = new NanoScroll this, options
      
      # scrollbar settings
      if settings and typeof settings is "object"
        $.extend scrollbar.options, settings # update scrollbar settings
        return scrollbar.scrollBottom settings.scrollBottom if settings.scrollBottom
        return scrollbar.scrollTop settings.scrollTop if settings.scrollTop
        return scrollbar.scrollRight settings.scrollRight if settings.scrollRight
        return scrollbar.scrollLeft settings.scrollLeft if settings.scrollLeft
        return scrollbar.scrollTo settings.scrollTo if settings.scrollTo
        return scrollbar.scrollBottom 0 if settings.scroll is 'bottom'
        return scrollbar.scrollTop 0 if settings.scroll is 'top'
        return scrollbar.scrollRight 0 if settings.scroll is 'right'
        return scrollbar.scrollLeft 0 if settings.scroll is 'left'
        return scrollbar.scrollTo settings.scroll if settings.scroll and settings.scroll instanceof $
        return do scrollbar.stop if settings.stop
        return do scrollbar.flash if settings.flash

      do scrollbar.reset
  return

)(jQuery, window, document)
