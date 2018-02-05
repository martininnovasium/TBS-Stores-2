var promotionDebug = true;

if (!window.console) window.console = {log:function(){}};

$(document).ready(function(){
	if (promotionDebug) console.log("promotion.ready()");

	$(".emailClub .btn").click(function() {
		if (promotionDebug) console.log("promotion.ready: .emailClub .btn.click()");
	});
	
});
