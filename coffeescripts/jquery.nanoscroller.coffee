$ = @jQuery

class NanoScroll
  slider: 				null
  pane: 					null
  content: 				null
  scrollHeight: 	0
  sliderHeight: 	0
  paneHeight: 		0
  sliderY: 				0
  offsetY: 				0
  contentHeight: 	0
  contentY: 			0

  constructor: (target, options) ->
    options     = options || {}
    @target     = target
    @generateElements()
    @createEventHandlers()
    @assignListeners()
    @reset()
    return
  
  createEventHandlers: ->
    me          = this
    @handler    = []
    @handler.onDown = (e) ->
      me.offsetY 		= e.clientY - me.slider.offset().top
      $(document).bind 'mousemove', me.handler.onDrag
      $(document).bind 'mouseup', 	me.handler.onUp
      return false

    @handler.onWheel = (e) ->
      me.sliderY += e.wheelDeltaY * -.5 || e.wheelDelta || e.detail
      me.scroll()
      e = $.event.fix e
      e.preventDefault()
      return false

    @handler.onDrag 	= (e) ->
      me.sliderY  	= e.clientY - me.target.offset().top - me.offsetY
      me.scroll()
      return false

    @handler.onUp 		= (e) ->
      $(document).unbind 'mousemove', me.handler.onDrag
      $(document).unbind 'mouseup', 	me.handler.onUp
      return false

    @handler.onResize = (e) ->
      me.reset()
      me.scroll()

    @handler.onDragPane = (e) ->
      me.sliderY  	= e.clientY - me.target.offset().top - me.sliderHeight * .5
      me.scroll()
      me.handler.onDown e


  assignListeners: ->
    @slider.bind 'mousedown', @handler.onDown
    @pane.bind 'mousedown', @handler.onDragPane
    $(window).bind 'resize', @handler.onResize
    @content[0].addEventListener 'DOMMouseScroll', @handler.onWheel, false
    @content[0].addEventListener 'mousewheel', @handler.onWheel, false
    return
  
  removeEventListeners: ->
    @slider.unbind 'mousedown', @handler.onDown
    $(window).unbind 'resize', @handler.onResize
    @content[0].removeEventListener 'DOMMouseScroll', @handler.onWheel, false
    @content[0].removeEventListener 'mousewheel', @handler.onWheel, false
    
  generateElements: ->
    @target.append '<div class="pane"><div class="slider"></div></div>'
    @content = $ @target.children()[0]
    @slider	= @target.find '.slider'
    @pane = @target.find '.pane'
    return

  reset: ->
    @contentHeight = @content[0].scrollHeight
    @paneHeight = @pane.innerHeight()
    @sliderHeight = @paneHeight / @contentHeight
    @sliderHeight *= @paneHeight
    @scrollHeight = @paneHeight - @sliderHeight
    @slider.height 	@sliderHeight
    return

  scroll: ->
    @sliderY = 0 if @sliderY < 0
    @sliderY = @scrollHeight if @sliderY > @scrollHeight
    scrollValue = @paneHeight - @contentHeight
    scrollValue = scrollValue * @sliderY / @scrollHeight
    @content.scrollTop -scrollValue
    @slider.css top: @sliderY
    return

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

  
$.fn.nanoScroller = (options) ->
  options = options || {}
  scrollbar = @data 'scrollbar'
  if scrollbar is undefined
    scrollbar = new NanoScroll this, options
    @data 'scrollbar': scrollbar
    return
  scrollbar.reset() if options.update is true
  scrollbar.scrollBottom() if options.scroll is 'bottom'
  scrollbar.scrollTop() if options.scroll is 'top'
  scrollbar.stop() if options.stop is true
  return false
