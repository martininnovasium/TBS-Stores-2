<cfprocessingdirective suppresswhitespace="yes" pageencoding="UTF-8">
<cfinclude template="/lib/cfm/cfidfix.cfm" />
<cfobject component="#Application.FFMAP#.components.redirect" name="comRedirect"/>
<cffunction name="RewriteStartRequestFunction">
</cffunction>
<cffunction name="RewriteRequestFunction">
	<cfset var i = ''/>
	<cfset var tmp = ''/>
	<cfset var found = false/>
	<cfset var myzone = ""/>
	<cfset var defaultzone = ""/>
	<cfset var comArticle = ""/>
	<cfset var getArticlesResult= ""/>
	
	<cfset debugLog("RewriteRequestFunction: Start")>

	<!--- Convert old cookie to new --->		
	<cfif StructKeyExists(cookie,'mystore') EQ true AND StructKeyExists(cookie,'store') EQ false>
		<cfset tmp = ListToArray(cookie.mystore,"~")/>
		<cfif ArrayLen(tmp) GT 1>

			<cfcookie name="mystore" value="X" expires="NOW" />

			<cfobject component="forefront_6.managers.article" name="comArticle" />

			<cfinvoke component="#comArticle#" method="init">
			</cfinvoke>

			<cfinvoke component="#comArticle#" method="getArticles" returnvariable="getArticlesResult">
				<cfinvokeargument name="collection_ids" value="2"/>
				<cfinvokeargument name="role_ids" value="0"/>
				<cfinvokeargument name="names" value="#tmp[2]#"/>
				<cfinvokeargument name="columns" value="id,name,title,locations,roles,attachments,link"/>
				<cfinvokeargument name="status" value="1"/>
			</cfinvoke>

			<cfif getArticlesResult.RecordCount GT 0>
				<cfset session['mystore'] = StructNew()/>
				<cfset session['mystore']['id'] = getArticlesResult.id[1]/>
				<cfset session['mystore']['name'] = getArticlesResult.name[1]/>
				<cfset session['mystore']['title'] = getArticlesResult.title[1]/>
				<cfset session['mystore']['city'] = getArticlesResult.locations[1][1].city/>
				<cfset session['mystore']['url'] = "/store/#getArticlesResult.name[1]#/"/>
			</cfif>
			
		</cfif>
	</cfif>
		
	<cfset foundDomainRole = "D2FC2C88-D7A5-4275-9DC3-3B41AFD7BE38"/>
	<cfloop from="1" to="#ArrayLen(Application.custom.domains)#" index="i">
		<cfif ListFind(Application.custom.domains[i][1],cgi.SERVER_NAME) GT 0>
			<cfset session['location_role_id'] = Application.custom.domains[i][2]/>
			<cfset foundDomainRole = Application.custom.domains[i][2]/>
		</cfif>
	</cfloop>

	<!--- Set default user --->
	<cfif StructKeyExists(session,"ffuser") EQ false>
		<cfset session['ffuser'] = StructNew()/>
	</cfif>

	<cfif StructKeyExists(session.ffuser,"role_ids") EQ false>
		<cfset session.ffuser['role_ids'] = foundDomainRole/>
	<cfelse>
		<!--- Remove all domain roles --->
		<cfloop from="1" to="#ArrayLen(Application.custom.domains)#" index="i">
			<cfset f = ListFind(session.ffuser['role_ids'], Application.custom.domains[i][2])/>
			<cfif f GT 0>
				<cfset session.ffuser['role_ids'] = ListDeleteAt(session.ffuser['role_ids'], f)/>
			</cfif>
		</cfloop>
	</cfif>

	<cfif ListFind(session.ffuser['role_ids'], foundDomainRole) EQ 0>
		<cfset session.ffuser['role_ids'] = ListAppend(session.ffuser['role_ids'], foundDomainRole)/>
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

	<cfif StructCount(Request.FFUser) EQ 0>
		<cfset Request.FFUser = Session.ffuser/>
	</cfif>
		
	<!--- Set default zone --->
	<cfloop collection="#Application.custom.zones#" item="i">
		<cfif ListFind(Request.FFUser['role_ids'], i)>
			<cfset myzone = Application.custom.zones[i]/>
			<cfset found = true/>
		</cfif>
		<!---cfif Application.custom.zones[i] EQ "z1">
			<cfset defaultzone = i/>
		</cfif--->
	</cfloop>

		
	<cfif StructKeyExists(cookie,'store') AND StructKeyExists(session,'mystore') EQ false>
		<cfset debugLog("RewriteRequestFunction: cookie['store']=[#cookie['store']#]")>
		<cfset tmp = ListToArray(cookie.store)/>
	
		<cfif ArrayLen(tmp) GT 1>
			
			<cfloop collection="#Application.custom.zones#" item="i">
				<cfif Application.custom.zones[i] EQ tmp[1]>
					<cfset defaultzone = i/>
				</cfif>
			</cfloop>

			<cfif StructKeyExists(session,'mystore') EQ false>
<cfset debugLog("RewriteRequestFunction: set store to [#tmp[2]#]")>

				<cfobject component="forefront_6.managers.article" name="comArticle" />

				<cfinvoke component="#comArticle#" method="init">
				</cfinvoke>

				<cfinvoke component="#comArticle#" method="getArticles" returnvariable="getArticlesResult">
					<cfinvokeargument name="collection_ids" value="2"/>
					<cfinvokeargument name="role_ids" value="0"/>
					<cfinvokeargument name="article_ids" value="#tmp[2]#"/>
					<cfinvokeargument name="columns" value="id,name,title,locations,roles,attachments,link"/>
					<cfinvokeargument name="status" value="1"/>
				</cfinvoke>

				<cfif getArticlesResult.RecordCount GT 0>
					<cfset session['mystore'] = StructNew()/>
					<cfset session['mystore']['id'] = getArticlesResult.id[1]/>
					<cfset session['mystore']['name'] = getArticlesResult.name[1]/>
					<cfset session['mystore']['title'] = getArticlesResult.title[1]/>
					<cfset session['mystore']['city'] = getArticlesResult.locations[1][1].city/>
					<cfset session['mystore']['url'] = "/store/#getArticlesResult.name[1]#/"/>
				</cfif>

			</cfif>

		</cfif>
	</cfif>

	<cfset debugLog("RewriteRequestFunction: defaultzone=[#defaultzone#]")>
		
	<!--- Assign a default zone role --->

	<cfset debugLog("RewriteRequestFunction: found=[#found#]")>

	<cfif found EQ false>
		<cfif defaultzone NEQ "">
			<cfset myzone = Application.custom.zones[defaultzone]/>
		<cfelse>
			<cfset myzone = ""/>
		</cfif>
		<cfset Request.FFUser['role_ids'] = ListAppend(Request.FFUser['role_ids'], defaultzone )/>
		<cfset Request.Groups = Request.FFUser.role_ids>
	</cfif>
	<cfset debugLog("RewriteRequestFunction: myzone=[#myzone#]")>

<cfset debugLog("RewriteRequestFunction: Request.FFUser['role_ids']=")>
<cfset debugLog(Request.FFUser['role_ids'])>
		
	<cfset session['myzone'] = myzone/>

	<!--- Set default store --->
	<cfif StructKeyExists(session,'mystore') EQ false>
		<cfset session['mystore'] = StructNew()/>
		<cfset session['mystore']['id'] = 0/>
		<cfset session['mystore']['name'] = ""/>
		<cfset session['mystore']['title'] = ""/>
		<cfset session['mystore']['city'] = ""/>
		<cfset session['mystore']['url'] = ""/>
	</cfif>

	<cfif StructKeyExists(cookie,'STORE') EQ false>
		<cfcookie name="store" value="#session['myzone']#,#session['mystore']['id']#" expires="NEVER"/>
	</cfif>
	
	<cfset debugLog("RewriteRequestFunction: End")>
</cffunction>
<cfset comRedirect.RewriteStartRequestFunction = RewriteStartRequestFunction/>
<cfset comRedirect.RewriteRequestFunction = RewriteRequestFunction/>
<cfinvoke method="init" component="#comRedirect#">
	<cfinvokeargument name="page404" value="404.htm">
	<cfinvokeargument name="page403" value="403.htm">
	<cfinvokeargument name="page401" value="401.htm">
</cfinvoke>
</cfprocessingdirective>