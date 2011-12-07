# nanoScroller.js
[nanoScroller.js](http://jamesflorentino.com/jquery.nanoscroller) is a jQuery plugin that offers a simple way of implementing non-distracting scrollbars for your website. It also respects html markup and uses only two layers for scrolling content. The other scrollbar div elements `.pane` and `.slider` are added during run time to prevent clutter in templating. It is aimed at providing scrollbar solutions for dynamic content such as from ajax's.

To start using, you to do three basic things:

### Mark Up
    <div id="about" class="nano">
     <div class="content"> ... content here ...  </div> 
    </div>

Copy the HTML mark-up. You may change `#about` if you want. In fact, you can remove that attribute as long as you have a parent div with an ID reference. e.g. `#parent .nano'

### JavaScript
    $("#about.nano").nanoScroller();

### Additional Method

To scroll at the top

    $("#about.nano").nanoScroller({update:true});

To scroll at the bottom

    $("#about.nano").nanoScroller({scroll:'bottom'});

To stop the operation

    #("#about.nano").nanoScroller({stop: true});

Refresh the scrollbar

    #("#about.nano").nanoScroller();

### Features
- Currently works in IE8+, FireFox, Chrome, Safari
- For IE7 and below, it will fallback to the native scrollbar gadget of the OS.
- Works with popular multi-touch mobile and tablet devices. But still not error free.
- The current version v.02 weighs 3.65KB. I have yet to optimize the code. If you write CoffeeScript, feel free to Fork the project.

#### Credits
- Written by [James Florentino](http://jamesflorentino.com)
- Released under [MIT License](http://www.opensource.org/licenses/mit-license.php)
