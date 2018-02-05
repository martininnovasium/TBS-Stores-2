// V2

var storeDebug = false;
var locationURL = "/ajax_location.cfm";

var storeProvinceData = [];
var storeCityData = [];

'use strict';

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

// This library is used for comparing the dates
var dates = {
  convert: function convert(d) {
    // Converts the date in d to a date-object. The input can be:
    //   a date object: returned without modification
    //  an array      : Interpreted as [year,month,day]. NOTE: month is 0-11.
    //   a number     : Interpreted as number of milliseconds
    //                  since 1 Jan 1970 (a timestamp) 
    //   a string     : Any format supported by the javascript engine, like
    //                  "YYYY/MM/DD", "MM/DD/YYYY", "Jan 31 2009" etc.
    //  an object     : Interpreted as an object with year, month and date
    //                  attributes.  **NOTE** month is 0-11.
    return d.constructor === Date ? d : d.constructor === Array ? new Date(d[0], d[1], d[2]) : d.constructor === Number ? new Date(d) : d.constructor === String ? new Date(d) : (typeof d === 'undefined' ? 'undefined' : _typeof(d)) === "object" ? new Date(d.year, d.month, d.date) : NaN;
  },
  compare: function compare(a, b) {
    // Compare two dates (could be of any type supported by the convert
    // function above) and returns:
    //  -1 : if a < b
    //   0 : if a = b
    //   1 : if a > b
    // NaN : if a or b is an illegal date
    // NOTE: The code inside isFinite does an assignment (=).
    return isFinite(a = this.convert(a).valueOf()) && isFinite(b = this.convert(b).valueOf()) ? (a > b) - (a < b) : NaN;
  },
  inRange: function inRange(d, start, end) {
    // Checks if date in d is between dates in start and end.
    // Returns a boolean or NaN:
    //    true  : if d is between start and end (inclusive)
    //    false : if d is before start or after end
    //    NaN   : if one or more of the dates is illegal.
    // NOTE: The code inside isFinite does an assignment (=).
    return isFinite(d = this.convert(d).valueOf()) && isFinite(start = this.convert(start).valueOf()) && isFinite(end = this.convert(end).valueOf()) ? start <= d && d <= end : NaN;
  }
};

var Store = function () {
  function Store(storeData) {
    var todayDate = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : false;

    _classCallCheck(this, Store);

    this.days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    this.results = {};
    this.today = todayDate ? this.newDate(todayDate) : this.newDate();
    this.weekStart = this.getStartOfWeek(this.today);
    this.weekEnd = this.getEndOfWeek(this.today);
    this.weekMap = {};
    this.data = storeData;
    this.formattedHtml = '';

    for (var i = 0; i < 7; i++) {
      var d = new Date(this.weekStart.getTime());
      d.setDate(d.getDate() + i);
      this.weekMap[this.days[i]] = d;
    }
    this.init();
  }

  _createClass(Store, [{
    key: 'init',
    value: function init() {
      var _this = this;

      if (this.data['openingHoursSpecification'].constructor === Array) {
        this.data['openingHoursSpecification'].forEach(function (entry) {
          _this.processEntry(entry);
        });
      } else {
        this.processEntry(this.data['openingHoursSpecification']);
      }
      this.prepareFormattedHtml();
      this.displayData();
    }
  }, {
    key: 'prepareFormattedHtml',
    value: function prepareFormattedHtml() {
      var _this2 = this;

      // Object.keys(this.results).forEach((element, index) => {
      //   const timing = this.results[element].closed ? 'Closed' : `${this.results[element].opens} to ${this.results[element].closes}`;
      //   this.formattedHtml += `<div class="business-hours-day-block">
      //     <strong class="day">${element}</strong>
      //     <span class="time">
      //       ${timing}
      //     </span>
      //   </div>`;
      // });

      this.days.forEach(function (element, index) {
        var timing = _this2.results[element].closed ? 'Closed' : _this2.results[element].opens + ' to ' + _this2.results[element].closes;
        _this2.formattedHtml += '<div class="business-hours-day-block">\n        <strong class="day">' + element + '</strong>\n        <span class="time">\n          ' + timing + '\n        </span>\n      </div>';
      });
    }
  }, {
    key: 'displayData',
    value: function displayData() {
      $(".storeDays").html(this.formattedHtml);
    }
  }, {
    key: 'newDate',
    value: function newDate(date) {
      var d = date ? new Date(date) : new Date();
      if (d.getHours() < 12) {
        d.setHours(0, 0, 0, 0); // previous midnight day
      } else {
        d.setHours(24, 0, 0, 0); // next midnight day
      }
      return d;
    }
  }, {
    key: 'processEntry',
    value: function processEntry(entry) {
      var _this3 = this;

      var validFromDate = this.newDate(entry.validFrom);
      var validToDate = this.newDate(entry.validThrough);

      if (typeof entry.validFrom === 'undefined' && typeof entry.validThrough === 'undefined') {
        this.pushHoursToDay(entry, entry.dayOfWeek, false);
      }

      var validDateAndWeekEndComparison = dates.compare(validFromDate, this.weekEnd);
      if (validDateAndWeekEndComparison === -1 || validDateAndWeekEndComparison === 0) {
        if (typeof entry.validThrough !== 'undefined' && this.weekStart <= validToDate) {
          var toDate = void 0;
          if (_typeof(entry.dayOfWeek) === 'object') {
            entry.dayOfWeek.forEach(function (element, index) {
              toDate = typeof entry.validThrough === 'undefined' ? false : validToDate;
              _this3.pushHoursToDay(entry, element, toDate);
            });
          } else if (typeof entry.dayOfWeek === 'string') {
            toDate = typeof entry.validThrough === 'undefined' ? false : validToDate;
            this.pushHoursToDay(entry, entry.dayOfWeek, toDate);
          }
        }
      }
    }

    // Gets the Sunday of this week's date

  }, {
    key: 'getStartOfWeek',
    value: function getStartOfWeek(date) {
      // Copy date if provided, or use current date if not
      date = date ? new Date(+date) : new Date();
      date.setHours(0, 0, 0, 0);

      // Set date to previous Sunday
      date.setDate(date.getDate() - date.getDay());

      return date;
    }

    // Gets the Saturday of this week's date

  }, {
    key: 'getEndOfWeek',
    value: function getEndOfWeek(date) {
      date = this.getStartOfWeek(date);
      date.setDate(date.getDate() + 6);
      return date;
    }

    // Returns YYYY-MM-DD format

  }, {
    key: 'getDateFormat',
    value: function getDateFormat(date) {
      date = date ? new Date(+date) : new Date();
      return date.toISOString().slice(0, 10);
    }

    // Get the 12 hour format

  }, {
    key: 'get12HourFormat',
    value: function get12HourFormat(time) {
      var values = time.split(':');
      var hour = parseInt(values[0], 10);
      var minutes = values[1];
      var minutesContainer = minutes === '00' ? '' : ":" + minutes;
      var results = (hour + 11) % 12 + 1 + minutesContainer + (hour > 11 ? 'pm' : 'am');
      return results;
    }

    // Push the date to the given day

  }, {
    key: 'pushHoursToDay',
    value: function pushHoursToDay(entry, day, validToDate) {
      var hours = {
        opens: this.get12HourFormat(entry.opens),
        closes: this.get12HourFormat(entry.closes),
        closed: entry.opens === entry.closes && entry.opens === '00:00'
      };
      var datesCompare = dates.compare(this.weekMap[day], validToDate);
      if (!validToDate) {
        this.results[day] = hours;
      } else if (datesCompare === -1 || datesCompare === 0) {
        this.results[day] = hours;
      }
    }
  }]);

  return Store;
}();

/* ------------------------------ */

$(function() {
});

$(window).scroll(function(){
	$(".mapStreet").removeClass("decreaseIndex");
});

$(document).ready(function(){
	if (storeDebug) {console.log("store.ready()");}
	
	//initialize();
	
	$(".mapStreet").click(function()
	{
		console.log("clicked");
		$(".mapStreet").addClass("decreaseIndex");
	});
	
	var banner_image = "";

	if (typeof(article)!="undefined") {
		if (storeDebug) {console.log("store.ready: article=",article);}

		storeType = '';
		article.roles.forEach( function(element, index) {
			if (element.role === 'tbs') {
				storeType = 'tbs';
			} else if (element.role === 'ra') {
				storeType = 'ra';
			}
		});
		
		/** special hours**/
		var hoursNoteArray = JSON.parse(article.meta.hours_note); 
		for (var i = 0; i < hoursNoteArray.hoursArray.length; i++) {
			if(new Date() >= new Date(hoursNoteArray.hoursArray[i].StartDate) && new Date() <= new Date(hoursNoteArray.hoursArray[i].EndDate)) {
				$("#store_specialhours").html(hoursNoteArray.hoursArray[i].title+hoursNoteArray.hoursArray[i].body);
			}
		}
		
		var lat = article.locations[0].lat;
		var lon = article.locations[0].lon;

		$("#store_title").html((storeType === 'ra' ? 'Red Apple' : 'The Bargain Shop') + " - " + article.locations[0].city+", "+article.locations[0].provstate);
		$("#store_address").html(article.locations[0].address + ", " + article.locations[0].city+", "+article.locations[0].provstate);
		$("#store_phone").html(article.locations[0].phone);

		$("#store_social").html("<a target='_blank' title='Visit our Facebook page' href='http://facebook.com/" +
		(storeType === 'ra' ? 'redapplestores' : 'TheBargainShopStores') + "'><img src='/img/FB-f-Logo__blue_29.png' " + 
		"alt='Visit our Facebook page' /> <span>Visit our Facebook page</a></a>" );

		// Initializing the store data
		var structuredData = JSON.parse(article.meta.google_structured_data);
		var store = new Store(structuredData);

		$("#province-selector").on('change', function(event) {
			if (storeDebug) {console.log("store.ready: provinceSelectorObj.change()");}
			event.preventDefault();
			if (typeof(article)!="undefined" && $(this).val()!='') {
				loadCity($(this).val(),article.name);
			}
		});

		$("#city-selector").on('change', function(event) {
			if (storeDebug) {console.log("store.ready: citySelectorObj.change()");}
			event.preventDefault();
			var u = $(this).find("option:selected").val();
			if (u) {
				$("#province-selector,#city-selector").attr('disabled', true).addClass('loading');
				window.location.href = u;
			}
		});

		$("#city-selector").on('focus', function(event) {
			if (storeDebug) {console.log("store.init: city-selector.focus()");}
			$(this).find("option").each(function(i){
				if (i>0) $(this).text(storeCityData[i-1].label + " (" + storeCityData[i-1].address + ")");
			})
		});

		$("#city-selector").on('blur', function(event) {
			if (storeDebug) {console.log("store.init: city-selector.blur()");}
			$(this).find("option").each(function(i){
				if (i>0) $(this).text(storeCityData[i-1].label);
			});
		});

	} else {
		if (storeDebug) {console.log("store.ready: no store");}
		$(".storeDetailPanel, #searchbar, .id_storemap").hide();
		$("#nostore").html("Store not found. Please find a store <a href='/locations.htm'>here</a>.");
		setTimeout(function(){
			location.href="/locations.htm";
		}, 3000);
	}
});

function loadProvince(prov) {
	if (storeDebug) {console.log("store.loadProvince()",arguments);}
	
	var provinceSelectorObj = $("#province-selector");
	
	provinceSelectorObj.attr('disabled', true).addClass('loading')
	provinceSelectorObj.html('<option>Loading...</option>');
	
	$.ajax({
		url: '/ajax_store.cfm',
		type: 'GET',
		dataType: 'json',
		data: {action: 'provinces'},
	})
	.done(function(data) {
		if (storeDebug) {console.log("store.ready: ajax_store: data=",data);}
		if (data.status>0) {
			storeProvinceData = data.data;
			provinceSelectorObj.html("<option value=''>Select a province</option>");
			$(storeProvinceData).each(function(i){
				var sel = "";
				if (prov==storeProvinceData[i].val) sel = " selected";
				provinceSelectorObj.append("<option value='" + storeProvinceData[i].val + "'"+sel+">" + storeProvinceData[i].label + "</option>");
			});
		}
		if (data.status<0) {
			alert(data.message);
		}
		provinceSelectorObj.attr('disabled', false).removeClass('loading')
	});	
	
}
function loadCity(prov,name) {
	if (storeDebug) {console.log("store.loadCity()",arguments);}
	
	var citySelectorObj = $("#city-selector");
	
	citySelectorObj.attr('disabled', true).addClass('loading')
	citySelectorObj.html('<option>Loading...</option>');
	
	$.ajax({
		url: '/ajax_store.cfm',
		type: 'GET',
		dataType: 'json',
		data: {province: prov, action: 'cities'},
	})
	.done(function(data) {
		if (storeDebug) {console.log("store.ready: ajax_store: data=",data);}
		if (data.status>0) {
			storeCityData = data.data;
			citySelectorObj.html("<option value=''>Select a city</option>");
			$(storeCityData).each(function(i){
				var sel = "";
				if (storeCityData[i].val.indexOf("/"+name+"/")>-1) sel = " selected";
				citySelectorObj.append("<option value='" + storeCityData[i].val + "'"+sel+">" + storeCityData[i].label + "</option>");
			});
		}
		if (data.status<0) {
			alert(data.message);
		}
		citySelectorObj.attr('disabled', false).removeClass('loading')
	});
	
}

function drawMyHome() {
	if (storeDebug) {console.log("store.drawMyHome()");}
	if (storeDebug) {console.log("store.drawMyHome: article.id=["+article.id+"] mystore.id=["+mystore.id+"]");}
	if (article && mystore) {
		if (article.id != mystore.id) {
			if (storeDebug) {console.log("store.drawMyHome: draw");}
			$(".storeDetailPanel .careersAvailable").append("<a class='sethome' href='#'>Set as my home store</a>");
			$(".storeDetailPanel .careersAvailable .sethome").click(function(event){
				if (storeDebug) {console.log("store.drawMyHome: .storeDetailPanel .careersAvailable .but.click()");}
				event.preventDefault();
				locationAjax('sethome',{'name':article.name});	
			});
		}
	}
}

function mystoreInit () {
	if (storeDebug) {console.log("store.mystoreInit()");}
	if (typeof(article)!="undefined") {
		if (storeDebug) {console.log("store.mystoreInit: article=",article);}
		drawMyHome();
	}
}

function googleMapInit() {
	if (storeDebug) {console.log("store.googleMapInit()");}
	// Google API has finished loading

	if (typeof(article)!="undefined") {
		if (storeDebug) {console.log("store.googleMapInit: article=",article);}
	
		var store_lat = article.locations[0].lat;
		var store_lon = article.locations[0].lon;

		loadProvince(article.locations[0].provstate);
		loadCity(article.locations[0].provstate,article.name);
		//drawMyHome();

		// Draw google map from lat/lon

		var uluru = {lat: store_lat, lng: store_lon};
		var map = new google.maps.Map(document.getElementById('map'), {
		  zoom: 14,
		  center: uluru
		});
		var marker = new google.maps.Marker({
		  position: uluru,
		  map: map
		});

		if(article.image == '')
		{
			var StreetViewHeading = JSON.parse(article.meta.street_view_heading);	
			var StreetViewZoom = JSON.parse(article.meta.street_view_zoom);
			var StreetViewLat = JSON.parse(article.meta.street_view_lat);
			var StreetViewLon = JSON.parse(article.meta.street_view_lon);
			RenderStreetView(StreetViewLat,StreetViewLon,StreetViewHeading,StreetViewZoom);
		}
		else
		{
			$("#pano").css("background-image","url("+article.image+")");
		}
	}
}

function RenderStreetView(addLat,addLon, heading, zoomlevel) {
  var storeFront = {lat: addLat, lng: addLon};
  var streetmap = new google.maps.Map(document.getElementById('streetview'), {
    center: storeFront,
    zoom: 20,
	gestureHandling: 'cooperative'
  });
  var panorama = new google.maps.StreetViewPanorama(
      document.getElementById('pano'), {
        position: storeFront,
        pov: {
          heading: heading,
          pitch: 0,
		  zoom: zoomlevel,
		  
        },
		linksControl: false,
        panControl: false,
        enableCloseButton: false,
		addressControl :false,
		motionTrackingControl :false,
		fullscreenControl :false,
		enableCloseButton :false,
		scaleControl: false,
  		scrollwheel: false,
		 motionTracking: false,
      motionTrackingControl: false,
		gestureHandling: 'none'
      });
  streetmap.setStreetView(panorama);
}