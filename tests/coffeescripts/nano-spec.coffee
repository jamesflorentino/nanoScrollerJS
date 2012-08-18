describe "nanoScroller", ->
  $nano = null
  $content = null
  $pane = null
  $slider = null
  height = null
  jasmine.getFixtures().fixturesPath = 'spec/fixtures'

  describe "when the plugin is called without any options and there is content", ->
    beforeEach ->
      loadFixtures('nano-content.html')
      $nano = $("#nano")
      $nano.nanoScroller()

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
      it "should exist", ->
        expect($pane).toExist()
        expect($pane.length).toBeTruthy()
        expect($nano).toContain("div.pane")
      it "should have a height of 200px", ->
        expect($pane.height()).toEqual(200)

    describe "slider element", ->
      beforeEach ->
        $slider = $nano.find('.slider')
      it "should exist", ->
        expect($slider).toExist()
        expect($slider.length).toBeTruthy()
        expect($nano).toContain("div.slider")
      it "should have style attribute set", ->
        expect($slider).toHaveAttr('style')

    describe "calling $('.nano').nanoScroller({ scroll: 'top' })", ->
      beforeEach ->
        $nano.nanoScroller({ scroll: 'top' })
        $slider = $nano.find('.slider')
      it "should have set .slider CSS 'top' value to 0px", ->
        expect($slider).toHaveCss({ top: '0px' })

    describe "calling $('.nano').nanoScroller({ scroll: 'bottom' })", ->
      beforeEach ->
        $nano.nanoScroller({ scroll: 'bottom' })
        $slider = $nano.find('.slider')
        height = $nano.find('.content').height() - $slider.height()
      it "should have set .slider CSS 'top' value to (content height - slider height)", ->
        expect($slider).toHaveCss({ top: height + 'px' })

  describe "when the plugin is called without any options and there is no content", ->
    beforeEach ->
      loadFixtures('nano-no-content.html')
      $nano = $("#nano")
      $nano.nanoScroller()

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
      it "should exist", ->
        expect($pane).toExist()
        expect($pane.length).toBeTruthy()
        expect($nano).toContain("div.pane")
      it "should have a height of 200px", ->
        expect($pane.height()).toEqual(200)
      it "should be hidden with 'display: none'", ->
        expect($pane.css('display')).toEqual('none')

    describe "slider element", ->
      beforeEach ->
        $slider = $nano.find('.slider')
      it "should exist", ->
        expect($slider).toExist()
        expect($slider.length).toBeTruthy()
        expect($nano).toContain("div.slider")
      it "should have style attribute set", ->
        expect($slider).toHaveAttr('style')

    describe "calling $('.nano').nanoScroller({ scroll: 'bottom' })", ->
      beforeEach ->
        $nano.nanoScroller({ scroll: 'bottom' })
        $slider = $nano.find('.slider')
        height = $nano.find('.content').height() - $slider.height()
      it "should not have set .slider CSS 'top' value to (content height - slider height)", ->
        expect($slider).not.toHaveCss({ top: height + 'px' })

  