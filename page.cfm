<cfprocessingdirective suppresswhitespace="yes" pageencoding="utf-8">
<cfsetting enablecfoutputonly="yes">
<cfscript>
	// -------------------------------------
	// Load page
	Request.page = createObject('component','forefront_6.components.page');
	pageExists = Request.page.init(Request.PageId, true);

	isStandalone = false;
	if (Request.page.getTemplateFile() EQ "standalone") isStandalone = true;

	isAjax = false;
	try {
		if (StructKeyExists(request.header.headers,'X-Requested-With') EQ true) isAjax=true;
	} catch (Any error) {}

	sectionPath = "";
	pageTitle = "";
	for (i = 1 ; i LTE ArrayLen(Application.custom.domains) ; i = (i + 1)) {
		if (ListFind(Application.custom.domains[i][1],cgi.SERVER_NAME) GT 0) {
			sectionPath = Application.custom.domains[i][3];
			pageTitle = Application.custom.domains[i][4];
		}	
	}
	//pageTitle = pageTitle & " (#session['myzone']#)";
    
Request.debugLog("redirect_article.init()");
    
	pageTitleTmp = Request.page.getTitle();
    if (pageTitle NEQ "" AND pageTitleTmp NEQ "") {
        pageTitle = pageTitle & " : ";
    }
    if (pageTitleTmp NEQ "") {
        pageTitle = pageTitle & REReplace(pageTitleTmp,"(\\n)"," ","all");
    }
    
	//pageTitle = Application.locations.roles[session['location_role_id']].title;
	//pageTitle = "";
    /*
	if (StructKeyExists(session,'location_role_id')) {
		if (Request.page.getTitle(session['location_role_id']) NEQ "") {
			pageTitle = pageTitle & " : " & REReplace(Request.page.getTitle(session['location_role_id']),"(\\n)"," ","all");
		} else {
			if (Request.page.getTitle() NEQ "") {
				pageTitle = pageTitle & " : " & REReplace(Request.page.getTitle(),"(\\n)"," ","all");
			}
		}
	}
    */

</cfscript>
<cfif pageExists>
	<cfif isStandalone EQ true>
		<cfinclude template="_assets/templates/#Request.page.getTemplateFile()#.cfm">
	<cfelse>
<cfoutput><!DOCTYPE html>
<html lang="#Request.page.getLangLocation()#">
<head>
	<title>#pageTitle#</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="description" content="#HTMLEditFormat(Request.page.getMetaDescription())#" />
	<meta name="keywords" content="#HTMLEditFormat(Request.page.getMetaKeywords())#" />
	<meta name="author" content="Innovasium" />
	<meta name="dcterms.rightsHolder" content="#Request.page.getSetting('site_name')#" />
	<meta name="dcterms.dateCopyrighted" content="#(DateFormat(Now(),'yyyy')-1)#-#DateFormat(Now(),'yyyy')#" />
	<meta name="dcterms.rights" content="All rights reserved" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
#Request.page.getAdminHeader()#
	<meta name="robots" content="allow;all" />
	<link rel="shortcut icon" type="image/x-icon" href="/src/img/#sectionPath#/favicon.ico" />
	<link rel="icon" type="image/png" href="/src/img/#sectionPath#/favicon.png" />
	<link href="https://fonts.googleapis.com/css?family=Open+Sans:400,700,800" rel="stylesheet" />
	<link href="https://fonts.googleapis.com/css?family=Bree+Serif" rel="stylesheet">
	<link href="https://fonts.googleapis.com/css?family=Lobster" rel="stylesheet">
<!--%article_google_structured_data%-->
<script type="text/javascript">
var myzone = '#session['myzone']#';
</script>
#Request.page.getStylesHeader()#
<cfif Request.page.getProperty('top_image') NEQ "">
<style type="text/css">
.topImage { background-image: url('#Request.page.getProperty('top_image')#'); }
</style>
	</cfif>	
#Request.page.getScriptsHeader()#
<cfinclude template="\lib\cfm\googleanalytic.cfm">
<script src="https://use.typekit.net/jjr5zvo.js"></script>
<script>try{Typekit.load({ async: true });}catch(e){}</script>
</head>
<body class='#Request.page.getProperty("page_color")#' >

<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = 'https://connect.facebook.net/en_US/sdk.js##xfbml=1&version=v2.10&appId=137902272946348';
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>
	<div id="header">
#Request.page.getElement('header').getHtmlDiv(true)#
	</div>
	<div class="fix" data-spy="affix" data-offset-top="360">
#Request.page.getElement('subheader').getHtmlDiv(true)#
	</div>
	<div id="contents">
<cfinclude template="_assets/templates/#Request.page.getTemplateFile()#.cfm">
	</div>
	<div id="footer">
#Request.page.getElement('footer').getHtmlDiv(true)#
	</div>
	<cfif Request.page.hasCatches() EQ true>
		<small><i>FF6 catches</i></small>
		<cfif Request.Debug EQ true OR Application.status EQ "dev">
			<cfdump var="#Request.page.getCatches()#" label="Catches">
		</cfif>
	</cfif>
<!---	
	<cfif Request.Debug EQ true OR Application.status EQ "dev">
<cfdump var="#Application.custom#"	 label="Application.custom" expand="no"/>
<cfdump var="#session#"	 label="session" expand="no"/>
	</cfif>
<cfdump var="#session#"	 label="session"/>
<cfdump var="#Request#"	 label="Request"/>
--->
</body>
</html>
</cfoutput>
	</cfif>
<cfelse>
<cfoutput><!DOCTYPE html>
<html lang="en">
<head>
	<title>Page Error</title>
</head>
<body>
<cfif Request.page.hasCatches() EQ true>
	<p>Page Error (#myurl.file#)</p>
	<cfif Application.status EQ "dev">
		<cfdump var="#Request.page.getCatches()#" label="Catches">
		<cfdump var="#Request#" label="Request">
	</cfif>
	<cfelse>
	<p>Forefront Page Not Found (#myurl.file#)</p>
</cfif>
</body>
</html>
</cfoutput>
</cfif>
</cfprocessingdirective>