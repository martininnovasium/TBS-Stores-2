// JavaScript Document
$(document).ready(function()
{
	var newBG = $(".featuredTownBG").find("img").attr("src");
	$(".featuredTownBG").css("background-image","url("+newBG+")");
	
});