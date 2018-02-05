var locationautocompleteDebug = true;
var locationSelector = ".locationControl form";

var autocomplete=[], clinicautocompleteObject;
/*
https://maps.googleapis.com/maps/api/js?key=AIzaSyBQeUOo4totpuLp86zn3phlvDIsDdzv7D0&libraries=places&callback=initAutocomplete
*/

$(function() {
	$(locationSelector).submit(function(){
		var i = $(this).find("input[name=article_location_search]").data("i")
		findStore(i);
		return false;
	});
});

$(document).ready(function(){
	if (locationautocompleteDebug) {console.log("location-autocomplete.ready()");}

	if (locationautocompleteDebug) {console.log("location-autocomplete.ready: google=["+typeof(google)+"]");}
	
	clinicautocompleteObject = $(locationSelector);
	
	if (clinicautocompleteObject.length>0){
		if (typeof(google)=="undefined") {
			var sg=document.createElement('script');sg.type='text/javascript';sg.async=true;
			var b=('htt'+'ps:'==document.location.protocol?'htt'+'ps://':'htt'+'p://');sg.src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBQeUOo4totpuLp86zn3phlvDIsDdzv7D0&libraries=places&callback=initAutocomplete";
			var s=document.getElementsByTagName('script')[0];s.parentNode.insertBefore(sg,s);
		} else {
			initAutocomplete();
		}
	}
	
});

function initAutocomplete() {
	if (locationautocompleteDebug) {console.log("location-autocomplete.initAutocomplete()");}
	var i = 0;
	// Create the autocomplete object, restricting the search to geographical
	// location types.

	if (locationautocompleteDebug) {console.log("location-autocomplete.initAutocomplete: clinicautocompleteObject.length=["+clinicautocompleteObject.length+"]");}
	
	clinicautocompleteObject.each(function(i){

		if (locationautocompleteDebug) {console.log("location-autocomplete.initAutocomplete: i=["+i+"]");}
		
		$(this).find("input[name=article_location_search]").attr("id","article_location_search_"+i).data("i",i);
		
		var input = document.getElementById('article_location_search_'+i);
		//var input = $("input[name=article_location_search]");

		autocomplete[i] = new google.maps.places.Autocomplete(
			input,
			{types: ['geocode']}
		);

		// When the user selects an address from the dropdown, populate the address
		// fields in the form.
		autocomplete[i].addListener('place_changed', function(){
			fillInAddress(i);
		});

	});

	clinicautocompleteObject.find("input[name=article_location_search]").focusin(function(){
		if (locationautocompleteDebug) {console.log("location-autocomplete.ready: article_location_search.focusin()");}
		geolocate($(this).data("i"));
	});
	
}

function fillInAddress(i) {
	if (locationautocompleteDebug) {console.log("location-autocomplete.fillInAddress("+i+")", arguments);}
	var ii = 0;
	var place = autocomplete[i].getPlace();
	
	if (locationautocompleteDebug) {console.log("location-autocomplete.fillInAddress: place=",place);}
	if (!place.geometry) {
		return;
	}
	if (locationautocompleteDebug) {console.log("location-autocomplete.fillInAddress: lat["+place.geometry.location.lat()+"] lng["+place.geometry.location.lng()+"]");}

	clinicautocompleteObject.each(function(ii){
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
	if (locationautocompleteDebug) {console.log("location-autocomplete.findStore()", arguments);}
	$(locationSelector).addClass("loading");

	clinicautocompleteObject.each(function(ii){
		if (ii==i) {
			data = {};
			data.lat = $(this).find("input[name=article_location_lat]").val();
			data.lon = $(this).find("input[name=article_location_lon]").val();
			if ($(this).find("input[name=sethome]").length>0) {
				data.sethome = 1;
			}

			if (locationautocompleteDebug) {console.log("location-autocomplete.findStore: data=", data);}
			locationAjax('find',data);
		}
	});
	
}

// Bias the autocomplete object to the user's geographical location,
// as supplied by the browser's 'navigator.geolocation' object.
function geolocate(i) {
	if (locationautocompleteDebug) {console.log("location-autocomplete.geolocate("+i+")");}
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
			autocomplete[i].setBounds(circle.getBounds());
		});
	}
}