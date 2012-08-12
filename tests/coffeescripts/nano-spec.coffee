describe "nanoScroller", ->
  $nano = null
  $content = null
  $pane = null
  $slider = null
  jasmine.getFixtures().fixturesPath = 'spec/fixtures'
  describe "when the plugin is called without any options", ->
    beforeEach ->
      loadFixtures('nano.html')
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

    describe "pane element", ->
      beforeEach ->
        $pane = $nano.find('.pane')
      it "should exist", ->
        expect($pane).toExist()
        expect($pane.length).toBeTruthy()
        expect($nano).toContain("div.pane")


    describe "slider element", ->
      beforeEach ->
        $slider = $nano.find('.slider')
      it "should exist", ->
        expect($slider).toExist()
        expect($slider.length).toBeTruthy()
        expect($nano).toContain("div.slider")
      it "should have style attribute set", ->
        expect($slider).toHaveAttr('style')


  