$(function(){

    $('.overthrow').nanoScroller({ contentClass: 'overthrow-content' });

  $("#main").find('.description').load("readme.html", function(){

    $('.overthrow').nanoScroller();

  });


});

