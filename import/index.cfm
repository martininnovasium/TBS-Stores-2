<cfprocessingdirective suppresswhitespace="yes" pageencoding="utf-8">
<cfsetting enablecfoutputonly="Yes" requesttimeout="300"/>

<cfset authorized = false/>
<cfif StructKeyExists(session,'ffuser') EQ true AND StructKeyExists(session.ffuser,'role_ids') EQ true>
	<cfif ListFind(session.ffuser.role_ids,'80EFAAF7-2F89-4B1F-8262-883573434A03') GT 0>
		<cfset authorized = true/>
	</cfif>
</cfif>
<cfif NOT authorized>
	<!---cfheader statuscode="401" statustext="Not Authorized"/--->
	<cfoutput>Not Authorized</cfoutput>
    <cfabort/>
</cfif>

<cfparam name="act" type="string" default=""/>
<cfparam name="update" type="string" default=""/>
<cfparam name="start" type="string" default=""/>
<cfparam name="end" type="string" default=""/>
<cfparam name="defaultcountry" type="string" default="Canada"/>
<cfparam name="debug" type="string" default=""/>
<cfparam name="importfile" type="string" default=""/>

<cfset update = Val(update)/>
<cfset start = Val(start)/>
<cfset end = Val(end)/>
<cfset debug = Val(debug)/>

<cfset collection_id = 2/>

<cfobject component="forefront_6.managers.article" name="Request.comArticle">
<cfinvoke component="#Request.comArticle#" method="init">
	<cfinvokeargument name="collection_id" value="#collection_id#">
</cfinvoke>

<cfobject component="forefront_6.components.address" name="comAddress">
<cfset comAddress.debugMode = debug/>
<cfinvoke component="#comAddress#" method="init">
</cfinvoke>

<cfset dsn = Request.comArticle.dsn/>

<cfquery name="selectApplicationRoles" datasource="#dsn#" cachedwithin="#CreateTimeSpan(0, 5, 0, 0)#">
	SELECT role_id, role, description
	FROM tbl_application_roles
</cfquery>

<cfquery name="selectArticleTags" datasource="#dsn#" cachedwithin="#CreateTimeSpan(0, 5, 0, 0)#">
	SELECT id, title
	FROM tbl_article_tag
	WHERE collection_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#collection_id#">
</cfquery>

<cfquery name="selectArticleCategorys" datasource="#dsn#" cachedwithin="#CreateTimeSpan(0, 5, 0, 0)#">
	SELECT id, name, title
	FROM tbl_article_category
	WHERE collection_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#collection_id#">
</cfquery>

<cfquery name="selectCountry" datasource="forefront" cachedwithin="#CreateTimeSpan(0, 30, 0, 0)#">
	SELECT *
	FROM tbl_geo_country
	ORDER BY name
</cfquery>

<cfset hours = ArrayNew(1)/>
<cfset ArrayAppend(hours,['Monday','hours_mon'])/>
<cfset ArrayAppend(hours,['Tuesday','hours_mon'])/>
<cfset ArrayAppend(hours,['Wednesday','hours_mon'])/>
<cfset ArrayAppend(hours,['Thursday','hours_mon'])/>
<cfset ArrayAppend(hours,['Friday','hours_mon'])/>
<cfset ArrayAppend(hours,['Saturday','hours_mon'])/>
<cfset ArrayAppend(hours,['Sunday','hours_mon'])/>

<cfset columns = ArrayNew(1)/>

<cfset ArrayAppend(columns, {'name'='date_created',					'proto'=Now(),			'length'=0,		'col'=''}) />
<cfset ArrayAppend(columns, {'name'='collection_id',				'proto'=collection_id,	'length'=0,		'col'=''}) />
<cfset ArrayAppend(columns, {'name'='name',							'proto'='',				'length'=255,	'col'=''}) />
<cfset ArrayAppend(columns, {'name'='title',						'proto'='',				'length'=255,	'col'=''}) />
<cfset ArrayAppend(columns, {'name'='excerpt',						'proto'='',				'length'=1000,	'col'=''}) />
<cfset ArrayAppend(columns, {'name'='html',							'proto'='',				'length'=0,		'col'='html',					'parser'='parseIntoHTML'}) />
<cfset ArrayAppend(columns, {'name'='image',						'proto'='',				'length'=255,	'col'='image'}) />
<cfset ArrayAppend(columns, {'name'='location',						'proto'='',				'length'=0,		'col'=''}) />
<cfset ArrayAppend(columns, {'name'='hits',							'proto'=0,				'length'=0,		'col'=''}) />
<cfset ArrayAppend(columns, {'name'='status',						'proto'=1,				'length'=0,		'col'=''}) />
<cfset ArrayAppend(columns, {'name'='meta',							'proto'=StructNew(),	'length'=0,		'col'=''}) />
<cfset ArrayAppend(columns, {'name'='meta.seo_keywords',			'proto'='',				'length'=0,		'col'='keywords'}) />
<cfset ArrayAppend(columns, {'name'='meta.seo_description',			'proto'='',				'length'=0,		'col'='description'}) />
<cfset ArrayAppend(columns, {'name'='meta.social_youtube',			'proto'='',				'length'=0,		'col'='youtube'}) />
<cfset ArrayAppend(columns, {'name'='meta.social_twitter',			'proto'='',				'length'=0,		'col'='twitter'}) />
<cfset ArrayAppend(columns, {'name'='meta.social_pinterest',		'proto'='',				'length'=0,		'col'='pinterest'}) />
<cfset ArrayAppend(columns, {'name'='meta.social_facebook',			'proto'='',				'length'=0,		'col'='facebook'}) />
<cfset ArrayAppend(columns, {'name'='meta.social_instagram',		'proto'='',				'length'=0,		'col'='instagram'}) />
<cfset ArrayAppend(columns, {'name'='meta.google_map_view',			'proto'='',				'length'=0,		'col'='google_map_view',		'parser'='parseURL'}) />
<cfset ArrayAppend(columns, {'name'='meta.google_structured_data',	'proto'='{}',			'length'=0,		'col'='hours_json'}) />
<cfset ArrayAppend(columns, {'name'='meta.hours_note',				'proto'='',				'length'=0,		'col'='hours_notes'}) />
<cfset ArrayAppend(columns, {'name'='meta.district',				'proto'='',				'length'=0,		'col'='district'}) />
<cfset ArrayAppend(columns, {'name'='meta.group',					'proto'='',				'length'=0,		'col'='group'}) />

<cfset articleTagsDefault = StructNew()/>
<cfset articleRolesDefault = StructNew()/>
<cfset articleCategorysDefault = StructNew()/>

<cfset articleRolesDefault['3381A07E-7A32-4F87-B88C-1B935ECB6710'] = ['PUBLIC','Public']/>

<!--- =========================== --->

<cffunction name="cleanField" returntype="string">
	<cfargument name="data" type="string"/>
	<cfargument name="type" type="string" default="string"/>
	
	<cfif type EQ "string">
	
		<cfset data = Trim(data)/>
		<cfset data = REReplace(data,'^"',"","one")/>
		<cfset data = REReplace(data,'"$',"","one")/>
	
	</cfif>
	<cfif type EQ "list">

		<cfset data = Trim(data)/>
		<cfset data = ListToArray(data,",",false)/>
		<cfloop from="1" to="#ArrayLen(data)#" index="ii">
			<cfset data[ii] = Trim(data[ii])/>
		</cfloop>
		<cfset data = ArrayToList(data,"#chr(10)#")/>
		
	</cfif>
	
	<cfreturn data/>
</cffunction>

<cffunction name="parseTiming" returntype="string">
	<cfargument name="data" type="string"/>

	<cfset data = REReplace(data,",","~","all")/>
	<cfset data = REReplace(data,";","~","all")/>
	<cfset data = REReplace(data,"#chr(10)#","~","all")/>
	<cfset data = REReplace(data,"#chr(11)#","~","all")/>
	<cfset data = REReplace(data,"#chr(12)#","~","all")/>
	<cfset data = REReplace(data,"#chr(13)#","~","all")/>
	<cfset data = REReplace(data,"–","-","all")/>
	
	<cfset data = ListToArray(data,"~",false)/>
	
	<cfset data = ArrayToList(data,"<br/>")/>

	<cfreturn data/>
</cffunction>

<cffunction name="parseURL" returntype="string">
	<cfargument name="data" type="string"/>
	
	<cfif data NEQ "" AND Left(data,4) NEQ "http">
		<cfset data = "http://" & data/>
	</cfif>
	
	<cfreturn data/>
</cffunction>

<cffunction name="cleanName" returntype="string">
	<cfargument name="data" type="string"/>
	
	<cfset data = Trim(LCase(data))/>
	<cfset data = REReplace(data, "http://[^/]*/" ,"", "all")/>
	
	<cfset data = Replace(data, "zh-hant" ,"", "all")/>
	
	<cfset tmp = ListToArray(data,"/",false)/>

	<cfif ArrayLen(tmp) EQ 2>
		<cfset data = tmp[2] & "_" & tmp[1]/>
		<cfset ArrayAppend(warn,"Name contains country/lang.")/>
	</cfif>
	
	<cfset data = REReplace(data, "[\w]{2}\-[\w]{2}/" ,"", "all")/>
	<cfset data = REReplace(data, "\s" ,"-", "all")/>
	<cfset data = REReplace(data, "[^\w\d\-\_]" ,"", "all")/>
	<!---cfset data = REReplace(data, "[\`\~\!\@\##\$\%\^\&\*\(\)\{\}\[\]\;\:\'\""\,\<\.\>\/\?]" ,"", "all")/--->
	<cfset data = REReplace(data, "[-]+" ,"-", "all")/>
	
	<cfreturn data/>
</cffunction>

<cffunction name="findApplicationRole" returntype="string">
	<cfargument name="data" type="string"/>
	<cfset var i = 0/>
	<cfset var r = 0/>
	
	<cfset data = cleanTagTitle(data)/>
	
	<cfloop from="1" to="#selectApplicationRoles.RecordCount#" index="i">
		<cfif data EQ selectApplicationRoles.role[i]>
			<cfset r = selectApplicationRoles.role_id[i]/>
			<cfbreak/>
		</cfif>
	</cfloop>
	
	<cfreturn r/>
</cffunction>

<cffunction name="findArticleTag" returntype="numeric">
	<cfargument name="data" type="string"/>
	<cfset var i = 0/>
	<cfset var r = 0/>
	
	<cfset data = cleanTagTitle(data)/>
	<cfloop from="1" to="#selectArticleTags.RecordCount#" index="i">
		<cfset data2 = cleanTagTitle(selectArticleTags.title[i])/>
		<cfif data EQ data2>
			<cfset r = selectArticleTags.id[i]/>
			<cfbreak/>
		</cfif>
	</cfloop>
	
	<cfreturn r/>
</cffunction>

<cffunction name="cleanTagTitle" returntype="string">
	<cfargument name="data" type="string"/>
	<cfset data = Replace(data,"Treatment:","","all")/>
	<cfset data = Replace(data,"Product:","","all")/>
	<cfset data = Trim(REReplace(data,"[^\w\s]","","all"))/>
	<cfreturn data/>
</cffunction>

<cfset firstParagraph = ""/>

<cffunction name="parseIntoHTML" returntype="string">
	<cfargument name="article" type="struct"/>
	<cfargument name="data" type="string"/>
	<cfset var t = ""/>
	<cfset var tmp = ""/>
	<cfset var tmpLen = 0/>
	<cfset var i = 0/>
	<cfset var b = "">
	<cfset var a = "">
	
	<cfset data = Replace(data,"#chr(10)#","#chr(13)#","all")/>
	
	<cfset firstParagraph = "" />

	<!---
<cfset data = Replace(data,"#chr(11)#","{11}","all")/>
<cfset data = Replace(data,"#chr(12)#","{12}","all")/>
	<cfset data = Replace(data,"#chr(13)#","{13}","all")/>
	--->
	
<cfif debug GT 1><cfoutput><textarea style="width:100%;height:200px;">#HTMLEditFormat(data)#</textarea><br></cfoutput></cfif>

	<cfset tmp = ListToArray(data,"#chr(13)#",true)/>
<cfif debug GT 1><cfoutput><cfdump var="#tmp#" label="Before" expand="no"/></cfoutput></cfif>

	<cfset tmpLen = ArrayLen(tmp)/>

	<!--- clean --->	
	<cfloop from="1" to="#tmpLen#" index="i">
		<cfset tmp[i] = Trim(tmp[i])/>
		<cfif tmp[i] EQ "&nbsp;" OR tmp[i] EQ "andnbsp;">
			<cfset tmp[i] = "" />
		</cfif>
		<cfset tmp[i] = Replace(tmp[i], "&nbsp;", " ", "all")/>
	</cfloop>

			
	<cfloop from="1" to="#tmpLen#" index="i">
		<cfset t = tmp[i]/>
<cfif debug GT 1><cfoutput>[#i#] [#HTMLEditFormat(t)#] [#Asc(Mid(t,1,1))#,#Asc(Mid(t,2,1))#,#Asc(Mid(t,3,1))#]</cfoutput></cfif>
		<cfif t NEQ "" AND Left(t,1) NEQ "<">
<cfif debug GT 1><cfoutput>A</cfoutput></cfif>
			<cfset b = "">
			<cfset a = "">
			<cfif (i+1) LTE tmpLen AND tmp[i+1] NEQ "">
				<cfset a = tmp[i+1]/>
			</cfif>
			<cfif (i-1) GT 0 AND tmp[i-1] NEQ "">
				<cfset b = tmp[i-1]/>
			</cfif>
			
			<!---
			<cfif b NEQ "">
				<cfset tmp[i] = t & "<br/>"/>
			<cfelse>
				<cfif a NEQ "">
					<cfset tmp[i] = t & "<br/>"/>
				<cfelse>
			--->				
					<cfset tmp[i] = "<p>" & t & "</p>"/>
			<!---					
				</cfif>
			</cfif>
			--->
			
			<cfif firstParagraph EQ "">
<cfif debug GT 1><cfoutput>B [#t#]</cfoutput></cfif>
				<cfset firstParagraph = REReplace(t, "<[^>]*>", " ", "all") />
			</cfif>
		</cfif>
<cfif debug GT 1><cfoutput><br></cfoutput></cfif>
	</cfloop>
<!---
<cfif debug GT 1><cfoutput><cfdump var="#tmp#" label="After" expand="no"/></cfoutput></cfif>
--->
	<cfset data = ArrayToList(tmp,"#chr(13)#")/>
<!---	
<cfif debug GT 1><cfoutput><div style="border:1px solid ##000000">#data#</div></cfoutput></cfif>
--->

	<cfreturn data/>
</cffunction>

<cffunction name="parseTitle" returntype="void">
	<cfargument name="article" type="struct"/>
	<cfargument name="data" type="string"/>
	
	<cfif debug><cfoutput><div>parseTitle({},'#data#')</div></cfoutput></cfif>

	<cfif article.title NEQ data>
		<cfset ArrayAppend(dif, "title [#article.title#] &gt; [#data#]")/>
		<cfset articleAction = ListAppend(articleAction, "title")/>
		<cfset article.title = data/>
	</cfif>
		
	<cfset article.title = data/>
	
</cffunction>

<cffunction name="parseZone" returntype="void">
	<cfargument name="article" type="struct"/>
	<cfargument name="data" type="string"/>
	<cfset var i = 0/>
	<cfset var found = false/>
	
	<cfif debug><cfoutput><div>parseZone({},'#data#')</div></cfoutput></cfif>
	
	<cfloop from="1" to="#selectApplicationRoles.RecordCount#" index="i">
		<cfif selectApplicationRoles.role[i] EQ data>
			<cfif StructKeyExists(articleRoles,selectApplicationRoles.role_id[i]) EQ false>
				<cfset ArrayAppend(dif, "zone")/>
				<cfset articleAction = ListAppend(articleAction, "zone")/>
				<cfset articleRoles[selectApplicationRoles.role_id[i]] = [selectApplicationRoles.role[i],selectApplicationRoles.description[i]]/>
			</cfif>
			<cfset found = true/>
		</cfif>
	</cfloop>

	<cfif found EQ false>
		<cfset ArrayAppend(error, "Zone not found [#data#]")/>
	</cfif>
	
</cffunction>

<cffunction name="parseSite" returntype="void">
	<cfargument name="article" type="struct"/>
	<cfargument name="data" type="string"/>
	<cfset var i = 0 />
	<cfset var found = false/>
	
	<cfif debug><cfoutput><div>parseSite({},'#data#')</div></cfoutput></cfif>

	<cfif data EQ "redapple">
		<cfset data = "ra"/>
	</cfif>
	
	<cfloop from="1" to="#selectApplicationRoles.RecordCount#" index="i">
		<cfif selectApplicationRoles.role[i] EQ data>
			<cfif StructKeyExists(articleRoles,selectApplicationRoles.role_id[i]) EQ false>
				<cfset ArrayAppend(dif, "site")/>
				<cfset articleAction = ListAppend(articleAction, "site")/>
				<cfset articleRoles[selectApplicationRoles.role_id[i]] = [selectApplicationRoles.role[i],selectApplicationRoles.description[i]]/>
			</cfif>
			<cfset found = true/>
		</cfif>
	</cfloop>

	<cfif found EQ false>
		<cfset ArrayAppend(error, "Site not found [#data#]")/>
	</cfif>
		
</cffunction>

<cffunction name="cleanExcerpt" returntype="string">
	<cfargument name="data" type="string"/>
	<cfset data = Replace(data, "&nbsp;", " ", "all")/>
	<cfset data = Replace(data, "&amp;", "&", "all")/>
	<cfset data = REReplace(data, "<[^>]*>", " ", "all")/>
	<cfset data = REReplace(data, "  ", " ", "all")/>
	<cfset data = Trim(data)/>
	<cfreturn data/>
</cffunction>

<cffunction name="cleanGeo" returntype="string">
	<cfargument name="data" type="string"/>
	
	<cfif debug><cfoutput><div>cleanGeo('#data#')</div></cfoutput></cfif>
	
	<cfif data EQ "">	
		<cfset data = 0/>
	</cfif>
	<cfset var t = ListToArray(data,".")/>
	<cfif ArrayLen(t) GT 1>
		<cfset data = t[1] & "." & Left(t[2],6)/>
	</cfif>
	<cfreturn data/>
</cffunction>

<cffunction name="convertTime24" returntype="string">
	<cfargument name="data" type="string"/>
	<!--- Convert AM/PM to 24H --->
	<cfreturn data/>
</cffunction>

<cffunction name="getColumn" returntype="string">
	<cfargument name="name" type="string"/>
	<cfargument name="i" type="numeric"/>
	<cfset var data = ""/>
	<cfif StructKeyExists(spreadsheet,name)>
		<cfset data = cleanField(spreadsheet[name][i])/>
	</cfif>
	<cfreturn data/>
</cffunction>

<!--- =========================== --->

<cfoutput>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Store Import</title>
<script src='/lib/js/jquery/1.10.2/jquery-1.10.2.min.js' type='text/javascript'></script>
<style>
td {text-align: left;vertical-align: top}
.err {color:##FFFFFF;background-color:##FF0000;}
.ok {color:##00B103;}
.warn {background-color:##FCCD44;}
.dif { white-space: pre;}
.nam,
.rep {
	white-space: nowrap;
}
.rep div {margin-bottom: 5px;}
</style>
<script language="javascript">
$(document).ready(function(){
	var hidetogle = false;
	$("##hideok").click(function(){
		if (!hidetogle) {
			$("tbody tr").each(function(i){
				if ($(this).find("td .warn").length>0 || $(this).find("td .err").length>0) {
				} else {
					$(this).hide();
				}
			});
		} else {
			$("tbody tr").each(function(i){
				$(this).show();
			});
		}

		hidetogle = !hidetogle;
	});
	
	$("select[name=importfile]").change(function(){
		var v = $(this).val();
		v = v.split(".");
		v = $.trim(v[0].substr(-2,2));
		console.log(v);
		if (v) {
			var obj = $("select[name=defaultcountry] option[data-a2="+v+"]");
			if (obj.length>0) {
				$("select[name=defaultcountry] option").prop("selected",false);
				obj.prop("selected",true);
			}
		}
	});

});
</script>
</head>

<body>
<div id="hideok" style="float:right;width:auto;cursor: pointer;">Hide OK</div>
	
<form method="get">
	<div><label>Start:</label><input type="number" name="start" value="#start#"/></div>
	
	<div><label>End:</label><input type="number" name="end" value="#end#"/></div>

	<div><label>File:</label>
		<cfdirectory action="LIST" directory="#ExpandPath('./')#" name="dirlist" filter="*.xlsx"/>
		<select name="importfile" data-path="#ExpandPath('./')#">
			<option value=""<cfif importfile EQ ""> selected</cfif>></option>
			<cfloop from="1" to="#dirlist.RecordCount#" index="i">
			<option value="#dirlist.name[i]#"<cfif importfile EQ dirlist.name[i]> selected</cfif>>#dirlist.name[i]# (#dirlist.size[i]#)</option>
			</cfloop>
		</select>
	</div>

	<div><label>Country:</label><select name="defaultcountry">
		<option value=""<cfif defaultcountry EQ ""> selected</cfif>>-Auto-</option>
		<cfloop from="1" to="#selectCountry.RecordCount#" index="i">
		<option data-a2="#selectCountry.a2[i]#" value="#selectCountry.name[i]#"<cfif defaultcountry EQ selectCountry.name[i]> selected</cfif>>#selectCountry.name[i]# (#selectCountry.a2[i]#)</option>
		</cfloop>
		<!---
		<option value="Canada"<cfif defaultcountry EQ "Canada"> selected</cfif>>Canada</option>
		<option value="United States"<cfif defaultcountry EQ "United States"> selected</cfif>>United States</option>
		<option value="Australia"<cfif defaultcountry EQ "Australia"> selected</cfif>>Australia</option>
		--->
	</select></div>
		
	<div><label>Update:</label><select name="update">
		<option value="0"<cfif update EQ 0> selected</cfif>>No</option>
		<option value="1"<cfif update EQ 1> selected</cfif>>Yes</option>
	</select></div>
	
	<div><label>Debug:</label><select name="debug">
		<option value="0"<cfif debug EQ 0> selected</cfif>>No</option>
		<option value="1"<cfif debug EQ 1> selected</cfif>>Yes, level 1</option>
		<option value="2"<cfif debug EQ 2> selected</cfif>>Yes, level 2</option>
	</select></div>
	
	<button type="submit" name="act" value="go">Import</button>
	<button type="submit" name="act" value="test">Test</button>
</form>

<cfif act NEQ "" AND importfile NEQ "">

	<cfspreadsheet action="read" src="#importfile#" query="spreadsheet" headerrow="1" />

   	<!---
    <cfquery name="spreadsheet" dbtype="query"> 
        SELECT *
        FROM spreadsheet
    </cfquery> 
    --->
    
	<cfif debug>
		<cfdump var="#spreadsheet#" expand="no" />
	</cfif>
	<cfif debug EQ 2>
		<cfdump var="#selectApplicationRoles#" label="selectApplicationRoles" expand="no"/>
		<cfdump var="#selectArticleCategorys#" label="selectArticleCategorys" expand="no"/>
		<cfdump var="#selectArticleTags#" label="selectArticleTags" expand="no"/>
		<cfdump var="#selectCountry#" label="selectCountry" expand="no"/>
	</cfif>

	<cfset cnt = 1/>
	<cfset flushCnt = 1/>
	<cfset namesFound = StructNew()/>

	<cfif start EQ 0>
		<cfset start = 2/>
	</cfif>	
	<cfif end EQ 0 OR end GT spreadsheet.RecordCount>
		<cfset end = spreadsheet.RecordCount/>
	</cfif>	
	
	<table id="list" width="100%" border="1" cellpadding="0" cellspacing="0">
		<thead>
		<tr>
			<th>Row##</th>
			<th class="nam">Name</th>
			<th>Action</th>
			<th class="dif">Dif</th>
			<th class="rep">Report</th>
		</tr>
		</thead>
		<tbody>
	<cfloop from="#start#" to="#end#" index="i">
		<tr>
			<cfset error = ArrayNew(1)/>
			<cfset warn = ArrayNew(1)/>
			<cfset message = ArrayNew(1)/>
			<cfset dif = ArrayNew(1)/>
			
			<cfset firstProduct = ""/>
			<cfset locationAction = ""/>
			<cfset articleAction = ""/>

			<cfset articleObj = StructNew()/>
			<cfset locationObj = StructNew()/>
			
			<cfset articleTags = Duplicate(articleTagsDefault)/>
			<cfset articleRoles = Duplicate(articleRolesDefault)/>
			<cfset articleCategorys = Duplicate(articleCategorysDefault)/>
				
			<td>#i#</td>
		
			<!--- Process name --->

			<cfset article_id = 0/>
			<cfset article_name = ""/>
			
			<td class="nam">
			
			<cfset article_name = cleanName(getColumn('store_id',i))/>


			
				<a href="/store/#article_name#/" target="_blank">#article_name#</a>
			</td>

			<td>
				<div style="max-width:1000px;overflow:auto;">
				<ul>

			<cfif ArrayLen(error) EQ 0>
				<cfif getColumn('address',i) EQ "address">
				<li>Error: Ignore Row</li>
					<cfset ArrayAppend(error,"Ignore Row")/>
				</cfif>
			</cfif>

			<cfif ArrayLen(error) EQ 0>
				<cfif article_name NEQ "" AND StructKeyExists(namesFound, article_name) EQ true>
				<li>Warn: Name allready used on [#namesFound[article_name]#]</li>
					<cfset ArrayAppend(warn,"Name allready used on [#namesFound[article_name]#]")/>
				</cfif>
			</cfif>
			
			<cfif article_name NEQ "">
				<cfset namesFound[article_name] = i/>
			</cfif>
			
			<cfif article_name EQ "">
				<li>Error: No Name</li>
				<cfset ArrayAppend(error,"No Name")/>
			</cfif>

			<!--- Process Address --->
			<cfif ArrayLen(error) EQ 0>
					<li>Process Address<br/>

				<!--- Process address --->
				<cfset addressParsed = StructNew()/>
				<cfset addressParsed.address = getColumn('address',i)/>
				<cfset addressParsed.City = getColumn('city',i)/>
				<cfset addressParsed.ProvState = getColumn('province',i)/>
				<cfset addressParsed.Country = getColumn('country',i)/>
				<cfset addressParsed.PostalZip = getColumn('postal',i)/>
				
						<table border="1" cellpadding="0" cellspacing="0">
							<tr><th>Address</th><td>#addressParsed.address#</td></tr>
							<tr><th>City</th><td>#addressParsed.City#</td></tr>
							<tr><th>ProvState</th><td>#addressParsed.ProvState#</td></tr>
							<tr><th>Country</th><td>#addressParsed.Country#</td></tr>
							<tr><th>Postal</th><td>#addressParsed.PostalZip#</td></tr>
						</table>
					</li>
			</cfif>

			<!--- Process Location --->
			<cfif ArrayLen(error) EQ 0>
					<li>Process Location<br/>
				
				<cfif addressParsed.address NEQ "">

					<cfif addressParsed.city EQ "">
						<cfset ArrayAppend(warn,"No City")/>
					</cfif>
				
					<cfquery name="selectLocation" datasource="#dsn#">
						SELECT
							*
						FROM tbl_location
						WHERE
							address = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#addressParsed.address#" />
							AND
							city = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#addressParsed.city#" />
							AND
							country = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#addressParsed.country#" />
					</cfquery>
					<cfif selectLocation.RecordCount GT 0>
						<cfloop list="#selectLocation.columnList#" index="r">
							<cfset locationObj[r] = selectLocation[r][1]/>
						</cfloop>
						
						<cfif debug>
							<cfdump var="#locationObj#" label="locationObj" expand="no" />
						</cfif>
						
					<cfelse>
						<cfloop list="#selectLocation.columnList#" index="r">
							<cfset locationObj[r] = ""/>
							<cfif r EQ "ID"><cfset locationObj[r] = 0/></cfif>
						</cfloop>
						<cfset locationAction = "new"/>
					</cfif>

				<cfelse>

					<cfset ArrayAppend(error,"No Address")/>
				</cfif>
					</li>
			</cfif>

			<!--- Process Article Name --->
			<cfif ArrayLen(error) EQ 0>
					<li>Process Article Name<br/>
					[#article_name#]
				<cfquery name="selectArticle" datasource="#dsn#"><!--- cachedwithin="#CreateTimeSpan(0,0,0,0)#"--->
					SELECT TOP 1
						id
					FROM tbl_article
					WHERE
						collection_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#collection_id#">
						AND
						name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#article_name#">
				</cfquery>

				<cfif debug>
					<cfdump var="#selectArticle#" label="selectArticle" expand="no" />
				</cfif>
					
				<cfif selectArticle.RecordCount GT 0>
					<cfset article_id = selectArticle.id[1]/>
					[#article_id#]
				</cfif>
				
					</li>
			</cfif>

			<!--- Process Article Roles --->
			<cfif ArrayLen(error) EQ 0>
				<cfif article_id GT 0>
					<li>Process Article Roles<br/>

					<cfquery name="selectArticleRoles" datasource="#dsn#">
						SELECT
							ar.role_id, ar.role, ar.description
						FROM
							tbl_article_article_x_role AS axr
							LEFT JOIN tbl_application_roles AS ar ON ar.role_id = axr.role_id
						WHERE
							axr.article_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#article_id#">
					</cfquery>

					<cfif debug>
						<cfdump var="#selectArticleRoles#" label="selectArticleRoles" expand="no" />
					</cfif>
					
					<cfif selectArticleRoles.RecordCount GT 0>
						<cfset articleRoles = StructNew()/>
						<cfloop from="1" to="#selectArticleRoles.RecordCount#" index="r">
							<cfset articleRoles[selectArticleRoles.role_id[r]] = [selectArticleRoles.role[r],selectArticleRoles.description[r]]/>
						</cfloop>
					</cfif>

					</li>
				</cfif>
			</cfif>
				
			<!--- Process Article Categories --->
			<cfif ArrayLen(error) EQ 0>
				<cfif article_id GT 0>
					<li>Process Article Categories<br/>

					<cfquery name="selectArticleCategorys" datasource="#dsn#">
						SELECT
							ac.id, ac.name, ac.title
						FROM
							tbl_article_article_x_category AS axc
							LEFT JOIN tbl_article_category AS ac ON ac.id = axc.category_id
						WHERE
							axc.article_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#article_id#">
					</cfquery>

					<cfif debug>
						<cfdump var="#selectArticleCategorys#" label="selectArticleCategorys" expand="no" />
					</cfif>
					
					<cfif selectArticleCategorys.RecordCount GT 0>
						<cfset articleCategorys = StructNew()/>
						<cfloop from="1" to="#selectArticleCategorys.RecordCount#" index="r">
							<cfset articleCategorys[selectArticleCategorys.id[r]] = [selectArticleCategorys.name[r],cleanTagTitle(selectArticleCategorys.title[r])] />
						</cfloop>
					</cfif>

					</li>
				</cfif>
			</cfif>
									
			<!--- Process Article Tags --->
			<cfif ArrayLen(error) EQ 0>
				<cfif article_id GT 0>
					<li>Process Article Tags<br/>

					<cfquery name="selectArticleTags" datasource="#dsn#">
						SELECT
							t.id, t.title
						FROM
							tbl_article_article_x_tag AS axt
							LEFT JOIN tbl_article_tag AS t ON t.id = axt.tag_id
						WHERE
							axt.article_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#article_id#">
					</cfquery>

					<cfif debug>
						<cfdump var="#selectArticleTags#" label="selectArticleTags" expand="no" />
					</cfif>

					<cfif selectArticleTags.RecordCount GT 0>
						<cfset articleTags = StructNew()/>
						<cfloop from="1" to="#selectArticleTags.RecordCount#" index="r">
							<cfset articleTags[selectArticleTags.id[r]] = [cleanTagTitle(selectArticleTags.title[r])] />
						</cfloop>
					</cfif>

					</li>
				</cfif>
			</cfif>
		
			<!--- Process Article --->
			<cfif ArrayLen(error) EQ 0>
					<li>Process Article<br/>
					[#article_id#]

				<cftry>
					
					<cfquery name="selectArticle" datasource="#dsn#"><!--- cachedwithin="#CreateTimeSpan(0,0,0,0)#"--->
						SELECT *
						FROM tbl_article
						WHERE 
						<cfif article_id GT 0>
							id = <cfqueryparam cfsqltype="cf_sql_integer" value="#article_id#">
						<cfelse>
							1=2
						</cfif>
					</cfquery>

					<cfif debug>
						<cfdump var="#selectArticle#" label="selectArticle" expand="no" />
					</cfif>

					<cfif selectArticle.RecordCount GT 0>
						<cfloop list="#selectArticle.columnList#" index="r">
							<cfif r EQ "META">
								<cfset articleObj[r] = DeserializeJSON(selectArticle[r][1])/>
							<cfelse>
								<cfset articleObj[r] = selectArticle[r][1]/>
							</cfif>
						</cfloop>
					<cfelse>
						<cfloop list="#selectArticle.columnList#" index="r">
							<cfset articleObj[r] = ""/>
							<cfif r EQ "ID"><cfset articleObj[r] = 0/></cfif>
							<cfif r EQ "name"><cfset articleObj[r] = article_name/></cfif>
							<cfif r EQ "COLLECTION_ID"><cfset articleObj[r] = collection_id/></cfif>
							<cfif r EQ "META"><cfset articleObj[r] = StructNew()/></cfif>
							<cfif r EQ "STATUS"><cfset articleObj[r] = 1/></cfif>
							<cfif r EQ "HITS"><cfset articleObj[r] = 0/></cfif>
							<cfif r EQ "DATE_CREATED"><cfset articleObj[r] = Now()/></cfif>
						</cfloop>
						<cfset articleAction = "new"/>
					</cfif>		
					
					<cfcatch>
						<cfset ArrayAppend(error, cfcatch.detail)/>
						<cfif debug>
							<cfdump var="#cfcatch#" label="cfcatch" expand="no"/>
						</cfif>
					</cfcatch>
				</cftry>
			</cfif>

			<!--- Process Location --->
			<cfif ArrayLen(error) EQ 0>
					<li>Set Location<br/>
				<cftry>
																								
					<!--- Location.Location --->
					<cfif locationObj.id EQ 0>
						<!--- New location --->
						<cfset locationObj.date_created = Now()/>
						<cfset locationObj.status = 1/>
						<cfset locationObj.location_type = 3/>
						<cfset locationObj.html = ""/>
						<cfset locationObj.address = addressParsed.address/>
						<cfset locationObj.city = addressParsed.city/>
						<cfset locationObj.provstate = addressParsed.provstate/>
						<cfset locationObj.postalzip = addressParsed.postalzip/>
						<cfset locationObj.country = addressParsed.country/>
						<cfset locationObj.fax = ""/>
					</cfif>

					<cfset tmp = getColumn('phone',i)/>
					<cfif tmp NEQ "" AND tmp NEQ locationObj.phone>
						<cfset ArrayAppend(dif, "phone [#locationObj.phone#] &gt; [#tmp#]")/>
						<cfset locationObj.phone = Left(tmp,50)/>
						<cfset locationAction = ListAppend(locationAction,"phone")/>
					</cfif>

					<cfset tmp = getColumn('email',i)/>
					<cfif tmp NEQ "" AND tmp NEQ locationObj.email>
						<cfset ArrayAppend(dif, "email [#locationObj.email#] &gt; [#tmp#]")/>
						<cfset locationObj.email = Left(tmp,255)/>
						<cfset locationAction = ListAppend(locationAction,"email")/>
					</cfif>

					<cfset tmp = parseURL(getColumn('website',i))/>
					<cfif tmp NEQ "" AND tmp NEQ locationObj.website>
						<cfset ArrayAppend(dif, "website [#locationObj.website#] &gt; [#tmp#]")/>
						<cfset locationObj.website = Left(tmp,255)/>
						<cfset locationAction = ListAppend(locationAction,"website")/>
					</cfif>

					<cfset tmp = cleanGeo(getColumn('latitude',i))/>
					<cfif tmp NEQ "" AND tmp NEQ locationObj.lat>
						<cfset ArrayAppend(dif, "lat [#locationObj.lat#] &gt; [#tmp#]")/>
						<cfset locationObj.lat = tmp/>
						<cfset locationAction = ListAppend(locationAction,"lat")/>
					</cfif>

					<cfset tmp = cleanGeo(getColumn('longitude',i))/>
					<cfif tmp NEQ "" AND tmp NEQ locationObj.lon>
						<cfset ArrayAppend(dif, "lon [#locationObj.lon#] &gt; [#tmp#]")/>
						<cfset locationObj.lon = tmp/>
						<cfset locationAction = ListAppend(locationAction,"lon")/>
					</cfif>

					<cfif debug>
						<cfdump var="#locationObj#" label="locationObj" expand="no"/>
					</cfif>
				
					<cfcatch>
						<cfset ArrayAppend(error, cfcatch.detail)/>
						<cfif debug>
							<cfdump var="#cfcatch#" label="cfcatch" expand="no"/>
						</cfif>
					</cfcatch>
				</cftry>
					</li>																								
			</cfif>
					
			<!--- Process Columns --->
			<cfif ArrayLen(error) EQ 0>
					<li>Process Columns<br/>
				<cftry>
									
					<!--- Build articleObj --->
					<cfif debug><ul></cfif>
					<cfloop from="1" to="#ArrayLen(columns)#" index="c">
						<cfset column = columns[c] />
						<cfif debug><li>[#c#] column:</cfif>

						<cfif debug>column.name=[#column.name#]</cfif>

						<cfif Left(column.name,5) EQ "meta.">

							<cfset name = Mid(column.name,6,99)/>

						<cfif debug>name=[#name#]</cfif>

							<cfif StructKeyExists(articleObj.meta,name) EQ false>
								<cfset articleObj.meta['#name#'] = Duplicate(column.proto)/>
							</cfif>

						<cfif debug>column.col=[#column.col#]</cfif>

							<cfif column.col NEQ "">
								<cfset tmp = getColumn(column.col,i)/>
<cfif debug>
<cfdump var="#tmp#" label="tmp"/>
<cfdump var="#articleObj.meta[name]#" label="articleObj.meta[name]"/>
</cfif>								
								<cfif tmp NEQ articleObj.meta[name]>
									<cfset ArrayAppend(dif, "#column.name# [#articleObj.meta[name]#] &gt; [#tmp#]")/>
									<cfset articleObj.meta[name] = tmp/>
									<cfset articleAction = ListAppend(articleAction, column.name)/>
								</cfif>

								<cfif column.length GT 0>
									<cfif Len(articleObj.meta[name]) GT 255>
										<cfset articleObj.meta[name] = Left(articleObj.meta[name], column.length)>
										<cfset ArrayAppend(warn,"#column.name# was cropped to #column.length#")/>
									</cfif>
								</cfif>

							</cfif>

						<cfelse>

							<cfset name = column.name/>

						<cfif debug>name=[#name#]</cfif>

							<cfif StructKeyExists(articleObj,name) EQ false>
								<cfset articleObj['#name#'] = Duplicate(column.proto)/>
							</cfif>

						<cfif debug>column.col=[#column.col#]</cfif>

							<cfif column.col NEQ "">
								<cfset tmp = getColumn(column.col,i)/>

								<cfif tmp NEQ articleObj[name]>
									<cfset ArrayAppend(dif, "#name# [#articleObj[name]#] &gt; [#tmp#]")/>
									<cfset articleObj[name] = tmp/>
									<cfset articleAction = ListAppend(articleAction, name)/>
								</cfif>

								<cfif column.length GT 0>
									<cfif Len(articleObj[name]) GT 255>
										<cfset articleObj[name] = Left(articleObj[name], column.length)>
										<cfset ArrayAppend(warn,"#name# was cropped to #column.length#")/>
									</cfif>
								</cfif>

							</cfif>

						</cfif>

						<cfif debug></li></cfif>
					</cfloop>
					<cfif debug></ul></cfif>

					<cfcatch>
						<cfset ArrayAppend(error, cfcatch.detail)/>
						<cfif debug>
							<cfdump var="#cfcatch#" label="cfcatch" expand="no"/>
						</cfif>
					</cfcatch>
				</cftry>
					</li>																								
			</cfif>
											
			<!--- Process Custom --->
			<cfif ArrayLen(error) EQ 0>
					<li>Process Custom<br/>
							
				<cftry>
					
					<!---cfset tmp = getColumn('address',i) & ", " & getColumn('city',i)/--->
					<cfset tmp2 = articleObj.title/>
					<cfset tmp = getColumn('city',i)/>
					Title=[#tmp#]<br/>
					<cfset parseTitle(articleObj, tmp)/>
				
					<cfset tmp = getColumn('zone',i)/>
					Zone=[#tmp#]<br/>
					<cfset parseZone(articleObj, tmp)/>

					<cfset tmp = getColumn('site',i)/>
					Site=[#tmp#]<br/>
					<cfset parseSite(articleObj, tmp)/>

					<cfif articleObj.meta.google_map_view EQ "no picture">
						<cfset articleObj.meta.google_map_view = ""/>
					</cfif>

					<!--- Build google_structured_data --->

					<cfset tmp = articleObj.meta.google_structured_data/>
					<cfif IsSimpleValue(tmp)>
						<cfset tmp = DeserializeJSON(tmp)/>
					</cfif>

					<cfif StructKeyExists(tmp,'@context') EQ false>
						<cfset tmp['@context'] = "http://schema.org"/>
					</cfif>
					<cfif StructKeyExists(tmp,'@type') EQ false>
						<cfset tmp['@type'] = "Store"/>
					</cfif>
					<cfif StructKeyExists(tmp,'name') EQ false>
						<cfset tmp['name'] = articleObj.title/>
					</cfif>

					<cfif StructKeyExists(tmp,'address') EQ false>
						<cfset tmp['address'] = StructNew()/>
					</cfif>
					<cfif StructKeyExists(tmp.address,'@type') EQ false>
						<cfset tmp.address['@type'] = "PostalAddress"/>
					</cfif>
					<cfif StructKeyExists(tmp.address,'streetAddress') EQ false>
						<cfset tmp.address['streetAddress'] = addressParsed.address/>
					</cfif>
					<cfif StructKeyExists(tmp.address,'addressLocality') EQ false>
						<cfset tmp.address['addressLocality'] = addressParsed.city/>
					</cfif>
					<cfif StructKeyExists(tmp.address,'addressRegion') EQ false>
						<cfset tmp.address['addressRegion'] = addressParsed.provstate/>
					</cfif>
					<cfif StructKeyExists(tmp.address,'postalCode') EQ false>
						<cfset tmp.address['postalCode'] = addressParsed.postalzip/>
					</cfif>
					<cfif StructKeyExists(tmp.address,'addressCountry') EQ false>
						<cfset tmp.address['addressCountry'] = "CA"/>
					</cfif>

					<cfif locationObj.lat NEQ 0 AND locationObj.lon NEQ 0>
						<cfif StructKeyExists(tmp,'geo') EQ false>
							<cfset tmp['geo'] = StructNew()/>
						</cfif>
						<cfif StructKeyExists(tmp.geo,'latitude') EQ false>
							<cfset tmp.geo['latitude'] = locationObj.lat/>
						</cfif>
						<cfif StructKeyExists(tmp.geo,'longitude') EQ false>
							<cfset tmp.geo['longitude'] = locationObj.lon/>
						</cfif>
					<cfelse>
						<cfif StructKeyExists(tmp,'geo') EQ true>
							<cfset StructDelete(tmp,'geo')/>
						</cfif>
					</cfif>

					<cfif StructKeyExists(tmp,'url') EQ false>
						<cfset tmp2 = getColumn('site',i)/>
						<cfif tmp2 EQ "tbs">
							<cfset tmp['url'] = "http://www.tbsstores.com/store/" & articleObj.name & "/"/>
						</cfif>
						<cfif tmp2 EQ "ra" OR tmp2 EQ "redapple">
							<cfset tmp['url'] = "http://www.redapplestores.com/store/" & articleObj.name & "/"/>
						</cfif>
					</cfif>

					<cfif locationObj.phone NEQ "">
						<cfif StructKeyExists(tmp,'telephone') EQ false>
							<cfset tmp['telephone'] = locationObj.phone/>
						</cfif>
					<cfelse>
						<cfif StructKeyExists(tmp,'telephone') EQ true>
							<cfset StructDelete(tmp,'telephone')/>
						</cfif>
					</cfif>

					<cfset tmp = SerializeJSON(tmp)/>
					
					<cfif tmp NEQ articleObj.meta.google_structured_data>
						<cfset ArrayAppend(dif, "meta.google_structured_data [] &gt; [#tmp#]")/>
						<cfset articleObj.meta.google_structured_data = tmp/>
						<cfset articleAction = ListAppend(articleAction, "meta.google_structured_data")/>
					</cfif>
					
					<!---
					<cfif StructKeyExists(articleObj.meta.google_structured_data,'openingHoursSpecification') EQ false>
						<cfset articleObj.meta.google_structured_data['openingHoursSpecification'] = ArrayNew(1)/>
					</cfif>

					<cfloop from="1" to="#ArrayLen(hours)#" index="h">
						<cfset tmp = StructNew()/>
						<cfset tmp['@type'] = "OpeningHoursSpecification"/>
						<cfset tmp['dayOfWeek'] = ArrayNew(1)/>
						<cfset ArrayAppend(tmp['dayOfWeek'], hours[h][1])/>

						<cfset tmp2 = parseTiming(cleanField(spreadsheet['#hours[h][2]#'][i]))/>
						<cfset tmp2 = Replace(tmp2, " to ",",","one")/>
						<cfif ListLen(tmp2,",") GT 1>
							<cfset tmp['opens'] = convertTime24(ListFirst(tmp2,","))/>
							<cfset tmp['closes'] = convertTime24(ListLast(tmp2,","))/>
							<cfset ArrayAppend(articleObj.meta.google_structured_data['openingHoursSpecification'], tmp)/>
						</cfif>
					</cfloop>

					<cfif debug>
						<cfdump var="#articleObj.meta.google_structured_data#" label="articleObj.meta.google_structured_data" expand="no" />
					</cfif>

					<cfset articleObj.meta.google_structured_data = SerializeJSON(articleObj.meta.google_structured_data)/>
					--->
										
					<cfcatch>
						<cfset ArrayAppend(error, cfcatch.detail)/>
						<cfif debug>
							<cfdump var="#cfcatch#" label="cfcatch" expand="no"/>
						</cfif>
					</cfcatch>
				</cftry>
					</li>																								
			</cfif>		
			

			
			<!--- Validate --->
			<cfif ArrayLen(error) EQ 0>
					<li>Validate<br/>
							
				<cftry>
												
					<!--- Validate --->
					<cfif Len(locationObj.address) GT 255>
						<cfset ArrayAppend(error, "Address is long")/>
					</cfif>

					<cfif locationObj.lon EQ 0>
						<cfset ArrayAppend(error, "No Lat/Lon")/>
					</cfif>

					<cfif StructCount(articleRoles) EQ 0>
						<cfset ArrayAppend(warn, "No Article Roles")/>
					</cfif>
					<cfif StructCount(articleCategorys) EQ 0>
						<cfset ArrayAppend(warn, "No Article Categories")/>
					</cfif>
					<cfif StructCount(articleTags) EQ 0>
						<cfset ArrayAppend(warn, "No Article Tags")/>
					</cfif>

					<cfcatch>
						<cfset ArrayAppend(error, cfcatch.detail)/>
						<cfif debug>
							<cfdump var="#cfcatch#" label="cfcatch" expand="no"/>
						</cfif>
					</cfcatch>
				</cftry>
					</li>																								
					
			</cfif>

			<cfif debug>
				<cfdump var="#articleObj#" label="articleObj" expand="no"/>
				<cfdump var="#articleRoles#" label="articleRoles" expand="no"/>
				<cfdump var="#articleCategorys#" label="articleCategorys" expand="no"/>
				<cfdump var="#articleTags#" label="articleTags" expand="no"/>
			</cfif>

			<!--- Process Completed --->
			<cfif ArrayLen(error) EQ 0>
				
				<cfset ArrayAppend(message, "Process Completed")/>

				<cfif act NEQ "test">
				
						<li>Save<br/>

				articleAction=[#articleAction#]<br/>
				locationAction=[#locationAction#]<br/>

				<!--- Save Location --->
				<cfif locationAction NEQ "">
					<cfif locationObj.id EQ 0>
						[New Location]<br/>

						<cfquery name="insertLocation" result="res" datasource="#dsn#">
							INSERT INTO
								tbl_location (
									address,
									city,
									provstate,
									country,
									postalzip,
									lat,
									lon,
									html,
									email,
									phone,
									fax,
									website,
									date_created,
									status,
									location_type
								)
								VALUES
								(
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.address#" />,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.city#" />,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.provstate#" />,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.country#" />,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.postalzip#" />,
									<cfqueryparam cfsqltype="cf_sql_float" value="#locationObj.lat#" />,
									<cfqueryparam cfsqltype="cf_sql_float" value="#locationObj.lon#" />,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.html#" />,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.email#" />,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.phone#" />,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.fax#" />,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.website#" />,
									<cfqueryparam cfsqltype="cf_sql_timestamp" value="#locationObj.date_created#">,
									<cfqueryparam cfsqltype="cf_sql_integer" value="#locationObj.status#" />,
									<cfqueryparam cfsqltype="cf_sql_integer" value="#locationObj.location_type#" />
								)
						</cfquery>
						<cfset locationObj.id = res.IDENTITYCOL/>

						<cfset ArrayAppend(message, "Insert Location [#locationObj.id#]")/>
				
					<cfelse>
						<cfif update>
							[Update Location]<br/>

							<cfquery name="updateLocation" datasource="#dsn#">
								UPDATE
									tbl_location
								SET							
									address = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.address#" />,
									city = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.city#" />,
									provstate = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.provstate#" />,
									country = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.country#" />,
									postalzip = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.postalzip#" />,
									lat = <cfqueryparam cfsqltype="cf_sql_float" value="#locationObj.lat#" />, 
									lon = <cfqueryparam cfsqltype="cf_sql_float" value="#locationObj.lon#" />,
									html = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.html#" />,
									email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.email#" />,
									phone = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.phone#" />,
									fax = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.fax#" />,
									website = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#locationObj.website#" />,
									date_created = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#locationObj.date_created#">,
									status = <cfqueryparam cfsqltype="cf_sql_integer" value="#locationObj.status#" />,
									location_type = <cfqueryparam cfsqltype="cf_sql_integer" value="#locationObj.location_type#" />
								WHERE
									id = <cfqueryparam cfsqltype="cf_sql_integer" value="#locationObj.id#" />						
							</cfquery>
						</cfif>

						<cfset ArrayAppend(message, "Update Location [#locationObj.id#]")/>
				
					</cfif>
				</cfif>		

				<!--- Save Article --->
				<cfif articleAction NEQ "">
					<cfif articleObj.id EQ 0>
						[New Article]<br/>

						<cfquery name="insertArticle" datasource="#dsn#" result="insertArticleResult">
							INSERT INTO
								tbl_article (
									collection_id,
									name,
									page,
									hits,
									title,
									status,
									date_start,
									date_end,
									location,
									excerpt,
									image,
									meta,
									html
								) VALUES (
									<cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.collection_id#" />,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#articleObj.name#" />,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#articleObj.page#" />,
									<cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.hits#" />,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#articleObj.title#" />,
									<cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.status#" />,
									<cfif articleObj.date_start EQ "">NULL<cfelse><cfqueryparam cfsqltype="cf_sql_timestamp" value="#articleObj.date_start#" /></cfif>,
									<cfif articleObj.date_end EQ "">NULL<cfelse><cfqueryparam cfsqltype="cf_sql_timestamp" value="#articleObj.date_end#" /></cfif>,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#articleObj.location#" />,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#articleObj.excerpt#" />,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#articleObj.image#" />,
									<cfqueryparam cfsqltype="cf_sql_clob" value="#SerializeJSON(articleObj.meta)#" />,
									<cfqueryparam cfsqltype="cf_sql_clob" value="#articleObj.html#" />
								)
						</cfquery>
						<cfset articleObj.id = insertArticleResult.IDENTITYCOL/>

						<cfset ArrayAppend(message, "Insert Article [#articleObj.id#]")/>
				
					<cfelse>
						<cfif update>

							[Update Article]<br/>

							<cfquery name="updateArticle" datasource="#dsn#">
								UPDATE					
									tbl_article
								SET
									status = <cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.status#" />,
									collection_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.collection_id#" />,
									name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#articleObj.name#" />,
									page = <cfqueryparam cfsqltype="cf_sql_varchar" value="#articleObj.page#" />,
									hits = <cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.hits#" />,
									title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#articleObj.title#" />,
									date_created = <cfif articleObj.date_created EQ "">NULL<cfelse><cfqueryparam cfsqltype="cf_sql_timestamp" value="#articleObj.date_created#" /></cfif>,
									date_start = <cfif articleObj.date_start EQ "">NULL<cfelse><cfqueryparam cfsqltype="cf_sql_timestamp" value="#articleObj.date_start#" /></cfif>,
									date_end = <cfif articleObj.date_end EQ "">NULL<cfelse><cfqueryparam cfsqltype="cf_sql_timestamp" value="#articleObj.date_end#" /></cfif>,
									location = <cfqueryparam cfsqltype="cf_sql_varchar" value="#articleObj.location#" />,
									excerpt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#articleObj.excerpt#" />,
									image = <cfqueryparam cfsqltype="cf_sql_varchar" value="#articleObj.image#" />,
									meta = <cfqueryparam cfsqltype="cf_sql_clob" value="#SerializeJSON(articleObj.meta)#" />,
									html = <cfqueryparam cfsqltype="cf_sql_clob" value="#articleObj.html#" />
								WHERE
									id = <cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.id#" />
							</cfquery>

							<cfset ArrayAppend(message, "Update Article [#articleObj.id#]")/>
					
						</cfif>
					</cfif>
				</cfif>		

				<!--- Save role association --->
				[Save Article Role]<br/>
				<cfquery name="insertArticle" datasource="#dsn#">
					DELETE FROM	tbl_article_article_x_role
					WHERE article_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.id#" />
				</cfquery>
				<cfloop collection="#articleRoles#" item="ii">
					<cfif ii GT 0>
						<cfquery name="insertArticle" datasource="#dsn#">
							INSERT INTO
								tbl_article_article_x_role (
									article_id,
									role_id
								) VALUES (
									<cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.id#" />,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#ii#" />
								)
						</cfquery>
					</cfif>
				</cfloop>	

				<!--- Save category association --->
				[Save Article Category]<br/>
				<cfquery name="insertArticle" datasource="#dsn#">
					DELETE FROM	tbl_article_article_x_category
					WHERE article_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.id#" />
				</cfquery>
				<cfloop collection="#articleCategorys#" item="ii">
					<cfif ii GT 0>
						<cfquery name="insertArticle" datasource="#dsn#">
							INSERT INTO
								tbl_article_article_x_category (
									article_id,
									category_id
								) VALUES (
									<cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.id#" />,
									<cfqueryparam cfsqltype="cf_sql_integer" value="#ii#" />
								)
						</cfquery>
					</cfif>
				</cfloop>
				
				<!--- Save tag association --->
				[Save Article Tag]<br/>
				<cfquery name="insertArticle" datasource="#dsn#">
					DELETE FROM	tbl_article_article_x_tag
					WHERE article_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.id#" />
				</cfquery>
				<cfloop collection="#articleTags#" item="ii">
					<cfif ii GT 0>
						<cfquery name="insertArticle" datasource="#dsn#">
							INSERT INTO
								tbl_article_article_x_tag (
									article_id,
									tag_id
								) VALUES (
									<cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.id#" />,
									<cfqueryparam cfsqltype="cf_sql_integer" value="#ii#" />
								)
						</cfquery>
					</cfif>
				</cfloop>
										
				<!--- Save Article Location --->
				[Save Article Location]<br/>
				<cfquery name="insertLocation" datasource="#dsn#">
					DELETE
					FROM tbl_location_location_x_article
					WHERE article_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.id#" />
				</cfquery>
				<cfquery name="insertLocation" datasource="#dsn#" result="res">
					INSERT INTO
						tbl_location_location_x_article (
							article_id,
							location_id
						) VALUES (
							<cfqueryparam cfsqltype="cf_sql_integer" value="#articleObj.id#" />,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#locationObj.id#" />
						)
				</cfquery>

				<cfset ArrayAppend(message, "Save Completed")/>
				
					</li>																								
				</cfif>
				
			</cfif>

				</ul>
				</div>
			</td>

			<td class="dif">
				<div style="max-width:400px;overflow:auto;">#ArrayToList(dif,"<br/>")#</div>
			</td>
			
			<td class="rep">
				<div style="max-width:400px;overflow:auto;">
			<cfif ArrayLen(warn) GT 0>
					<div class="warn">#ArrayToList(warn,"<br/>")#</div>
			</cfif>
			<cfif ArrayLen(error) GT 0>
					<div class="err">#ArrayToList(error,"<br/>")#</div>
			</cfif>
			<cfif ArrayLen(message) GT 0>
					<div class="ok">#ArrayToList(message,"<br/>")#</div>
			</cfif>
				</div>
			</td>
		</tr>

		<cfset cnt = cnt + 1/>
		<cfset flushCnt = flushCnt + 1/>
		<cfif flushCnt EQ 11>
			<cfflush/>
			<cfset flushCnt = 1/>
		</cfif>
	</cfloop>
		</tbody>
	</table>

	<cfif debug>
		<cfdump var="#namesFound#" label="namesFound" expand="no"/>
	</cfif>

</cfif>

<cfif act EQ "">
SELECT
</cfif>
</body>
</html>
</cfoutput>
</cfprocessingdirective>