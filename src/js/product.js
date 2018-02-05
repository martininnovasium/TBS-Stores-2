var productDebug = true;

if (productDebug) console.log("product.load()");
if (productDebug) console.log("product.load: mystore=",mystore);
if (productDebug) console.log("product.load: myzone=["+myzone+"]");

$(document).ready(function() {
	if (productDebug) console.log("product.ready()");
	if (productDebug) console.log("product.ready: mystore=",mystore);
	if (productDebug) console.log("product.ready: myzone=["+myzone+"]");

	if (myzone!='') {
		$(".article_item div[class^=article_meta_price"+myzone+"]").each(function(i){
			if (productDebug) console.log("product div[class^=article_meta_price].each("+i+")");
			var c = $(this).attr('class');
			var d = $(this).text();
			$(this).attr('data-orig',d);
			if (d.indexOf(',')>-1) {
				d = d.split(',');
				if (d[1].indexOf('$')==-1) d[1] = '$'+d[1];
				$(this).parent().attr('data-was', d[1]);
				d = d[0];
			}
			if (d.indexOf('$')==-1) d = '$'+d;
			$(this).text(d);
		});
	}
	
	$(".productList article").each(function() {
		$(this).append('<div class="prodMore"><a href="#" class="btn btn-yellow">More</a></div>');
	});

	
	$(".article_meta_price"+myzone).show();

	if ($("#ProductDetailsReveal").length==0) {

		var html = '';
		html += "<div id='ProductDetailsReveal' class='modal fade loading'>";
		html += " <div class='content'>";
		html += "  <div id='ProductModal'>";
		html += "   <div class='close1 newclose'><img src='/img/close.png' alt='close'></div>";
		html += '   <div class="col-md-7">';
		html += '    <div class="images">';
		html += '     <div class="thumbs"></div>';
		html += '     <div class="bigimage"></div>';
		html += '    </div>';
		html += '   </div>';
		html += '   <div class="col-md-5">';
		html += '    <div class="prodTitle"></div>';
		html += '    <div class="prodDetails"></div>';
		// html += '    <div class="prodPriceWas"><span class="was"></span> <span class="price"></span></div>';
		html += '    <div class="prodPriceWas"><span class="price"></span></div>';
		html += '    <div class="prodPrice"><span></span></div>';
		html += '   </div>';
		html += "  </div>";
		html += " </div>";
		html += "</div>";

		$('body').append(html);

		$('#ProductDetailsReveal .close1.newclose').click(function(){
			$('#ProductDetailsReveal').modal('hide'); // hide the overlay
			$("#ProductDetailsReveal").addClass('loading');
			$("#ProductDetailsReveal").removeClass("in");
			$('body').css('overflow','auto');
		});

	}

	$(".productList .article_title a").click(function()	{
		if (productDebug) console.log("product .productList .article_title a.click()");
		launchProduct($(this).parent().parent().parent());
		event.stopImmediatePropagation()
		return false;
	});

	$(".productList article").click(function(event) {
		if (productDebug) console.log("product .productList article.click()");
		launchProduct($(this));
		event.stopImmediatePropagation()
		return false;
	});

	$('#ProductDetailsReveal').on('hidden.bs.modal', function () {
		if (productDebug) console.log("product ProductDetailsReveal.modal.hidden()");
		$('body').css('overflow','auto');
		$('body').unbind('touchmove')
	})


	$(".productList.expandWidth .renderOldPrice article").each(function(i) {
		if (productDebug) console.log("product article.each("+i+")");
		var d = $(this).find(".article_item").attr("data-was");
		console.log(d);
		if (typeof(d)!="undefined") {
			if (productDebug) console.log("product article.each: d=["+d+"]{"+d.indexOf(":")+"}");
			if (d.indexOf(":")>-1) {
				d = d.split(":");
			} else {
				//d = ['WAS:',d];
				d = [d];
			}
			if (productDebug) console.log("product article.each: d=",d);
			//$(this).find("div[class*='article_meta_price']").append("<span class='oldPrice'><br/>"+d[0]+" "+d[1]+"</span>");
			$(this).find("div[class*='article_meta_price']").append("<span class='oldPrice'><br/>"+d[0]+"</span>");
		}
	});

});

function launchProduct(obj) {
	if (productDebug) console.log("product.launchProduct()");

	var gallery = "";
	var prodObj = $("#ProductModal");

	prodObj.find(".thumbs").html('');
	prodObj.find(".bigimage").html('');
	prodObj.find(".prodTitle").html('');
	prodObj.find(".prodDetails").html('');
	prodObj.find(".bigimage").html('');
	prodObj.find(".prodPriceWas").hide();
	prodObj.find(".prodPrice span").html('');

	$("#ProductDetailsReveal").modal();
	$("#ProductDetailsReveal").addClass("in");
	$("#ProductDetailsReveal").removeClass("loading");
	$('body').css('overflow','hidden');

	var productID = obj.find(".article_title a").attr("href");

	var BigImage = obj.find(".article_image img").attr("src");
	var title = obj.find(".article_title a").html();
	var excerpt = obj.find(".article_excerpt").html();
	if (obj.find(".article_meta_gallery").length>0) {
		gallery = JSON.parse(obj.find(".article_meta_gallery").attr('data-value'));
	}

	if (productDebug) console.log("product.launchProduct: gallery=",gallery);

	trackEvent('Product', 'Click', title);

	var thumbhtml = "";
	if (typeof(gallery)=='object') {
		for (i = 0; i < gallery.length; i++) {
			if (gallery[i].thumb!='') {
				thumbhtml += "<div class='item' data-image='"+gallery[i].small+"'>";
				thumbhtml += "<img src='"+gallery[i].thumb+"'/>";
				thumbhtml += "</div>";
				$('<img/>')[0].src = gallery[i].small;
			}
		}
	}

	var price = obj.find("div[class$=price"+myzone+"]").html();

	prodObj.find(".thumbs").html(thumbhtml).scrollTop(0);
	prodObj.find(".bigimage").html('');
	prodObj.find(".prodTitle").html(title);
	prodObj.find(".prodDetails").html(excerpt);
	prodObj.find(".bigimage").html('<img src='+BigImage+'>');
	prodObj.find(".prodPrice span").html(price);
	var d = obj.find('.article_item').attr('data-was');
	if (d) {
		if (d.indexOf(":")>-1) {
			d = d.split(":");
		} else {
			d = ['WAS:',d];
		}
		if (productDebug) console.log("product.launchProduct: d=",d);
		prodObj.find(".prodPriceWas span.was").html(d[0]);
		prodObj.find(".prodPriceWas span.price").html(d[1]);
		prodObj.find(".prodPriceWas").show();
	}

	if (thumbhtml=='') {
		prodObj.find(".images").addClass("nothumb");
		prodObj.find(".bigimage").html('<img src='+BigImage+'>');
	} else {
		prodObj.find(".images").removeClass("nothumb");
		prodObj.find(".bigimage").html('<img src='+gallery[0].small+'>');
	}

	prodObj.find(".thumbs .item").click(function(event) {
		if (productDebug) console.log("product .productList .thumbs .item.click()");
		var smallImage = $(this).attr('data-image');
		prodObj.find(".bigimage img").attr('src',smallImage);
	});

}