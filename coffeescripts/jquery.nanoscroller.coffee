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

    options        = options || {}
    @target        = target

    @generateElements()
    @createEventHandlers()
    @assignListeners()
    @reset()
    return
  
  createEventHandlers: ->
    me              = this
    @handler        = []
    @handler.onDown = (e) ->
      me.offsetY 		= e.clientY - me.slider.offset().top
      $(document).bind 'mousemove', me.handler.onDrag
      $(document).bind 'mouseup', 	me.handler.onUp
      return false

    @handler.onWheel = (e) ->
      e.preventDefault()
      me.sliderY += e.wheelDeltaY || e.wheelDelta || e.detail
      me.scroll()
      e = $.event.fix e
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

    ###
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
    ###

  assignListeners: ->
    me = this
    $(window).bind 'resize', @handler.onResize
    @slider.bind 'mousedown', @handler.onDown
    @pane.bind 'mousedown', @handler.onDragPane
    @target[0].addEventListener 'DOMMouseScroll', @handler.onWheel, false
    @target[0].addEventListener 'mousewheel', @handler.onWheel, false
    #@target[0].addEventListener 'touchstart',@handler.onTouchStart
    #@target[0].addEventListener 'touchend', @handler.onTouchEnd
    return
  
  removeEventListeners: ->
    $(window).unbind 'resize', @handler.onResize
    @slider.unbind 'mousedown', @handler.onDown
    @pane.unbind 'mousedown', @handler.onDragPane
    @target[0].removeEventListener 'DOMMouseScroll', @handler.onWheel, false
    @target[0].removeEventListener 'mousewheel', @handler.onWheel, false
    #@tqrget[0].removeEventListener 'touchstart',@handler.onTouchStart
    #@target[0].removeEventListener 'touchend', @handler.onTouchEnd
    return
    
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
    @sliderY    = 0 if @sliderY < 0
    @sliderY    = @scrollHeight if @sliderY > @scrollHeight
    scrollValue = @paneHeight - @contentHeight
    scrollValue = scrollValue * @sliderY / @scrollHeight
    version     = 'old'
    #version     = 'new' if $.browser.webkit is true

    switch version
      when 'old'
        @target.addClass 'old'
        @content.scrollTop -scrollValue
        @slider.css top: @sliderY
      else
        @content.css
          '-webkit-transform': 'translateY(' + scrollValue  + 'px)'
          '-moz-transform': 'translateY(' + scrollValue  + 'px)'
          '-o-transform': 'translateY(' + scrollValue  + 'px)'
          '-transform': 'translateY(' + scrollValue  + 'px)'
        @slider.css
          '-webkit-transform': 'translateY(' + @sliderY  + 'px)'
          '-moz-transform': 'translateY(' + @sliderY  + 'px)'
          '-o-transform': 'translateY(' + @sliderY  + 'px)'
          '-transform': 'translateY(' + @sliderY  + 'px)'
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
