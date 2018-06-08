var locationDebug = true;
var locationURL = "/ajax_location.cfm";
var locationSelector = ".locationControl form";
var locationObjects = [];
var locationAutoComplete = [];
var locationGoogleKey = "AIzaSyD-SYRkxw2OZuVeTBmHIMlecVV41ZJEOq0";

var mystore = {};

$(function() {
	$(locationSelector).submit(function(){
		if (locationDebug) {console.log("location.form.submit()");}
		var i = $(this).find("input[name=article_location_search]").attr("data-location-i");
		//findStore(i);
		return false;
	});
	$("input[name=article_location_search]").keydown(function(e){
        if (locationDebug) {console.log("location.input.keydown()");}
        var keyCode = e.keyCode || e.which;
        if (locationDebug) {console.log("location.input.keydown: keyCode=["+keyCode+"]");}
        if (keyCode === 13) { 
            e.preventDefault();
            //$(this).trigger('focus');
            return false;
        }        
    });
});

$(document).ready(function(){
	if (locationDebug) {console.log("location.ready()");}
	if (locationDebug) {console.log("location.ready: google=["+typeof(google)+"]");}
	
	$("a.changelocation").click(function(event){
		if (locationDebug) console.log("location.ready: changelocation.click()");
		locationWindow(true,'change');
		event.stopImmediatePropagation();
		event.stopPropagation();
		return false;
	})

	locationInit();
	/*
	if (storeHasCookies() && mystore['store_id'] < 0) {
		locationWindow(true,'check');
	}
	*/
	
});

function locationInit(){
	if (locationDebug) console.log("location.locationInit()",arguments);

	locationObjects = $(locationSelector);
	
	locationObjects.each(function(ii){
		$(this).find("input[name=article_location_search]").attr("data-location-i",ii);
	});
	
	if (locationObjects.length>0){
		if (typeof(google)=="undefined") {
			var sg=document.createElement('script');sg.type='text/javascript';sg.async=true;
			var b=('htt'+'ps:'==document.location.protocol?'htt'+'ps://':'htt'+'p://');sg.src="https://maps.googleapis.com/maps/api/js?key="+locationGoogleKey+"&libraries=places&callback=locationAutoCompleteInit";
			var s=document.getElementsByTagName('script')[0];s.parentNode.insertBefore(sg,s);
		} else {
			locationAutoCompleteInit();
		}
	}
	
	//var defaultinput = "Enter your postal code or city";
	var defaultinput = "";
	$("#location-change input").val(defaultinput).css("color","#888888");

	$("#location-close").click(function(event){
		if (locationDebug) console.log("location.ready: #location-close.click()");
		trackEvent('Location', 'Click', 'Change');
		locationWindow(false,'');
		event.stopImmediatePropagation();
		event.stopPropagation();
		return false;
	});
	
	locationAjax('check',{});
	
}

function locationAjax(action,data){
	if (locationDebug) {console.log("location.locationAjax()");}
	
	data.action = action;
	
	$.ajax({
		url: locationURL,
		data: data,
		dataType: 'json',
		type: "POST",
		success: function(data, textStatus, XMLHttpRequest){
			if (locationDebug) console.log("locationAjax: ajax",data);
			if (data.status==1) {
				mystore = data.mystore;
				if (mystore.id>0) {
					$('.changelocation span').text(mystore.title);
					$("#location-change .current a").attr('href',mystore.url).text(mystore.title);
					$("#location-change .current").show();
				} else if (mystore.id==0) {
					if (locationDebug) console.log("location.locationAjax: ajax: location not set");
					//locationWindow(true,'change');
					locationWindow(true,'check');
				}
				$('.toplocation').show();
                
                if (typeof(mystore['prov'])!="undefined") {
if (locationDebug) console.log("location.locationAjax: prov=["+mystore['prov']+"]");
                    if (mystore['prov'] == "BC")
                        {
                            $(".provIncludeBC").parent().parent().addClass("showthis");
                            $(".provExcludeBC").parent().parent().addClass("hidethis");
                        }
                        else
                        {
                            $(".provIncludeBC").parent().parent().addClass("hidethis");
                            $(".provExcludeBC").show().parent().parent().addClass("showthis");
                        }
                    if(mystore['prov'] == "AB")
                        {
                            $(".provIncludeAB").parent().parent().addClass("showthis");
                            $(".provExcludeAB").parent().parent().addClass("hidethis");
                        }
                        else
                        {
                            $(".provIncludeAB").parent().parent().addClass("hidethis");
                            $(".provExcludeAB").show().parent().parent().addClass("showthis");
                        }
                }
                
				if (locationDebug) console.log("location.locationInit: ajax: mystore=",mystore);
				
				if (typeof(mystoreInit)=="function") {mystoreInit();}

			}
			if (data.status==2) {
				if (data.url!='') {
					location.href = data.url;
				} else {
					location.reload();
				}
			}
			if (data.status==3) {
				locationWindow(false,'');
			}

			/*
			$("#location-found").html(data);
			locationWindowPosition('change');
			$("#location-change input").removeClass('loading');
			locationSetLinks();
			*/
		}
	});
}

function locationCheck(allow){
	if (locationDebug) console.log("location.locationCheck()",arguments);
	var act = ""; if (allow) act = "check";
	locationSet(act,0);
}

function locationWindow(mask,name){
	if (locationDebug) console.log("location.locationWindow()",arguments);
	//$('.locationmodal').modal('show');

	if (mask) {
		if ($("#location-mask").css('display')!='block') $("#location-mask").fadeIn(300);
	} else {
		if ($("#location-mask").css('display')=='block') $("#location-mask").fadeOut(300);
	}
	if (name!='' && $("#location-"+name).css('display')!='block') {
		$("#location-"+name).fadeIn(300,function(){
			//if (name=='change') $("#location-change #input-text").focus();
		});
		locationWindowPosition(name);
	}
	if (name!='check'    && $("#location-check").css('display')   =='block') $("#location-check").fadeOut(300);
	if (name!='change'   && $("#location-change").css('display')  =='block') $("#location-change").fadeOut(300);
	if (name!='redirect' && $("#location-redirect").css('display')=='block') $("#location-redirect").fadeOut(300);
}

function locationWindowPosition(name) {
	if (locationDebug) console.log("location.locationWindowPosition()",arguments);
	var h = parseInt($("#location-"+name).height()/2);
	var t = $("#location-"+name).position().top;
	if (h>t) h = t;
	$("#location-"+name).css('margin-top',"-"+h+"px");
}

function locationSet(action,storeid) {
	if (locationDebug) console.log("location.locationSet()",arguments);
	
	if (action=="") { // not allowed
		locationAjax('set',{"name":"none"});
	}
	if (action=="check") {
		locationAjax('find',{"name":"","search":"","lat":0,"lon":0,"sethome":1});
	}
/*	
	$.ajax({
		url: locationURL,
		data: "action=" + action + "&storeid=" + storeid,
		dataType: 'json',
		type: "POST",
		success: function(data, textStatus, XMLHttpRequest){
			if (locationDebug) console.log("locationSet: ajax",data);
			var doredirect = true;
			if (data.changesite==1) {
				$("#location-redirect .name").html(data.site_name);
				$("#location-redirect .allow").attr('data-url', data.redirect);
				locationWindow(true,'redirect');
			} else {
				window.location.reload(true);
				locationWindow(false,'');
			}
		}
	});
*/	
	return false;
}

function locationSetLinks(){
	if (locationDebug) console.log("location.locationSetLinks()",arguments);
	
	$('.storelink').click(function(event){
		if (locationDebug) console.log("location.locationSetLinks: .storelink.click()");
		trackEvent('Location Change', 'Click', 'Change to '+$(this).attr('data-id'));
		locationSet('',$(this).attr('data-id'));
		event.stopImmediatePropagation();
		event.stopPropagation();
		return false;
	});
}

function storeHasCookies() {
	return (navigator.cookieEnabled);
}

function locationAutoCompleteInit() {
	if (locationDebug) {console.log("location.locationAutoCompleteInit()");}
	var i = 0;
	// Create the locationAutoComplete object, restricting the search to geographical
	// location types.

	if (locationDebug) {console.log("location.locationAutoCompleteInit: locationObjects.length=["+locationObjects.length+"]");}
	
	locationObjects.each(function(i){

		if (locationDebug) {console.log("location.locationAutoCompleteInit: i=["+i+"]");}

		$(this).attr("data-location-i",i);
		$(this).find("input[name=article_location_search]").attr("id","article_location_search_"+i);
		
		var input = document.getElementById('article_location_search_'+i);
		//var input = $("input[name=article_location_search]");

		locationAutoComplete[i] = new google.maps.places.Autocomplete(
			input,
			{types: ['geocode']}
		);
		locationAutoComplete[i].setComponentRestrictions({'country': ['ca']});

		// When the user selects an address from the dropdown, populate the address
		// fields in the form.
		locationAutoComplete[i].addListener('place_changed', function(){
			fillInAddress(i);
		});

	});

	locationObjects.find("input[name=article_location_search]").focusin(function(){
		if (locationDebug) {console.log("location.ready: article_location_search.focusin()");}
		geolocate($(this).attr("data-location-i"));
	});
	
	if (locationDebug) {console.log("location.locationAutoCompleteInit: a=",typeof('googleMapInit'));}
	
	if (typeof(googleMapInit)=="function") {googleMapInit();}
}

function fillInAddress(i) {
	if (locationDebug) {console.log("location.fillInAddress("+i+")", arguments);}
	var ii = 0;
	var place = locationAutoComplete[i].getPlace();
	
	if (locationDebug) {console.log("location.fillInAddress: place=",place);}
	if (!place.geometry) {
		return;
	}
	if (locationDebug) {console.log("location.fillInAddress: lat["+place.geometry.location.lat()+"] lng["+place.geometry.location.lng()+"]");}

	locationObjects.each(function(ii){
		if (ii==i) {
			$(this).find("input[name=article_location_lat]").val(place.geometry.location.lat());
			$(this).find("input[name=article_location_lon]").val(place.geometry.location.lng());
			$(this).find("input[name=article_location_search]").val(place.formatted_address);
			findStore(i);
			//$(this).submit();
		}
	});

}

function findStore(i) {
	if (locationDebug) {console.log("location.findStore()", arguments);}

	locationObjects.each(function(ii){
		if (locationDebug) {console.log("location.findStore: ii=["+ii+"]");}
		if (ii==i) {
			
			$(this).addClass("loading");

			data = {};
			data.lat = $(this).find("input[name=article_location_lat]").val();
			data.lon = $(this).find("input[name=article_location_lon]").val();
			if ($(this).find("input[name=sethome]").length>0) {
				data.sethome = 1;
			}

			if (locationDebug) {console.log("location.findStore: data=", data);}
			
			locationAjax('find',data);
		}
	});
	
}

// Bias the locationAutoComplete object to the user's geographical location,
// as supplied by the browser's 'navigator.geolocation' object.
function geolocate(i) {
	if (locationDebug) {console.log("location.geolocate("+i+")");}
	if (navigator.geolocation) {
		navigator.geolocation.getCurrentPosition(function(position) {
			var geolocation = {
				lat: position.coords.latitude,
				lng: position.coords.longitude
			};
			var circle = new google.maps.Circle({
				center: geolocation,
				radius: position.coords.accuracy
			});
			locationAutoComplete[i].setBounds(circle.getBounds());
		});
	}
}