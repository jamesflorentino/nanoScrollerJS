$ = @jQuery

class NanoScroll

  constructor: (target, options) ->

    @slider   = null
    @pane     = null
    @content  = null
    @scrollH  = 0
    @sliderH  = 0
    @paneH    = 0
    @sliderY  = 0
    @offsetY  = 0
    @contentH = 0
    @contentY = 0
    @isDrag   = false

    options or= {}
    @target   = target

    @generate()
    @createEvents()
    @assignEvents()
    @reset()
    return
  
  createEvents: ->
    @handler =
      down: (e) =>
        @isDrag  = true
        @offsetY = e.clientY - @slider.offset().top
        @pane.addClass 'active'
        $(document).bind 'mousemove', @handler.drag
        $(document).bind 'mouseup', 	@handler.up
        false

      drag: (e) =>
        @sliderY = e.clientY - @target.offset().top - @offsetY
        @scroll()
        false

      up: (e) =>
        @isDrag = false
        @pane.removeClass 'active'
        $(document).unbind 'mousemove', @handler.drag
        $(document).unbind 'mouseup', 	@handler.up
        false

      resize: (e) =>
        @reset()
        @scroll()

      panedown: (e) =>
        @sliderY = e.clientY - @target.offset().top - @sliderH * .5
        @scroll()
        @handler.down e

      scroll: (e) =>
        return if @isDrag is true
        top = @content[0].scrollTop / @content[0].scrollHeight * (@paneH+ 5)
        @slider.css
          top: Math.floor top

  assignEvents: ->
    $(window).bind 'resize'  , @handler.resize
    @slider.bind 'mousedown' , @handler.down
    @pane.bind 'mousedown'   , @handler.panedown
    @content.bind 'scroll'   , @handler.scroll
  
  removeEventListeners: ->
    $(window).unbind 'resize'  , @handler.resize
    @slider.unbind 'mousedown' , @handler.down
    @pane.unbind 'mousedown'   , @handler.panedown
    @content.unbind 'scroll'   , @handler.scroll

  getScrollbarWidth: ->
    outer                = document.createElement 'div'
    outer.style.position = 'absolute'
    outer.style.width    = '100px'
    outer.style.height   = '100px'
    outer.style.overflow = 'scroll'
    document.body.appendChild outer
    noscrollWidth  = outer.offsetWidth
    yesscrollWidth = outer.scrollWidth
    document.body.removeChild outer
    noscrollWidth - yesscrollWidth

    
  generate: ->
    @target.append '<div class="pane"><div class="slider"></div></div>'
    @content = $ @target.children()[0]
    @slider  = @target.find '.slider'
    @pane    = @target.find '.pane'
    @scrollW = @getScrollbarWidth()
    @scrollW = 0 if @scrollbarWidth is 0
    @content.css
      right  : -@scrollW + 'px'

    # scumbag IE7
    if $.browser.msie?
      @pane.hide() if parseInt($.browser.version) < 8
    return

  reset: ->
    if @isDead is true
      @isDead = false
      @pane.show()
      @assignEvents()

    @contentH  = @content[0].scrollHeight
    @paneH     = @pane.height()
    @sliderH   = @paneH / @contentH * @paneH
    @scrollH   = @paneH - @sliderH
    @slider.height 	@sliderH
    return

  scroll: ->
    @sliderY    = 0 if @sliderY < 0
    @sliderY    = @scrollH if @sliderY > @scrollH
    scrollValue = @paneH - @contentH + @scrollW
    scrollValue = scrollValue * @sliderY / @scrollH
    @content.scrollTop -scrollValue
    @slider.css top: @sliderY

  scrollBottom: (offsetY) ->
    @reset()
    @sliderY = @scrollH
    @scroll()
    return

  scrollTop: (offsetY) ->
    @reset()
    @sliderY = 0
    @scroll()
    return

  stop: ->
    @isDead = true
    @removeEventListeners()
    @pane.hide()
    return

  
$.fn.nanoScroller = (options) ->
  options or= {}
  scrollbar = @data 'scrollbar'
  if scrollbar is undefined
    scrollbar = new NanoScroll this, options
    @data 'scrollbar': scrollbar
    return

  return scrollbar.scrollBottom() if options.scroll is 'bottom'
  return scrollbar.scrollTop()    if options.scroll is 'top'
  return scrollbar.stop()         if options.stop   is true
  return scrollbar.reset()
