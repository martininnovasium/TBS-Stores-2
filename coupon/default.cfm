<cfprocessingdirective suppresswhitespace="yes" pageencoding="utf-8">
<cfsetting enablecfoutputonly="yes"/>

<cfparam name="coupon_id" type="string" default=""/>

<cflocation url="http://tbsmembers.innovasium.com/get_coupon.php?coupon_id=#coupon_id#" addtoken="No"/>
<cfabort/>
    
<cfinclude template="common.cfm"/>

<!--- ================== --->
<!--- INSERT Build PDF --->

<cfif customer.id GT 0>    

    <cfset textX = 153.5/>
    <cfset textY = 116.75/>
    
	<cfset expire = DateFormat(customer.date_registered, "mmm d, yyyy")/>
    
    <cfpdf action="read" name="mypdf" source="#pdffile[customer.site_id]#" />
    
    <!--- Add expire Timestamp --->
    
<!---    
    <cfpdf
        action="addStamp"
        source = "#pdffile_tbs#"
        name = "mypdf"
    >
    <cfpdfparam
      pages = "1"
      coordinates = "#textX#,#textY#"
      iconName = "Approved"
      note = "#expire#" >
    >
--->
       
    <cfcontent variable="#toBinary(mypdf)#" type="application/pdf" />
        
</cfif>
    
<cfif debug>
<cfelse>
    <cfcontent file="#pdffile_tbs#"/>
</cfif>
    
<!---
<cfoutput><!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Coupon</title>
</head>

<body>
</body>
</html></cfoutput>
--->
</cfprocessingdirective>