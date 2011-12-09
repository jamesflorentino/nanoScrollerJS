$(function(){

  $('#main .nano').nanoScroller();

  $("#main .nano .content").load("readme.html", function(){
    $('#main .nano').nanoScroller();
  });


});

