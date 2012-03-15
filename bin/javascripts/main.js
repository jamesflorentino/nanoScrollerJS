$(function()
{
  var _options = {
    classPane: 'track',
    contentSelector: 'section.pane-content'
  };

  $('#main .nano').nanoScroller(_options);

  $("#main .nano .pane-content").load("readme.html", function(){

    $('#main .nano').nanoScroller(_options);

  });


});

