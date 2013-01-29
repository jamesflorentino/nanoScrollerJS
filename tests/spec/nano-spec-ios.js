
describe("nanoScroller (with CSS: 'width: 200px, height 200px' set to .content)", function() {
  var $content, $nano, $pane, $slider;
  $nano = null;
  $content = null;
  $pane = null;
  $slider = null;
  jasmine.getFixtures().fixturesPath = 'spec/fixtures';
  it("should support WebkitOverflowScrolling", function() {
    return expect($(document.body)[0].style.WebkitOverflowScrolling).toBeDefined();
  });
  return describe("when plugin is called with options {iOSNativeScrolling: true}", function() {
    var _this = this;
    beforeEach(function() {
      loadFixtures('nano-content.html');
      $nano = $("#nano");
      return $nano.nanoScroller({
        iOSNativeScrolling: true
      });
    });
    describe("content element", function() {
      beforeEach(function() {
        return $content = $nano.find('.content');
      });
      it("should exist", function() {
        expect($content).toExist();
        expect($content.length).toBeTruthy();
        return expect($nano).toContain("div.content");
      });
      it("should have tabindex attribute set", function() {
        return expect($content).toHaveAttr('tabindex');
      });
      return it("should have a height of 200px", function() {
        return expect($content.height()).toEqual(200);
      });
    });
    describe("pane element", function() {
      beforeEach(function() {
        return $pane = $nano.find('.pane');
      });
      return it("should not exist", function() {
        expect($pane).not.toExist();
        expect($pane.length).not.toBeTruthy();
        return expect($nano).not.toContain("div.pane");
      });
    });
    describe("slider element", function() {
      beforeEach(function() {
        return $slider = $nano.find('.slider');
      });
      return it("should not exist", function() {
        expect($slider).not.toExist();
        expect($slider.length).not.toBeTruthy();
        return expect($nano).not.toContain("div.slider");
      });
    });
    describe("calling $('.nano').nanoScroller({ scroll: 'bottom' })", function() {
      return it("should have triggered the 'scrollend' event", function() {
        var spyScrollend;
        spyScrollend = spyOnEvent($nano, 'scrollend');
        $nano.nanoScroller({
          scroll: 'bottom'
        });
        return expect('scrollend').toHaveBeenTriggeredOn($nano);
      });
    });
    return describe("calling $('.nano').nanoScroller({ scroll: 'top' })", function() {
      return it("should have triggered the 'scrolltop' event", function() {
        var spyScrolltop;
        spyScrolltop = spyOnEvent($nano, 'scrolltop');
        $nano.nanoScroller({
          scroll: 'top'
        });
        return expect('scrolltop').toHaveBeenTriggeredOn($nano);
      });
    });
  });
});
