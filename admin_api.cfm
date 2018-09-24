<cfprocessingdirective suppresswhitespace="yes" pageencoding="utf-8">
<cfsetting enablecfoutputonly="yes" />
    
<cfparam name="act" type="string" default=""/>
<cfparam name="store_id" type="string" default=""/>
<cfparam name="data" type="string" default=""/>
    
<cfset result = StructNew()/>
<cfset result['status'] = 0/>
<cfset result['message'] = ""/>

<cfif act EQ "getstorehours">
    
    <cfset data = ArrayNew(1)/>
    
	<cfquery name="query" datasource="#Application.DSN#" cachedwithin="#CreateTimeSpan(0, 1, 0, 0)#">
		SELECT a.id, a.name, a.title, a.meta
		FROM
			tbl_article AS a
		WHERE
			a.collection_id = 2
            AND
            a.status = 1
        <cfif store_id NEQ "">
            AND a.name = '#store_id#'
        </cfif>
	</cfquery>
    <cfloop from="1" to="#query.RecordCount#" index="i">
        <cfset structured_data = DeserializeJSON(query.meta[i])/>
        <cfset structured_data = DeserializeJSON(structured_data['google_structured_data'])/>
        <cfset tmp = StructNew()/>
        <cfset tmp['id'] = query.name[i]/>
        <cfset tmp['store_city'] = query.title[i]/>
        <cfset tmp['meta.google_structured_data'] = structured_data/>
        <cfset ArrayAppend(data, tmp)/>
    </cfloop>
    
    <cfif store_id NEQ "">
        <cfset result['data'] = data[1]/>
    <cfelse>
        <cfset result['data'] = data/>
    </cfif>
        
    <cfset result['status'] = 1/>
</cfif>

<cfif act EQ "savestorehours">

    <cfset result['data'] = data/>
    <cfset result['status'] = 1/>
</cfif>
    
<cfheader name="Content-Type" value="application/json; charset=utf-8" />
<cfoutput>#SerializeJSON(result)#</cfoutput>
    
</cfprocessingdirective>