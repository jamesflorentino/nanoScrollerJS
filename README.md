# nanoScroller.js
[nanoScroller.js](http://jamesflorentino.com/jquery.nanoscroller) is a jQuery plugin that offers a simplistic way of implementing Mac OS X Lion-styled scrollbars for your website.
It uses minimal HTML markup being `.nano > .content`. The other scrollbar div elements `.pane > .slider` are added during run time to prevent clutter in templating. The latest version utilizes native scrolling and works with the iPad, iPhone, and some Android Tablets.

Please visit the [downloads](https://github.com/jamesflorentino/nanoScrollerJS/downloads) section to get the js and css template file (.zip).

To start using, you to do three basic things:

### 1. Markup

The following type of markup structure is needed to make the plugin work:

    <div id="about" class="nano">
     <div class="content"> ... content here ...  </div> 
    </div>

Copy the HTML markup. Change `#about` into something related to your content. Though you can also remove that attribute as long as you have a parent div with an ID reference. e.g. `#parent > .nano`. `nano` and `content` classnames can be customized via plugin options (_in that case you must rename them inside the plugin's CSS file as well_).

### 2. CSS

Link to the `nanoscroller.css` file inside your page's `<head>` section (...or copy the contents from it to your page's main stylesheet file).

    <link rel="stylesheet" href="nanoscroller.css"> 

You should specify a width and a height to your container, and apply some custom styling for your scrollbar. Here's an example:

    .nano { background: #bba; width: 500px; height: 500px; }
    .nano .content { padding: 10px; }
    .nano .pane   { background: #888; }
    .nano .slider { background: #111; }

### 3. JavaScript

    $("#about").nanoScroller();

### Plugin Options

There are a few options that you can change when running nanoScroller, e.g. `$("#about").nanoScroller({ paneClass: 'myclass' });`

#### iOSNativeScrolling

Set to true if you want to use native scrolling in iOS 5+. This will disable your custom nanoScroller scrollbar in iOS 5+ and use the native one instead. While the native iOS scrollbar usually works much better, [there could possibly be bugs](http://jquerymobile.com/test/docs/pages/touchoverflow.html) in certain situations.

__Default:__ false

#### paneClass

A classname for scrollbar track element. If you change this setting, you also have to change it in the plugin's CSS file.

__Default:__ 'pane'

#### sliderClass

A classname for scrollbar thumb element. If you change this setting, you also have to change it in the plugin's CSS file.

__Default:__ 'slider'

#### contentClass

A classname for your content div. If you change this setting, you also have to change it in the plugin's CSS file.

__Default:__ 'content'

#### sliderMinHeight

Sets the minimum height of the slider element.

__Default:__ 20

### Additional Methods


#### scroll:

To scroll at the top:

    $("#about").nanoScroller({ scroll: 'top' });

To scroll at the bottom:

    $("#about").nanoScroller({ scroll: 'bottom' });

To scroll to an element:

    $("#about").nanoScroller({ scroll: $('#a_node') });


#### stop:

To stop the operation:

    $("#about").nanoScroller({ stop: true });


#### nanoScroller();    

Refresh the scrollbar:

    $("#about").nanoScroller();


### Advanced methods

To scroll at the top with an offset value:

    $("#about").nanoScroller({ scrollTop: value });

To scroll at the bottom with an offset value:

    $("#about").nanoScroller({ scrollBottom: value });

To scroll to an element:

    $("#about").nanoScroller({ scrollTo: $('#a_node') });

### Custom events

#### 'scrollend'

A custom 'scrollend' event is triggered on the element every time the user has scrolled to the end of the content. Some browsers trigger this event more than once each time, so to listen to the custom event, instead of using jQuery's normal `.bind` or `.on`, you most likely want to use [this tiny jQuery debounce plugin](https://github.com/diaspora/jquery-debounce) to prevent browsers from firing your function more than once every 100ms.

    $("#about").debounce("scrollend", function() {
      alert("The end");
    }, 100);

### Development

To build nanoScroller from source you need the following libraries installed:

* Node.js and npm: [homepage / download](http://nodejs.org/)
* Coffeescript: [homepage](http://coffeescript.org/) | `npm install -g coffee-script`

To allow the build process to convert the README file to HTML you also need:

* Ruby (pre-installed in OS X): [homepage](http://www.ruby-lang.org/en/) | [download](http://www.ruby-lang.org/en/downloads/)
* GCC: [homepage](http://gcc.gnu.org/) | [download for OS X](https://github.com/kennethreitz/osx-gcc-installer)
* Redcarpet: [homepage](https://github.com/tanoku/redcarpet) | `gem install redcarpet` (add `sudo` if needed)

#### How to build & contribute

1. Make all JS changes in Coffeescript file(s), CSS changes in CSS file(s).
2. In terminal move to nanoscroller folder and run `cake build`
3. Make sure that all changes are valid and open a pull request.

### Browser compatibility

__Tested desktop browsers:__

* IE7+
* Firefox 3+
* Chrome
* Safari 4+
* Opera 11.60+

__Mobile support:__

* iOS 5+ (iPhone, iPad and iPod Touch)
* iOS 4 (_with a polyfill_)
* Android Firefox
* Android 2.2/2.3 native browser (_with a polyfill_)
* Android Opera 11.6 (_with a polyfill_)
* If you see it's broken on other tablets and mobile devices, please file a ticket in the git repo. Along with model name, and OS of the device.

If you find a bug, please report here at the [issues section](https://github.com/jamesflorentino/nanoScrollerJS/issues).

### Using a polyfill for better mobile browser support

You can use [overthrow.js](https://github.com/filamentgroup/Overthrow/) polyfill (~1.5kb minified and gzipped) to make nanoScoller work on many mobile devices. It emulates CSS overflow (overflow: auto;/overflow: scroll;) in devices that are lacking it.

To use overthrow, link to the javascript file in your HTML document...

    <script src="overthrow.js"></script>


...and add an `overthrow` class to your `content` div. 

    <div id="about" class="nano">
     <div class="overthrow content"> ... content here ...  </div> 
    </div>

### Contributors
- @jamesflorentino
- @kristerkari

### From the author
I wrote this plugin out of necessity for a JavaScript project with designers and front-end developers in mind. Please also note that I will not be liable to fix your problem just in case you plan to use this commercially and some unforseen event arises. However, I will do what I can to immediately patch a solution.

### Credits
- Initially written by [James Florentino](http://jamesflorentino.com) in [CoffeeScript](http://coffeescript.org)
- Released under [MIT License](http://www.opensource.org/licenses/mit-license.php)
- If you write CoffeeScript and you wish to improve the code, please feel free to fork the project.
