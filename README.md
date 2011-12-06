# nanoScroller.js
[nanoScroller.js](http://jamesflorentino.com/jquery.nanoscroller) is a jQuery plugin that offers a simple way of implementing non-distracting scrollbars for your website. It also respects html markup and uses only two layers for scrolling content. It is aimed at providing scrollbar solutions for dynamic content such as from ajax's.

## Basic Usage

### Mark Up
    <div id="myContent" class="nano">
    <div class="content"> ... content here ...  </div> 
    </div>
    
`.nano` is the main container. It holds `.pane > .slider` and `.content`.

### JavaScript
    $("#myContent.nano").nanoScroller();

Update the scrollbar's content:

    $("#myContent.nano").nanoScroller({update:true});

To scroll at the bottom or top of the content:

    $("#myContent.nano").nanoScroller({scroll:'bottom'});

### Download & Instructions
- Download nanoscroller.css for the initial CSS template.
- Download jquery.nanoscroller.js plugin

#### Credits
- Written by [James Florentino](http://jamesflorentino.com)
- Released under [MIT License](http://www.opensource.org/licenses/mit-license.php)
