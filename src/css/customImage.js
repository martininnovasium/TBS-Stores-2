// JavaScript Document
$(document).ready(function()
{
	
	$(".customImage img").each(function() {
		var bgImage = $(this).attr("src");
		$(this).parent().parent().css("background-image","url("+bgImage+")");
	});

	$(".customImage").each(function() {
		var findHeight = $(this).parent().parent().siblings().height();
		if (commonDebug) console.log(findHeight)
		$(this).css("height",findHeight+"px");
	});
	
	if($(window).width() < 767)
	{
		console.log("add");
		$(".customImage").each(function()
		{
			var ImageToAdd = $(this).find("img").attr("src");
			$(this).parent().parent().siblings().prepend("<img class='hideonDesk' src="+ImageToAdd+">");
		});
	}

	
});