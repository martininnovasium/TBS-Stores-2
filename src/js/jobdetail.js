// JavaScript Document
$(document).ready(function()
{
	var articleLink;
	
	$(".jobOptions article").each(function()
	{
		articleLink = $(this).find(".article_item .article_title a").attr("href");
		$(this).find(".article_item").prepend("<div class='article_detailbtn'><a href='"+articleLink+"' class='btn'>DETAILS</a>");
	});
});