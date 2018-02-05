// JavaScript Document

if( $(window).width() > 600 ){
	var i = 0,
	colOne = new Array(),
	colTwo = new Array();
	jQuery('#cff .cff-item').each(function(){
	i++;
	var $self = jQuery(this);
function isEven(value) {
	if (value%2 == 0)
	return true;
	else
	return false;
	}
	if ( isEven(i) ){
	colTwo.push($self);
	} else {
	colOne.push($self);
	}
	$self.remove();
	});
	$('#cff').prepend('<div class="col-one" style="width: 45%; float: left; margin: 0 2.5%;"></div><div class="col-two" style="width: 45%; float: left; margin: 0 2.5%;"></div>');
	for (var i = 0; i < colOne.length; i++) {
	jQuery('#cff .col-one').append(colOne[i]);
	};
	for (var i = 0; i < colOne.length; i++) {
	jQuery('#cff .col-two').append(colTwo[i]);
	};
}