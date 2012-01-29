$(function(){

  $('.nano').nanoScroller();

  $("#main .content.description").load("readme.html", function(){

    $('.nano').nanoScroller();

  });


});

