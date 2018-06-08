function fbs3_ready() {
    console.log("custom.formbasic_s3.fbs3_ready()");
    $("body").append("<div class='progress'><div class='bar'></div><div class='text'></div></div>");
}

function fbs3_submit() {
    console.log("custom.formbasic_s3.submit()");
    
    // Build formData
    var formData = new FormData();
    formData.append('key', $('input[name=key]').val());
    formData.append('AWSAccessKeyId', $('input[name=AWSAccessKeyId]').val());
    formData.append('acl', $('input[name=acl]').val());
    if ($('input[name=redirect]').length>0) {
        formData.append('redirect', $('input[name=redirect]').val());
    }
    formData.append('policy', $('input[name=policy]').val());
    formData.append('signature', $('input[name=signature]').val());
    formData.append('file', $('input[name=file]')[0].files[0]);
    console.log(formData);
    
    console.log("custom.formbasic_s3.submit: submitting");
    
    progress(-1);
    
    // Send as AJAX
//        enctype: $("#s3upload").attr('enctype'),
    $.ajax({
        url: $("#s3upload").attr('action'),
        type: $("#s3upload").attr('method'),
        data: formData,
        processData: false,
        contentType: false,
        cache: false,
 
        xhr: function () {
            var jqXHR = null;
            if ( window.ActiveXObject ){
                jqXHR = new window.ActiveXObject( "Microsoft.XMLHTTP" );
            } else {
                jqXHR = new window.XMLHttpRequest();
            }             
            jqXHR.upload.addEventListener("progress", function (evt) {
               if (evt.lengthComputable) {
                   var percentComplete = Math.round( (evt.loaded * 100) / evt.total );
                   console.log(percentComplete);
                   if (percentComplete === 1) {
                       progress(100);
                   } else {
                       progress(percentComplete);
                   }
               }
            }, false);
            jqXHR.addEventListener("progress", function (evt) {
               if (evt.lengthComputable) {
                   var percentComplete = Math.round( (evt.loaded * 100) / evt.total );
                   console.log(percentComplete);
                   progress(percentComplete);
               }
            }, false);
            return jqXHR;
        }
    }).done(function(data) {
        console.log("custom.formbasic_s3.submit: done");
        console.log(data);
        
        if (typeof(data)!="undefined") {
            var found = data.match(/fbs3_done\('(.*)'\)/i);
            console.log("custom.formbasic_s3.submit: found=",found);

            if (found.length>1) {
                console.log("custom.formbasic_s3.submit: found=["+found[1]+"]");
                fbs3_done(found[1]);
            } else {
                fbs3_done('');
            }
        } else {
            fbs3_done();
        }
        
    }).fail(function(jqXHR, textStatus, errorThrown) {
        console.log("custom.formbasic_s3.submit: fail");
        console.log("textStatus=",textStatus);
        console.log("errorThrown=", errorThrown);
        console.log("jqXHR=",jqXHR);
    });
    
    return false;
}

function progress(p) {
    $("#s3upload").hide();    
    $(".progress").show();    
    if (p === -1) {
        $('.progress .text').text("Starting Upload");
        $('.progress .bar').css("width",0);
    } else if (p === 1 || p === 100) {
        $('.progress .text').text("Upload Finished");
        $('.progress .bar').css("width","100%");
    } else {
        $('.progress .text').text(p + '%');
        $('.progress .bar').css("width", p + '%');
    }
}

