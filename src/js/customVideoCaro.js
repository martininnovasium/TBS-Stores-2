// JavaScript Document
$(document).ready(function()
{
	
	$('.xvideoCaro .item').each(function(){
  var next = $(this).next();
  if (!next.length) {
    next = $(this).siblings(':first');
  }
  next.children(':first-child').clone().appendTo($(this));
  
  if (next.next().length>0) {
    next.next().children(':first-child').clone().appendTo($(this));
  } else {
  	$(this).siblings(':first').children(':first-child').clone().appendTo($(this));
  }
});

$(".videoCaro .item a").each(function()
{
	$(this).prepend("<img src='/img/home/video-play-button.png' alt='video icon' class='videoIcon'/>");
});

	$(".carousel-caption").prepend("<span class=wrapNumber><span class='currentNo red'></span> / <span class='totalNo'></span></span>")//var total = carouselData.$items.length;
	//$('.totalNo').html(total);
	var currentIndex = $(this).find('.active').index() +1;
	$('.currentNo').html(currentIndex);

	var totalItems = $('.videoCaro .carousel .item').length;
	$('.totalNo').html(totalItems);


	$('.videoCaro').on('slid.bs.carousel', function () {
  		var currentIndex = $(this).find('.active').index() +1;
		var carouselData = $(".videoCaro").data('bs.carousel');
		$('.currentNo').html(currentIndex);

		});
	/** bootstrap caro numbers ends**/
});