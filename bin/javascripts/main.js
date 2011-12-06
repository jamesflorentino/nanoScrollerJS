$(function(){

  // step 1: put some initial data while we wait for the actual content to load
  $('#main .nano .content').html('<p>loading...</p>');

  // step 2: initialize the plugin
  $('#main .nano').nanoScroller();

  // step 3: fill the '.content' layer with some html texts (e.g. your ajax data) then update the scrollbar's height. 
  setTimeout(function(){
    var stubdata = $("#stub").html();
    $('#main .nano .content').html(stubdata);
    $('#main .nano').nanoScroller({update:true});
    }, 200);

  // step 4: ???
  // step 5: profit!

});

