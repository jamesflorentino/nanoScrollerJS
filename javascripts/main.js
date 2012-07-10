$(function(){

  $('.nano').nanoScroller({
    preventPageScrolling: true,
    contentClass: 'content_new'
  });
  $("#main").find('.description').load("readme.html", function(){
    $(".nano").nanoScroller();
  });


});

