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

    options        = options || {}
    @target        = target

    @generateElements()
    @createEventHandlers()
    @assignListeners()
    @reset()
    return
  
  createEventHandlers: ->
    me              = this
    @handler        =
      onDown: (e) ->
        me.isDragging = true
        me.offsetY 		= e.clientY - me.slider.offset().top
        me.pane.addClass 'active'
        $(document).bind 'mousemove', me.handler.onDrag
        $(document).bind 'mouseup', 	me.handler.onUp
        return false

      onDrag: (e) ->
        me.sliderY = e.clientY - me.target.offset().top - me.offsetY
        me.scroll()
        return false

      onUp: (e) ->
        me.isDragging = false
        me.pane.removeClass 'active'
        $(document).unbind 'mousemove', me.handler.onDrag
        $(document).unbind 'mouseup', 	me.handler.onUp
        return false

      onResize: (e) ->
        me.reset()
        me.scroll()

      onDownPane: (e) ->
        me.sliderY = e.clientY - me.target.offset().top - me.sliderHeight * .5
        me.scroll()
        me.handler.onDown e

      onScroll: (e) ->
        return if me.isDragging is true
        top = me.content[0].scrollTop / me.content[0].scrollHeight * (me.paneHeight+ 5)
        me.slider.css
          top: Math.floor top

  assignListeners: ->
    console.log 'assign listeners'
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
    outer.style.position = 'absolute'
    outer.style.width    = '100px'
    outer.style.height   = '100px'
    outer.style.overflow = 'scroll'
    document.body.appendChild outer

    noscrollWidth  = outer.offsetWidth
    yesscrollWidth = outer.scrollWidth

    document.body.removeChild outer

    return noscrollWidth - yesscrollWidth

    
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
    if @isStopped is true
      @isStopped = false
      @pane.show()
      @assignListeners()


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
    @isStopped = true
    @removeEventListeners()
    @pane.hide()

  
$.fn.nanoScroller = (options) ->
  options = options || {}
  scrollbar = @data 'scrollbar'
  if scrollbar is undefined
    scrollbar = new NanoScroll this, options
    @data 'scrollbar': scrollbar
    return
  scrollbar.reset()
  scrollbar.scrollBottom() if options.scroll is 'bottom'
  scrollbar.scrollTop() if options.scroll is 'top'
  scrollbar.stop() if options.stop is true
  return false
