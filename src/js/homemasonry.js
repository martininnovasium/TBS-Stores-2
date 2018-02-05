// JavaScript Document
$(document).ready(function()
{
	
	$(".productmasonry .hoverWrapper").each(function()
	{
		if($(this).find(".widgetInfo").html() == "")
		{
			$(this).addClass("noInfo");
		};
	});
});