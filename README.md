# nanoScroller.js
[nanoScroller.js](http://jamesflorentino.com/jquery.nanoscroller) is a jQuery plugin that offers a simplistic way of implementing Lion-styled scrollbars for your website.
It uses minimal HTML markup being `.nano > .content`. The other scrollbar div elements `.pane > .slider` are added during run time to prevent clutter in templating. The latest version utilizes native scrolling and works with the iPad, iPhone, and some Android Tablets.

Please visit the [downloads](https://github.com/jamesflorentino/nanoScrollerJS/downloads) section to get the js and css template file (.zip).

To start using, you to do three basic things:

### 1. Mark Up

    <div id="about" class="nano">
     <div class="content"> ... content here ...  </div> 
    </div>

Copy the HTML mark-up. Change `#about` into something related to your content. Though you can also remove that attribute as long as you have a parent div with an ID reference. e.g. `#parent > .nano`

### 2. CSS

    @import url('nanoscroller.css');
    .nano .content      { padding: 10px; }
    .nano .pane         { background: #444; }
    .nano .pane .slider { background: #111; }

### 3. JavaScript

    $("#about.nano").nanoScroller();

### Additional Methods

To scroll at the top

    $("#about.nano").nanoScroller({scroll:'top'});

To scroll at the bottom

    $("#about.nano").nanoScroller({scroll:'bottom'});

To stop the operation

    $("#about.nano").nanoScroller({stop: true});

Refresh the scrollbar

    $("#about.nano").nanoScroller();


### Advanced methods

To scroll at the top with an offset value:

    $("#about.nano").nanoScroller({scrollTop:value});

To scroll at the bottom with an offset value:

    $("#about.nano").nanoScroller({scrollBottom:value});

### Features
- Currently works in IE8+, FireFox, Chrome, Safari. But I haven't fully tested in all versions. If you find a bug, please report here at the [issues section](https://github.com/jamesflorentino/nanoScrollerJS/issues)
- For IE7 and below, it will fallback to the native scrollbar gadget of the OS.
- It currently works with iOS5 (iPhone, iPad and iPod Touch). If you see it's broken on other tablets and mobile devices, please file a ticket in the git repo. Along with model name, and OS of the device.

### From the author
I wrote this plugin out of necessity for a JavaScript project with designers and front-end developers in mind. Please also note that I will not be liable to fix your problem just in case you plan to use this commercially and some unforseen event arises. However, I will do what I can to immediately patch a solution.

### Credits
- Initially written by [James Florentino](http://jamesflorentino.com) in [CoffeeScript](http://coffeescript.org)
- Released under [MIT License](http://www.opensource.org/licenses/mit-license.php)
- If you write CoffeeScript and you wish to improve the code, please feel free to fork the project.
