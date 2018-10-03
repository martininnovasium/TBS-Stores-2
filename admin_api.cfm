<cfprocessingdirective suppresswhitespace="yes" pageencoding="utf-8">
<cfsetting enablecfoutputonly="yes" />
    
<cfparam name="act" type="string" default=""/>
<cfparam name="store_id" type="string" default=""/>
<cfparam name="data" type="string" default=""/>
<cfparam name="key" type="string" default=""/>
<cfparam name="debug" type="integer" default="0"/>
    
<cfset result = StructNew()/>
<cfset result['status'] = 0/>
<cfset result['message'] = ""/>

<cfset store_id = Val(store_id)/>
    
<cfif debug>    
    <cfset result['debug'] = ArrayNew(1)/>
    <cfset ArrayAppend(result['debug'], "act=[#act#] store_id=[#store_id#] key=[#key#]")/>
</cfif>
    
<!--- Check key --->
<cfset keymatch = Hash(act & DateFormat(Now(),'YYYYMMDD'), 'MD5')/>
<cfif debug>    
    <cfset ArrayAppend(result['debug'], "keymatch=[#keymatch#]")/>
</cfif>
<cfif key NEQ keymatch>
    <cfset result['message'] = "Unauthorized [#keymatch#]"/>
    <cfset result['status'] = -1/>
    <cfset act = ""/>
</cfif>
    
<cfif act EQ "getstorehours">
    
    <cfset data = ArrayNew(1)/>
    
	<cfquery name="query" datasource="#Application.DSN#">
		SELECT a.id, a.name, a.title, a.meta
		FROM
			tbl_article AS a
		WHERE
			a.collection_id = 2
            AND
            a.status = 1
        <cfif store_id GT 0>
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
    
    <cfif store_id GT 0>
        <cfset result['data'] = data[1]/>
    <cfelse>
        <cfset result['data'] = data/>
    </cfif>
        
    <cfset result['status'] = 1/>
</cfif>

<cfif act EQ "savestorehours">

    <cfset data = DeserializeJSON(data) />

    <cfif debug>    
        <cfset ArrayAppend(result['debug'], "data=")/>
        <cfset ArrayAppend(result['debug'], data)/>
    </cfif>

    <cfset result['status'] = 1/>
    
    <cfif store_id GT 0>   
    
        <cfquery name="query" datasource="#Application.DSN#">
            SELECT a.id, a.name, a.title, a.meta
            FROM
                tbl_article AS a
            WHERE
                a.collection_id = 2
                AND a.status = 1
                AND a.name = '#store_id#'
        </cfquery>
        <cfif query.RecordCount GT 0>

            <cfset meta = DeserializeJSON(query.meta[1])/>
<cfset data['old_meta'] = Duplicate(meta)/>

            <cfset meta['google_structured_data'] = data['meta.google_structured_data']/>

<cfset data['new_meta'] = Duplicate(meta)/>
            
        <cfelse>
            <cfset result['status'] = -2/>
            <cfset result['message'] = "Store not found"/>
        </cfif>
            
    <cfelse>    
        
<cfset data['TEST'] = "testing 2"/>
    </cfif>
    
    <cfset result['data'] = data/>
    
    <cfset result['form'] = form/>
</cfif>
    
<cfheader name="Content-Type" value="application/json; charset=utf-8" />
<cfoutput>#SerializeJSON(result)#</cfoutput>
    
</cfprocessingdirective>