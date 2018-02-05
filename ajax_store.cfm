<cfprocessingdirective suppresswhitespace="yes" pageencoding="iso-8859-1">
<cfsetting enablecfoutputonly="yes" />

<cfparam name="action" type="string" default="" />
<cfparam name="province" type="string" default="">

<cfparam name="out" type="string" default="json" />
<cfparam name="debug" type="numeric" default="0" />

<cfset province = Trim(province)/>

<cfset result = StructNew() />
<cfset result['status'] = 0 />
<cfset result['message'] = "" />

<cfset collection_id = 2 />

	
<!---	
<cfsavecontent variable="tmp">
<cfoutput>
[
  {url: 'http://tbsstores2dev.innovasium.com/tbs/store/53827', city: 'Markham', address: '55 Albert Street, Markham, ON'},
  {url: 'http://tbsstores2dev.innovasium.com/tbs/store/53850', city: 'Scarborough', address: '2 Finch Ave, Scarborough, ON'},
  {url: 'http://tbsstores2dev.innovasium.com/tbs/store/53822', city: 'Toronto', address: '111 Peter Street, Toronto, ON'},
  {url: 'http://tbsstores2dev.innovasium.com/tbs/store/53821', city: 'Toronto', address: '280 Toronto Street, Toronto, ON'},
  {url: 'http://tbsstores2dev.innovasium.com/tbs/store/53824', city: 'Windsor', address: '2 Kruger Street, Windsor', ON'},
]
</cfoutput>
</cfsavecontent>	
<cfset result['data'] = DeserializeJSON(tmp)/>
--->
	
<!--- ================================= --->

<cfif action EQ "provinces">
		
	<cfquery name="query" datasource="#Application.DSN#" cachedwithin="#CreateTimeSpan(0, 1, 0, 0)#">
		SELECT l.provstate
		FROM
			tbl_location AS l
			LEFT JOIN tbl_location_location_x_article AS llxa ON llxa.location_id = l.id
			LEFT JOIN tbl_article AS a ON a.id = llxa.article_id
		WHERE
			a.collection_id = #collection_id#
            AND
            a.status = 1
		GROUP BY
			l.provstate
		ORDER BY		
			l.provstate
	</cfquery>

	<cfif query.RecordCount GT 0>

		<cfset result['data'] = ArrayNew(1) />
		<cfloop from="1" to="#query.RecordCount#" index="i">
			<cfset ArrayAppend(result['data'], {"val"=query.provstate[i],"label"=query.provstate[i]}) />
		</cfloop>
		<cfset result['status'] = 1 />

	<cfelse>
		<cfset result['status'] = -1 />
		<cfset result['message'] = "No stores found." />
	</cfif>		
</cfif>
	
<cfif action EQ "cities">
	
	<cfif province EQ "">
		<cfset result['status'] = -1 />
		<cfset result['message'] = "Province is required." />
	<cfelse>
	
		<cfquery name="query" datasource="#Application.DSN#" cachedwithin="#CreateTimeSpan(0, 1, 0, 0)#">
			SELECT a.name, l.address, l.city, l.provstate
			FROM
				tbl_location AS l
				LEFT JOIN tbl_location_location_x_article AS llxa ON llxa.location_id = l.id
				LEFT JOIN tbl_article AS a ON a.id = llxa.article_id
			WHERE
				l.provstate = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#province#"/>
				AND
				a.collection_id = #collection_id#
                AND
                a.status = 1
			ORDER BY		
				l.city
		</cfquery>

		<cfif query.RecordCount GT 0>

			<cfset result['data'] = ArrayNew(1) />
			<cfloop from="1" to="#query.RecordCount#" index="i">
				<cfset u = "/store/#query.name[i]#/"/>"
				<cfset ArrayAppend(result['data'], {"val"=#u#,"label"=query.city[i],"address"=query.address[i]}) />
			</cfloop>
			<cfset result['status'] = 1 />

		<cfelse>
			<cfset result['status'] = -1 />
			<cfset result['message'] = "No stores found in that province." />
		</cfif>

	</cfif>
		
</cfif>
	
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