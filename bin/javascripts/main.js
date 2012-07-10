$(function(){

  $('.nano').nanoScroller({
    preventPageScrolling: true
  });
  $("#main").find('.description').load("readme.html", function(){
    $(".nano").nanoScroller();
  });


});

