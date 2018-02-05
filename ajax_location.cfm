<cfprocessingdirective suppresswhitespace="yes" pageencoding="iso-8859-1">
<cfsetting enablecfoutputonly="yes" />

<cfparam name="action" type="string" default="" />
<cfparam name="sethome" type="string" default="">
<cfparam name="name" type="string" default="">
<cfparam name="lat" type="string" default="">
<cfparam name="lon" type="string" default="">
<cfparam name="search" type="string" default="">
<cfparam name="redirect" type="string" default="">
<cfparam name="ffdebug" type="string" default="0">

<cfparam name="out" type="string" default="json" />
<cfparam name="debug" type="numeric" default="0" />

<cfset name = Trim(name)/>
<cfset search = Trim(search)/>
<cfset sethome = Val(sethome)/>
<cfset lat = Val(lat)/>
<cfset lon = Val(lon)/>
<cfset ffdebug = Val(ffdebug)/>

<cfset result = StructNew() />
<cfset result['status'] = 0 />
<cfset result['message'] = "" />

<cfset collection_id = 2 />
<cfset default_zone = ""/><!--- z1 --->
<cfset default_path = ""/><!--- tbs --->
<cfset default_domain = "www.tbsstores.com"/>
	
<cfset article_location_searchtype = "city"/>
<cfset article_location_limit = 10/>
<cfset article_location_country = "Canada"/>
<cfset article_location_maxdistance = 1000/>
<cfset article_location_region = ""/>

<cfset domain = "" />
<cfset path = "" />
<cfset store_name = "" />
<cfset store_url = "" />

<cfif debug>
	<cfset result['debug'] = ArrayNew(1) />
	<cfset ArrayAppend(result['debug'], "action=[#action#] name=[#name#] lat=[#lat#] lon=[#lon#] sethome=[#sethome#] search=[#search#]") />
	<cfset ArrayAppend(result['debug'], "form=") />
	<cfset ArrayAppend(result['debug'], form) />
	<cfset ArrayAppend(result['debug'], "application.dsn=[#application.dsn#]") />
	<cfset ArrayAppend(result['debug'], "HTTP_USER_AGENT=[#cgi.HTTP_USER_AGENT#]") />
	<cfset ArrayAppend(result['debug'], "HTTP_ACCEPT_LANGUAGE=[#cgi.HTTP_ACCEPT_LANGUAGE#]") />
	<!---cfset ArrayAppend(result['debug'], cgi) /--->
</cfif>
	
<cftry>

	<cfif ffdebug GT 0>
		<cfset Session['ffdebug'] = 1/>
	</cfif>
	
	<!--- Set default session user --->
	<cfif StructKeyExists(session,"ffuser") EQ false>
		<cfset session['ffuser'] = StructNew()/>
	</cfif>
	<cfif StructKeyExists(session.ffuser,"role_ids") EQ false>
		<cfset session.ffuser['role_ids'] = ""/>
	</cfif>
	<cfif StructKeyExists(session.ffuser,"user_id") EQ false>
		<cfset session.ffuser['user_id'] = ""/>
		<cfset session.ffuser['user_name'] = ""/>
		<cfset session.ffuser['first_name'] = ""/>
		<cfset session.ffuser['last_name'] = ""/>
		<cfset session.ffuser['email'] = ""/>
	</cfif>
	<cfif session.ffuser.user_id EQ "">
		<cfset session.ffuser['loggedin'] = false/>
	</cfif>
	
	<cfif name NEQ "">
	
		<!--- find name in store articles --->
		<cfobject component="forefront_6.managers.article" name="Request.comArticle" />

		<cfinvoke component="#Request.comArticle#" method="init">
			<cfinvokeargument name="collection_id" value="#collection_id#"/>
			<cfinvokeargument name="debug" value="#debug#" />
		</cfinvoke>

		<cfinvoke component="#Request.comArticle#" method="getArticles" returnvariable="getArticlesResult">
			<cfinvokeargument name="collection_ids" value="#collection_id#"/>
			<cfinvokeargument name="role_ids" value="0"/>
			<cfinvokeargument name="names" value="#name#"/>
			<cfinvokeargument name="columns" value="id,name,title,locations,roles,attachments,link"/>
			<cfinvokeargument name="status" value="1"/>
		</cfinvoke>

		<cfif getArticlesResult.RecordCount GT 0>
			<cfset domain = getDomain(getArticlesResult.roles[1]) />
			<cfset path = getPath(getArticlesResult.roles[1]) />
			<cfset store_name = getArticlesResult.name[1] />
			<cfset store_url = "http://" & domain & "/store/#store_name#/" />
		</cfif>
		
		<cfif debug>
			<cfset ArrayAppend(result['debug'], "getArticlesResult=") />
			<cfset ArrayAppend(result['debug'], getArticlesResult) />
		</cfif>
	</cfif>
					
	<cfif action EQ "check">
		<cfset result['mystore'] = session.mystore/>
		<cfset result['myzone'] = session.myzone/>
		<cfset result['status'] = 1 />
	</cfif>

	<cfif action EQ "sethome">
		<cfif name EQ "">
			<cfset result['status'] = -1 />
			<cfset result['message'] = "Name not set" />
		<cfelse>
			
			<cfset result['url'] = REReplace(cgi.HTTP_REFERER, "http://[^/]*", "") />
			<!---cfset result['url'] = "http://" & domain & "/" & result['url'] & "?sethome"/--->
			<cfset result['url'] = "http://" & domain & "/ajax_location.cfm?action=set&name=#store_name#&redirect=" & result['url']/>
			<cfset result['status'] = 2 />
			<!---
			<cfif debug>
			<cfelse>
				<cflocation url="#result['url']#" addtoken="No"/>
			</cfif>
			--->
			
		</cfif>
	</cfif>
		
	<cfif action EQ "set">
		<cfif name EQ "">
			<cfset result['status'] = -1 />
			<cfset result['message'] = "Name not set" />
		<cfelse>
			
			<cfif name EQ "none">
				
				<cfinvoke method="setStore">
					<cfinvokeargument name="id" value="-1"/>
					<cfinvokeargument name="name" value=""/>
					<cfinvokeargument name="title" value=""/>
					<cfinvokeargument name="city" value=""/>
					<cfinvokeargument name="prov" value=""/>
					<cfinvokeargument name="roles" value="#default_zone#"/>
					<cfinvokeargument name="storeurl" value="/"/>
				</cfinvoke>
				
				<cfset result['status'] = 3 />
				
			<cfelse>

				<cfif getArticlesResult.RecordCount GT 0>

					<cfinvoke method="setStore">
						<cfinvokeargument name="id" value="#getArticlesResult.id[1]#"/>
						<cfinvokeargument name="name" value="#getArticlesResult.name[1]#"/>
						<cfinvokeargument name="title" value="#getArticlesResult.title[1]#"/>
						<cfinvokeargument name="city" value="#getArticlesResult.locations[1][1].city#"/>
						<cfinvokeargument name="prov" value="#getArticlesResult.locations[1][1].provstate#"/>
						<cfinvokeargument name="roles" value="#getArticlesResult.roles[1]#"/>
						<cfinvokeargument name="storeurl" value="#store_url#"/>
					</cfinvoke>

					<cfset result['mystore'] = session.mystore/>
					<cfset result['myzone'] = session.myzone/>

					<cfif redirect NEQ "">
						<cfset result['url'] = redirect />
					<cfelse>
						<cfset result['url'] = REReplace(cgi.HTTP_REFERER, "http://[^/]*", "") />
						<cfset result['url'] = "http://" & domain & "/" & result['url']/>
					</cfif>
					
					<cfset result['status'] = 2 />
				<cfelse>
					<cfset result['message'] = "Store not found" />
					<cfset result['status'] = -1 />
				</cfif>

				<cfif debug>
					<cfset ArrayAppend(result['debug'], "Request.comArticle.debug=") />
					<cfset ArrayAppend(result['debug'], Request.comArticle.debug) />
				</cfif>

				<cfif debug EQ 0>
					<cfif result['status'] EQ 2 AND redirect NEQ "">
						<cfheader name="TBS-Location-store" value="#session['mystore']['name']#"/>
						<cfheader name="TBS-Location-zone" value="#session['myzone']#"/>
						<cflocation url="#redirect#" addtoken="No"/>
					</cfif>
				</cfif>
			</cfif>
					
		</cfif>
	</cfif>

	<cfif action EQ "find" OR action EQ "list">
	
		<cfobject component="forefront_6.managers.location" name="Request.comLocation" />

		<cfinvoke component="#Request.comLocation#" method="init">
			<cfinvokeargument name="debug" value="#debug#" />
		</cfinvoke>
	
		<cfif debug>
			<cfset ArrayAppend(result['debug'], "collection_id=[#collection_id#] lat=[#lat#] lon=[#lon#]") />
		</cfif>
		<cfif debug>
			<cfif StructKeyExists(Application,'locations')>
				<cfset ArrayAppend(result['debug'], "Application.locations=") />
				<cfset ArrayAppend(result['debug'], Application.locations) />
			</cfif>
			<cfif StructKeyExists(Application.custom,'domains')>
				<cfset ArrayAppend(result['debug'], "Application.custom.domains=") />
				<cfset ArrayAppend(result['debug'], Application.custom.domains) />
			</cfif>
		</cfif>
		
		<cfinvoke component="#Request.comLocation#" method="getArticles" returnvariable="getArticlesResult">
			<cfinvokeargument name="collection_ids" value="#collection_id#" />
			<cfinvokeargument name="category_ids" value="0" />
			<cfinvokeargument name="tag_ids" value="0" />
			<cfinvokeargument name="role_ids" value="0" />
			<cfinvokeargument name="search" value="#search#" />
			<cfinvokeargument name="searchtype" value="#article_location_searchtype#" />
			<cfinvokeargument name="columns" value="id,name,title,locations,roles,address,city,provstate,distance,link" />
			<cfinvokeargument name="limit" value="#article_location_limit#" />
			<cfinvokeargument name="lat" value="#lat#" />
			<cfinvokeargument name="lon" value="#lon#" />
			<cfinvokeargument name="country" value="#article_location_country#" />
			<cfinvokeargument name="maxdistance" value="#article_location_maxdistance#" />
			<cfinvokeargument name="status" value="1" />
			<cfinvokeargument name="region" value="#article_location_region#" />
			<cfinvokeargument name="version" value="2" />
		</cfinvoke>

		<cfif debug>
			<cfset ArrayAppend(result['debug'], "getArticlesResult=") />
			<cfset ArrayAppend(result['debug'], getArticlesResult) />
		</cfif>

		<cfset store_url	= "/" />
		
		<cfif StructKeyExists(getArticlesResult,'count') AND getArticlesResult.count GT 0>
		
			<cfif action EQ "find">

				<cfset domain = getDomain(getArticlesResult.articles[1].roles) />
				<cfset path = getPath(getArticlesResult.articles[1].roles) />
				<cfset store_name = getArticlesResult.articles[1].name />
				<cfset store_url = "http://" & domain & "/store/#store_name#/" />

				<cfif debug>
					<cfset ArrayAppend(result['debug'], "store_name=[#store_name#] store_url=[#store_url#]") />
				</cfif>
				
				<cfif sethome EQ 1>

					<cfset result['url'] = REReplace(cgi.HTTP_REFERER, "http://[^/]*", "") />
					<!---cfset result['url'] = "http://" & domain & "/" & result['url'] & "?sethome"/--->
					<cfset result['url'] = "http://" & domain & "/ajax_location.cfm?action=set&name=#store_name#&redirect=" & result['url']/>
					
					<!---
					<cfset result['url'] = REReplace(storeurl,"/store/.*","/") />
					--->
					
					<cfset ref = cgi.HTTP_REFERER/>
					<cfif ref NEQ "">
						<cfif Find("/store/",ref)>
							<!---
							<cfset result['url'] = "/" />
							<cfset result['url'] = ListAppend(result['url'], path,"/") />
							<cfset result['url'] = ListAppend(result['url'], "store/#name#/", "/") />
							--->
							<cfset result['url'] = "http://" & domain & "/ajax_location.cfm?action=set&name=#store_name#&redirect=/store/#store_name#/"/>
						</cfif>
					</cfif>

					<cfinvoke method="setStore">
						<cfinvokeargument name="id" value="#getArticlesResult.articles[1].article_id#"/>
						<cfinvokeargument name="name" value="#getArticlesResult.articles[1].name#"/>
						<cfinvokeargument name="title" value="#getArticlesResult.articles[1].title#"/>
						<cfinvokeargument name="city" value="#getArticlesResult.articles[1].city#"/>
						<cfinvokeargument name="prov" value="#getArticlesResult.articles[1].provstate#"/>
						<cfinvokeargument name="roles" value="#getArticlesResult.articles[1].roles#"/>
						<cfinvokeargument name="storeurl" value="#store_url#"/>
					</cfinvoke>
					
					<cfset result['mystore'] = session.mystore/>
					<cfset result['myzone'] = session.myzone/>
						
				<cfelse>					

					<cfset result['store'] = Duplicate(getArticlesResult.articles[1]) />
					<cfset StructDelete(result['store'],'roles') />
					<cfset StructDelete(result['store'],'location_count') />
					<cfset StructDelete(result['store'],'location_id') />
					<cfset StructDelete(result['store'],'article_id') />

					<cfset result['url'] = "/store/#store_name#/" />
					<!---
					<cfset result['url'] = "/store/#name#/" />
					<cfset result['url'] = "/#path#/store/#name#/" />
					--->
					
				</cfif>				

				<cfset result['status'] = 2 />
					
			</cfif>			
			
			<cfif action EQ "list">
			
				<cfset result['stores'] = ArrayNew(1) />
			
				<cfloop from="1" to="#ArrayLen(getArticlesResult.articles)#" index="i">
					<cfset tmp = StructNew()/>
					<cfset tmp['distance'] = getArticlesResult.articles[i].distance/>
					<cfset tmp['title'] = getArticlesResult.articles[i].title/>
					<cfset tmp['address'] = getArticlesResult.articles[i].address/>
					<cfset tmp['city'] = getArticlesResult.articles[i].city/>
					<cfset tmp['provstate'] = getArticlesResult.articles[i].provstate/>
					<cfset tmp['distance'] = getArticlesResult.articles[i].distance/>
					<cfset tmp['name'] = getArticlesResult.articles[i].name/>
					<cfset tmp['lat'] = getArticlesResult.articles[i].lat/>
					<cfset tmp['lon'] = getArticlesResult.articles[i].lon/>
					<cfset ArrayAppend(result['stores'], tmp)	/>
				</cfloop>
				
				<cfset result['status'] = 1 />
			</cfif>			
			
		<cfelse>
		
			<cfinvoke method="setStore">
				<cfinvokeargument name="id" value="-1"/>
				<cfinvokeargument name="name" value=""/>
				<cfinvokeargument name="title" value=""/>
				<cfinvokeargument name="city" value=""/>
				<cfinvokeargument name="prov" value=""/>
				<cfinvokeargument name="roles" value="#default_zone#"/>
				<cfinvokeargument name="storeurl" value="/"/>
			</cfinvoke>
			
			<cfif sethome EQ 1>
				<cfset result['url'] = "/" & default_path & "/" />
				<cfset result['status'] = 2 />
			<cfelse>			
				<cfset result['message'] = "No Stores found." />
				<cfset result['status'] = -1 />
			</cfif>
			
		</cfif>

		<cfif debug>
			<cfset ArrayAppend(result['debug'], "Request.comLocation.debug=") />
			<cfset ArrayAppend(result['debug'], Request.comLocation.debug) />
		</cfif>

	</cfif>
      
    <cfcatch>
        <cfset result['status'] = -99 />
        <cfset result['message'] = cfcatch.Message />
        <cfset result['catch'] = cfcatch />
    </cfcatch>
</cftry>
			
<!--- ============================ --->

<cffunction name="getDomain" returntype="string">
	<cfargument name="roles" type="array"/>
	<cfset var domain = default_domain />
	<cfset var r = 0 />
	<cfset var i = 0 />
	<cfif debug>
		<cfset ArrayAppend(result['debug'], "getDomain()") />
	</cfif>
	<cfloop from="1" to="#ArrayLen(roles)#" index="r">
		<cfif Left(roles[r].description,5) EQ "Site:">
			<cfloop from="1" to="#ArrayLen(Application.custom.domains)#" index="i">
				<cfif roles[r].role_id EQ Application.custom.domains[i][2]>
					<cfif Find("innovasium",cgi.Server_Name) GT 0>
						<cfset domain = ListFirst(Application.custom.domains[i][1]) />
					<cfelse>
						<cfset domain = ListGetAt(Application.custom.domains[i][1],2) />
					</cfif>
					<cfbreak/>
				</cfif>
			</cfloop>
		</cfif>
	</cfloop>
	<cfif debug>
		<cfset ArrayAppend(result['debug'], "getDomain: domain=[#domain#]") />
	</cfif>
	<cfreturn domain/>
</cffunction>

<cffunction name="getPath" returntype="string">
	<cfargument name="roles" type="array"/>
	<cfset var path = default_path />
	<cfset var r = 0 />
	<cfloop from="1" to="#ArrayLen(roles)#" index="r">
		<cfif Left(roles[r].description,5) EQ "Site:">
			<cfif StructKeyExists(roles[r],'path')>
				<cfset path = roles[r].path />
				<cfbreak/>
			</cfif>
		</cfif>
	</cfloop>
	<cfif debug>
		<cfset ArrayAppend(result['debug'], "getPath()=[#path#]") />
	</cfif>
	<cfreturn path/>
</cffunction>
			
<cffunction name="setStore">
	<cfargument name="id" type="string"/>
	<cfargument name="name" type="string"/>
	<cfargument name="title" type="string"/>
	<cfargument name="city" type="string"/>
	<cfargument name="prov" type="string"/>
	<cfargument name="roles" type="any"/>
	<cfargument name="storeurl" type="string"/>

	<cfif debug>
		<cfset ArrayAppend(result['debug'], "setStore()") />
		<cfset ArrayAppend(result['debug'], arguments) />
	</cfif>
	
	<cfset session['mystore'] = StructNew()/>
	<cfset session['mystore']['id'] = id/>
	<cfset session['mystore']['name'] = name/>
	<cfset session['mystore']['title'] = title/>
	<cfset session['mystore']['city'] = city/>
	<cfset session['mystore']['prov'] = prov/>
	<cfset session['mystore']['url'] = storeurl/>

	<cfset session['myzone'] = ""/>

	<!--- Set default user --->
	<cfif StructKeyExists(session,"ffuser") EQ false>
		<cfset session['ffuser'] = StructNew()/>
	</cfif>
	<cfif StructKeyExists(session.ffuser,"role_ids") EQ false>
		<cfset session.ffuser['role_ids'] = ""/>
	</cfif>
	
	<!--- Delete zones from ffuser --->
	<cfloop collection="#Application.custom.zones#" item="z">
		<cfset f = ListFind(session.ffuser['role_ids'], z)/>
		<cfif f GT 0>
			<cfset session.ffuser['role_ids'] = ListDeleteAt(session.ffuser['role_ids'], f)/>
		</cfif>
	</cfloop>

	<!--- Add new zones to ffuser --->
	<cfif IsArray(roles)>
		<cfloop from="1" to="#ArrayLen(roles)#" index="i">
			<cfif Left(roles[i].description,5) EQ "Zone:">
				<cfset session['myzone'] = roles[i].role/>
				<cfset session.ffuser['role_ids'] = ListAppend(session.ffuser['role_ids'], roles[i].role_id)/>
				<cfif debug>
					<cfset ArrayAppend(result['debug'], "new role added [#roles[i].role_id#][#roles[i].role#]") />
				</cfif>
			</cfif>
		</cfloop>
	<cfelse>
		<cfloop collection="#Application.custom.zones#" item="z">
			<cfif Application.custom.zones[z] EQ roles>
				<cfset session['myzone'] = Application.custom.zones[z]/>
				<cfset f = ListFind(session.ffuser['role_ids'], z)/>
				<cfif f GT 0>
					<cfset session.ffuser['role_ids'] = ListDeleteAt(session.ffuser['role_ids'], f)/>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>

	<cfcookie name="store" value="#session['myzone']#,#session['mystore']['id']#" expires="NEVER" />

	<cfif debug>
		<cfset ArrayAppend(result['debug'], "session['mystore']=") />
		<cfset ArrayAppend(result['debug'], session['mystore']) />
	</cfif>
	
</cffunction>
			
<!--- ============================ --->

<cfif out EQ "json">
	<cfheader name="Content-Type" value="application/json; charset=utf-8" />
	<cfoutput>#SerializeJSON(result)#</cfoutput>
</cfif>
<cfif out EQ "debug">
	<cfdump var="#result#" label="result" />
	<cfdump var="#session#" label="session" expand="no" />
</cfif>

</cfprocessingdirective>
