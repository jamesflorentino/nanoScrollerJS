describe "nanoScroller (with CSS: 'width: 200px, height 200px' set to .content)", ->
  $nano = null
  $content = null
  $pane = null
  $slider = null
  jasmine.getFixtures().fixturesPath = 'spec/fixtures'
  it "should support WebkitOverflowScrolling", ->
    expect($(document.body)[0].style.WebkitOverflowScrolling).toBeDefined()
  describe "when plugin is called with options {iOSNativeScrolling: true}", ->
    beforeEach =>
      loadFixtures('nano-content.html')
      $nano = $("#nano")
      $nano.nanoScroller {iOSNativeScrolling: true}
    describe "content element", ->
      beforeEach ->
        $content = $nano.find('.content')
      it "should exist", ->
        expect($content).toExist()
        expect($content.length).toBeTruthy()
        expect($nano).toContain("div.content")
      it "should have tabindex attribute set", ->
        expect($content).toHaveAttr('tabindex')
      it "should have a height of 200px", ->
        expect($content.height()).toEqual(200)

    describe "pane element", ->
      beforeEach ->
        $pane = $nano.find('.pane')
      it "should not exist", ->
        expect($pane).not.toExist()
        expect($pane.length).not.toBeTruthy()
        expect($nano).not.toContain("div.pane")

    describe "slider element", ->
      beforeEach ->
        $slider = $nano.find('.slider')
      it "should not exist", ->
        expect($slider).not.toExist()
        expect($slider.length).not.toBeTruthy()
        expect($nano).not.toContain("div.slider")

    describe "calling $('.nano').nanoScroller({ scroll: 'bottom' })", ->
      it "should have triggered the 'scrollend' event", ->
        spyScrollend = spyOnEvent($nano, 'scrollend')
        $nano.nanoScroller({ scroll: 'bottom' })
        expect('scrollend').toHaveBeenTriggeredOn($nano)
      
    describe "calling $('.nano').nanoScroller({ scroll: 'top' })", ->
      it "should have triggered the 'scrolltop' event", ->
        spyScrolltop = spyOnEvent($nano, 'scrolltop')
        $nano.nanoScroller({ scroll: 'top' })
        expect('scrolltop').toHaveBeenTriggeredOn($nano)
