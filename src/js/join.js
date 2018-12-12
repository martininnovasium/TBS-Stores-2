// V1

var joinDebug = false;
var joinURL = "//join.tbsstores.net/";

if (!window.console) window.console = {log:function(){}};

$(function() {
});

$(document).ready(function(){
	if (joinDebug) {console.log("join.ready()");}
	
	$(".emailClub .btn").click(function() {
		if (joinDebug) console.log("promotion.ready: .emailClub .btn.click()");
	});
	
	joinAjax(location.search.replace("?",""));
	
});

function initForm(){
	if (joinDebug) {console.log("join.initForm()");}
	
	$("#joinform").find('form').submit(function(event){
		event.preventDefault();
		if (joinDebug) {console.log("join.initForm.submit()");}
		var data = $(this).serialize();
		if (joinDebug) {console.log("join.initForm.submit: data=",data);}
		joinAjax(data);
	});
};

function joinAjax(data){
	if (joinDebug) {console.log("join.joinAjax()",data);}
	
	var joinObj = $("#joinform");
    
    if (joinObj.attr("data-join")) {
        joinURL = joinObj.attr("data-join");
    }
	if (joinDebug) {console.log("join.joinAjax: joinURL=",joinURL);}
    
	joinObj.addClass('loading');

	$.ajax({
		url: joinURL,
		data: data,
		dataType: 'html',
		type: "get"
	})
	.done(function(data) {
		if (joinDebug) {console.log("join.joinAjax.done: data=",data);}
		joinObj.html(data).removeClass('loading');
		initForm();
	})
	.fail(function(jqXHR, textStatus) {
		if (joinDebug) {console.log("join.joinAjax.error:",jqXHR, textStatus);}
		alert("Request failed: " + textStatus);
		joinObj.removeClass('loading');
	});	

}