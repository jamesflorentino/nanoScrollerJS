$ = @jQuery

class NanoScroll

  constructor: (target, options) ->

    # initial properties
    @slider        = null
    @pane          = null
    @content       = null
    @scrollHeight  = 0
    @sliderHeight  = 0
    @paneHeight    = 0
    @sliderY       = 0
    @offsetY       = 0
    @contentHeight = 0
    @contentY      = 0
    @isDragging    = false

    options      or= {}
    @target        = target

    @generateElements()
    @createEventHandlers()
    @assignListeners()
    @reset()
    return
  
  createEventHandlers: ->
    @handler        = []
    @handler.onDown = (e) =>
      @isDragging = true
      @offsetY    = e.clientY - @slider.offset().top
      @pane.addClass 'active'
      $(document).bind 'mousemove', @handler.onDrag
      $(document).bind 'mouseup', 	@handler.onUp
      false

    @handler.onDrag = (e) =>
      @sliderY = e.clientY - @target.offset().top - @offsetY
      @scroll()
      false

    @handler.onUp = (e) =>
      @isDragging = false
      @pane.removeClass 'active'
      $(document).unbind 'mousemove', @handler.onDrag
      $(document).unbind 'mouseup', 	@handler.onUp
      false

    @handler.onResize = (e) =>
      @reset()
      @scroll()

    @handler.onDownPane = (e) =>
      @sliderY = e.clientY - @target.offset().top - @sliderHeight * .5
      @scroll()
      @handler.onDown e

    @handler.onScroll = (e) =>
      return if @isDragging is true
      top = @content[0].scrollTop / @content[0].scrollHeight * (@paneHeight+ 5)
      @slider.css
        top: Math.floor top

  assignListeners: ->
    $(window).bind 'resize'  , @handler.onResize
    @slider.bind 'mousedown' , @handler.onDown
    @pane.bind 'mousedown'   , @handler.onDownPane
    @content.bind 'scroll'   , @handler.onScroll
  
  removeEventListeners: ->
    $(window).unbind 'resize'  , @handler.onResize
    @slider.unbind 'mousedown' , @handler.onDown
    @pane.unbind 'mousedown'   , @handler.onDownPane
    @content.unbind 'scroll'   , @handler.onScroll

  getScrollbarWidth: ->
    outer                = document.createElement 'div'
    inner                = document.createElement 'div'
    outer.style.position = 'absolute'
    outer.style.width    = '100px'
    outer.style.height   = '10px'
    outer.style.overflow = 'hidden'
    inner.style.width    = '100%'
    inner.style.height   = '20px'

    outer.appendChild inner
    document.body.appendChild outer

    noscrollWidth        = inner.offsetWidth + 0
    outer.style.overflow = 'auto'
    yesscrollWidth       = inner.offsetWidth + 0
    document.body.removeChild outer

    noscrollWidth - yesscrollWidth

  generateElements: ->
    @target.append '<div class="pane"><div class="slider"></div></div>'
    @content = $ @target.children()[0]
    @slider  = @target.find '.slider'
    @pane    = @target.find '.pane'

    @scrollbarWidth = @getScrollbarWidth()
    @scrollbarWidth = 0 if @scrollbarWidth is 0

    @content.css
      right  : -@scrollbarWidth + 'px'

    if $.browser.msie?
      @pane.hide() if parseInt($.browser.version) < 8
    
    return

  reset: ->
    @contentHeight  = @content[0].scrollHeight
    @paneHeight     = @pane.height()
    @sliderHeight   = @paneHeight / @contentHeight * @paneHeight
    @scrollHeight   = @paneHeight - @sliderHeight
    @slider.height 	@sliderHeight
    return

  scroll: ->
    @sliderY    = 0 if @sliderY < 0
    @sliderY    = @scrollHeight if @sliderY > @scrollHeight
    scrollValue = @paneHeight - @contentHeight + @scrollbarWidth
    scrollValue = scrollValue * @sliderY / @scrollHeight
    @content.scrollTop -scrollValue
    @slider.css top: @sliderY

  scrollBottom: (offsetY) ->
    @reset()
    @sliderY = @scrollHeight
    @scroll()
    return

  scrollTop: (offsetY) ->
    @reset()
    @sliderY = 0
    @scroll()
    return

  stop: ->
    @removeEventListeners()
    @pane.hide()

$.fn.nanoScroller = (options) ->
  options or= {}
  scrollbar = @data 'scrollbar'
  if scrollbar is undefined
    scrollbar = new NanoScroll this, options
    @data 'scrollbar': scrollbar
    return
  scrollbar.reset()
  scrollbar.scrollBottom() if options.scroll is 'bottom'
  scrollbar.scrollTop() if options.scroll is 'top'
  scrollbar.stop() if options.stop is true
  false
