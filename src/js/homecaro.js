// JavaScript Document
$(document).ready(function()
{
	//$('.topCaro').on('slid.bs.carousel', function () {
  		
		//var HeightToAdd = $(".topCaro").height();
		
		$(".topCaro .item:nth-child(1) img").load(function()
		{
			var HeightToAdd = $(this).height();
			$(".topCaro .item").css("min-height",HeightToAdd+"px");
			var contentCaroHeight = $(".topCaro .item").height();
			var mainContainerCaroHeight = 300;
			var differenceCaroHeight = (contentCaroHeight - mainContainerCaroHeight) / 2;
			//console.log(contentCaroHeight,mainContainerCaroHeight,differenceCaroHeight);
			
			$(".topCaro .topText").css("padding-top",differenceCaroHeight);
		});
		
		
		$(".topCaro .addasBG").each(function()
		{
			var BGtoRender = $(this).find("img").attr("src");
			$(this).css("background-image","url("+BGtoRender+")");
		});
		
		
		
		
		
	//});
		
		
		
	
});
$( window ).resize(function() {
	var HeightNewToAdd = $(".topCaro .item:nth-child(1) img").height();
	$(".topCaro .item").css("min-height",HeightNewToAdd+"px");
});
