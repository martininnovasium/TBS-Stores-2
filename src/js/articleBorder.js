// JavaScript Document
$(document).ready(function()
{
	
	$(".productList.edsb article:nth-child(4n+1)").addClass("addBorder");
});

$(window).resize(function()
{
	if ($(window).width() < 1001)
	{
		
		$(".productList.edsb article:nth-child(2n+1)").addClass("addBorder");
	}
	
	if ($(window).width() > 1000)
	{
		
		$(".productList.edsb article:nth-child(2n+1)").removeClass("addBorder");
		$(".productList.edsb article:nth-child(4n+1)").addClass("addBorder");
	}
})