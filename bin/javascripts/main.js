$(function(){

  $('.nano').nanoScroller({
    preventPageScrolling: true
  });
  $("#main").find('.description').load("readme.html", function(){
    setTimeout(function() {
        $(".nano").nanoScroller();
    }, 100);
  });


});

