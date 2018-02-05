var commonDebug = false;

if (!window.console) window.console = {log:function(){}};

$(function() {

	/** Add tracking to all A tags */
	$("a").each(function() {
		if (!$(this).attr('data-track')) {
			$(this).attr('data-track','');
		}
	})

});

jQuery.fn.extend({
    toggleText: function (a, b){
        var isClicked = false;
        var that = this;
        this.click(function (){
            if (isClicked) { that.text(a); isClicked = false; }
            else { that.text(b); isClicked = true; }
        });
        return this;
    }
});

$(document).ready(function(){

	if (commonDebug) console.log("common.ready()");
	if (commonDebug) console.log("common.ready: myzone=["+myzone+"]");
	
	$("input[type=text], textarea").on({ 'touchstart' : function() {
		zoomDisable();
	}});
	
	$("input[type=text], textarea").on({ 'touchend' : function() {
		setTimeout(zoomEnable, 500);
	}});
	
	var loc = window.location.href;
   /** $(".navbar-nav a").each(function() {
        if (loc.indexOf($(this).attr("href")) != -1) {
            $(this).addClass("current");
        }
    });
	
	
	$("#footerlinks a").each(function() {
			if (loc.indexOf($(this).attr("href")) != -1) {
				$(this).addClass("current");
			}
    });
	**/	
	
	 if ( $(".submenu").length){
        $(".submenu a").each(function() {
			if (loc.indexOf($(this).attr("href")) != -1) {
				$(this).addClass("current");
			}
    	});
    }
	
	
	// Event Tracking
	$("*[data-track]").click(function() {
		if (commonDebug) console.log("tracking.[data-track].click()");
		var href = $(this).attr('href');
		var title = $(this).prop('title');
		var track = $(this).attr('data-track');
		if (commonDebug) console.log("tracking.[data-track]: href["+href+"] title["+title+"] track["+track+"]");
		var label = ""+href;
		if (typeof(href)=="undefined") href = "";
		if (title) label = title;
		if (track) {
			var p = track.split("|");
			trackEvent(p[0], p[1], p[2]);
		} else {
			if (href.substr(0,1)=="#") {
				if ($(this).hasClass("ui-tabs-anchor") || $(this).attr('data-toggle')=='tab') {
					trackEvent('Tab', 'Click', label);
				} else {
					trackEvent('Section', 'Click', label);
				}
			} else if (href.substr(0,1)=="/") {
				if (href.substr(-4,4).toLowerCase()==".pdf") {
					trackEvent('Internal', 'PDF', label);
				} else if (href.substr(-4,4).toLowerCase()==".zip") {
					trackEvent('Internal', 'ZIP', label);
				} else {
					if ($(this).hasClass('btn')==true) {
						trackEvent('Internal', 'Button', $(this).text());
					} else {
						trackEvent('Internal', 'Click', label);
					}
				}
			} else if (href.substr(0,4)=="http") {
				if (href.substr(-4,4).toLowerCase()==".pdf") {
					trackEvent('External', 'PDF', label);
				} else if (href.substr(-4,4).toLowerCase()==".zip") {
					trackEvent('External', 'ZIP', label);
				} else {
					trackEvent('External', 'Click', label);
				}
			}
		}
	});
	
	$(".adjustPadding").each(function() {
		var contentHeight = $(this).find(".container").height();
		var mainContainerHeight = $(this).parent().height();
		console.log(contentHeight,mainContainerHeight );
		var differenceHeight = (mainContainerHeight - contentHeight) / 2;
		var headerHeight = $("#header").height();
		//$(this).css("padding-top",differenceHeight + headerHeight);
		$(this).css("padding-top",differenceHeight + 10);
	});
	
	if($(window).width() < 1100)
	{
		
		$(".adjustPadding").each(function() {
			var contentHeight = $(this).find(".container").height();
		var mainContainerHeight = $(this).parent().height();
		console.log(contentHeight,mainContainerHeight );
		var differenceHeight = (mainContainerHeight - contentHeight) / 2;
		var headerHeight = $("#header").height();
		$(this).css("padding-top",differenceHeight + 5);
		});
	}
	
	if($(window).width() < 670)
	{
		
		$(".adjustPadding").each(function() {
			var contentHeight = $(this).find(".container").height();
		var mainContainerHeight = $(this).parent().height();
		console.log(contentHeight,mainContainerHeight );
		var differenceHeight = (mainContainerHeight - contentHeight) / 2;
		var headerHeight = $("#header").height();
		$(this).css("padding-top",differenceHeight + 2);
		});
	}
		
	
	$(".topmenuIcon img").click(function() {
		$("#mobilemenu").parent().modal();
		$("#mobilemenu").parent().addClass("in");
		return false;
	});

	$('#mobilemenu').on('hide.bs.modal', function (event) {
	  //jwplayer("ScarsinVideo").stop();
	  $(document.body).removeClass("modalBlur");
	})
	
		$("#mobilemenu .toplocation a").click(function(){
			$('#mobilemenu').parent().modal('hide'); // hide the overlay
			$('#mobilemenu').parent().addClass('loading');
			$('#mobilemenu').parent().removeClass("in");

		});
	
	try {
		var stickySidebar = $('.topMenu').offset().top + 500;
	}
	catch(err) {
		//Block of code to handle errors
	}

	$(window).scroll(function() {  
		if ($(window).scrollTop() > stickySidebar) {
			$('.topMenu').addClass('affix');
		}
		else {
			$('.topMenu').removeClass('affix');
		}  
	});
	
	//$("#header .navbar-nav > li.first").html('<a href="/"><img src="/img/home.png" alt="Home"/></a>');
	
	$(".adjustPaddingBanner").each(function() {
		var contentHeight = $(this).find(".container").height();
		var mainContainerHeight = $(this).height();
		var differenceHeight = (mainContainerHeight - contentHeight) / 2;
		var headerHeight = $("#header").height();
		$(this).css("padding-top",differenceHeight + headerHeight);
	});
	
	
	
	/** launch video modal**/
	
	if ($("#videopopup").length==0) {
		$('body').append("<div id='videopopup' class='modal fade loading'><div class='content'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>CLOSE <img src='/img/closewhite.png' alt='close'/></button><div id='sectionVideo'><iframe width='100%' height='545' src='' frameborder='0' allowfullscreen='allowfullscreen'></iframe><div class='newtext'></div></div></div></div>");
	}
	
		var setVideoPadding = $(window).height();
		var newVideoHeight =  (setVideoPadding - 350) / 2;
		
		
		if(setVideoPadding < 801)
		{
			//newVideoHeight = 200;
			newVideoHeight = 50;
		}
		
		if(setVideoPadding < 640)
		{
			newVideoHeight = 150;
		}
		
		if(setVideoPadding < 520)
		{
			newVideoHeight = 100;
		}
		
		if(setVideoPadding > 801)
		{
			newVideoHeight = newVideoHeight - 175;
		}
		
		if($(window).width() < 520)
		{
			$("#sectionVideo iframe").addClass("mobileFrame");
			}
		
		
		$("#videopopup .content").css("margin-top",newVideoHeight+"px");
	
	
	$(".videoCaro .item a").click(function()
	{
		var videosource = $(this).attr("href");
		$("#sectionVideo iframe").attr("src",videosource+"&autoplay");
		//$("#ScarsinVideo iframe").attr("autostart","true");
		$("#videopopup").modal();
		$("#videopopup").addClass("in");
		return false;
		


	});
	
	
	$(".launchVideo").click(function()
	{
		var videosource = $(this).attr("href");
		$("#sectionVideo iframe").attr("src",videosource+"&autoplay");
		//$("#ScarsinVideo iframe").attr("autostart","true");
		$("#videopopup").modal();
		$("#videopopup").addClass("in");
		return false;
		


	});
	
	$('#videopopup').on('hide.bs.modal', function (event) {
	  //jwplayer("ScarsinVideo").stop();
	  $("#sectionVideo iframe").attr("src","");
	  $(document.body).removeClass("modalBlur");
	})
	
	
	$(".faq .panel-heading a").click(function() {
		$(this).parent().toggleClass("active");
		$(this).parent().parent().parent().siblings().find(".panel-title").removeClass("active");
	});
	
	/** old browser handler **/
	if (typeof(browserdetect)!="undefined") {
		if (browserdetect.name=='MSIE' && browserdetect.version <= 9) {
			$('body').prepend("<div id='upgrade'>Your web browser is old. Please <a href='http://outdatedbrowser.com' target='_blank'>upgrade</a> to the latest version.</div>");
		}
	}
	
	/** ajax handler **/
	$('.ajax').each(function(){
		var u = $(this).attr('data-url');
		var c = $(this).attr('data-callback');
		if (commonDebug) console.log("common.ready.ajax(): u=["+u+"]");
		var obj = $(this);
		if (u) {
			$(this).addClass('loading');
			$.ajax({
				cache: false,
				url: u,
				type: 'get'
			}).done(function(data) {
				obj.removeClass('loading').html(data);
				if (c) window[c]();
			}).fail(function(jqXHR, textStatus, errorThrown) {
				obj.removeClass('loading').html("Error: " + jqXHR.statusText);
			});
		}
	});

});

var trackEvent_eventid = 0;
var trackEvent_sessionid = 0;
var trackEvent_guid = '';
var trackEvent_queue = trackEvent_queue || [];

function trackEvent(category, action, label, value, meta, name, session_id, event_id, guid, callback) {
	if (commonDebug) console.log("tracking.trackEvent()",arguments);
	trackEvent_queue.push(arguments);
	if (trackEvent_queue.length==1) trackEventItem(); // Start queue
}

function trackEventItem(category, action, label, value, meta, name, session_id, event_id, guid, callback) {
	if (commonDebug) console.log("tracking.trackEventItem()",arguments);
	var	data = "";
	var	trackData = {"track":"", "meta":""};
	
	category = category || '';
	action = action || '';
	label = label || '';
	value = value || '';
	
	try {

		if (commonDebug) console.log("tracking.trackEventItem: trackEvent_queue.length=",trackEvent_queue.length);

		if (trackEvent_queue.length>0) {

			if (commonDebug) console.log("tracking.trackEventItem: trackEvent_queue[0].length=",trackEvent_queue[0].length,trackEvent_queue[0]);

			if (trackEvent_queue[0].length>0) category = trackEvent_queue[0][0];
			if (trackEvent_queue[0].length>1) action = trackEvent_queue[0][1];
			if (trackEvent_queue[0].length>2) label = trackEvent_queue[0][2];
			if (trackEvent_queue[0].length>3) value = trackEvent_queue[0][3];
			if (trackEvent_queue[0].length>4) meta = trackEvent_queue[0][4];
			if (trackEvent_queue[0].length>5) name = trackEvent_queue[0][5];
			if (trackEvent_queue[0].length>6) session_id = trackEvent_queue[0][6];
			if (trackEvent_queue[0].length>7) event_id = trackEvent_queue[0][7];
			if (trackEvent_queue[0].length>8) guid = trackEvent_queue[0][8];
			if (trackEvent_queue[0].length>9) callback = trackEvent_queue[0][9];
			trackEvent_queue.shift();
		}

		category = $.trim(category);
		action = $.trim(action);
		name = $.trim(name);
		label = $.trim(label);
		value = parseInt("0"+value.replace(/[^\d]/g,''));
		session_id = parseInt(session_id);
		event_id = parseInt(event_id);
		guid = $.trim(guid);

		if (typeof(label)!="string" && typeof(label)!="undefined") {
			var t = "";
			for(var i in label) {
				if (typeof(label[i])!="undefined") t += i+"=["+label[i]+"],";
			}
			label=t.replace(/,$/,'');
		}

		if (typeof(label)=="undefined") label = "";
		if (typeof(gaUserID)!="undefined" && gaUserID!='') action = "["+gaUserID+"]:" + action

		// Google Analytics
		if (typeof(ga)  !="undefined") ga('send', 'event', category, action, label, value);
		if (typeof(_gaq)!="undefined") _gaq.push(['_trackEvent', category, action, label, value]);
		
	} catch(e) {
		if (commonDebug) console.log("tracking.trackEventItem.done: catch=",e);
	}

	return trackData;
}


function zoomDisable(){
  $('head meta[name=viewport]').remove();
  $('head').prepend('<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0" />');
}
function zoomEnable(){
  $('head meta[name=viewport]').remove();
  $('head').prepend('<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=1" />');
} 
