<cfprocessingdirective suppresswhitespace="yes" pageencoding="utf-8">
<cfsetting enablecfoutputonly="yes"/>

<cfinclude template="common.cfm"/>

<!--- ================== --->
<!--- INSERT Build PDF --->

    
<cfif debug>
    <cfoutput>
        
<pre>
customer_id=[#customer_id#]
site_id=[#site_id#]
timestamp=[#timestamp#]
pdffile_tbs=[#pdffile_tbs#]
</pre>

<pre>
<cfset a = "123|1">
a=[#a#]
<cfset b = ecode(a,2)/>
b=[#b#]
<!---cfset b = "=IDfwYDOwIjM"/--->
<cfset c = dcode(b,2)/>
c=[#c#]
</pre>

    </cfoutput>
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