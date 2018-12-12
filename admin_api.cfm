<cfprocessingdirective suppresswhitespace="yes" pageencoding="utf-8">
<cfsetting enablecfoutputonly="yes" />
    
<cfparam name="act" type="string" default=""/>
<cfparam name="store_id" type="string" default=""/>
<cfparam name="data" type="string" default=""/>
<cfparam name="key" type="string" default=""/>
<cfparam name="out" type="string" default="json"/>
<cfparam name="debug" type="string" default="0"/>
    
<cfset result = StructNew()/>
<cfset result['status'] = 0/>
<cfset result['message'] = ""/>

<cfset store_id = Val(store_id)/>
<cfset data = Trim(data)/>
<cfset debug = Val(debug)/>
<cfset cache_status = 0 />
    
<cfif debug>    
    <cfset result['debug'] = ArrayNew(1)/>
    <cfset ArrayAppend(result['debug'], "act=[#act#] store_id=[#store_id#] key=[#key#]")/>
</cfif>
    
<!--- Check key --->
<cfset keymatch = Hash(act & DateFormat(Now(),'YYYYMMDD'), 'MD5')/>
<cfif debug>    
    <cfset ArrayAppend(result['debug'], "keymatch=[#keymatch#]")/>
</cfif>
<cfif debug EQ 0 AND key NEQ keymatch>
    <cfset result['message'] = "Unauthorized [#keymatch#]"/>
    <cfset result['status'] = -1/>
    <cfset act = ""/>
</cfif>
    
<cfif act EQ "getstorehours">
    
    <cfset data = ArrayNew(1)/>
    
	<cfquery name="query" datasource="#Application.DSN#">
		SELECT a.id, a.name, a.title, a.meta, l.provstate
		FROM
			tbl_article AS a
			LEFT JOIN tbl_location_location_x_article AS lxa ON lxa.article_id = a.id
			LEFT JOIN tbl_location AS l ON l.id = lxa.location_id
		WHERE
			a.collection_id = 2
            AND a.status = 1
            AND l.location_type = 3
        <cfif store_id GT 0>
            AND a.name = '#store_id#'
        </cfif>
	</cfquery>
    <cfif query.RecordCount EQ 0>
        <cfset result['status'] = -2/>
        <cfset result['message'] = "Store not found"/>
    <cfelse>
        <cfloop from="1" to="#query.RecordCount#" index="i">

            <cfset tmp = StructNew()/>

            <cfset meta = DeserializeJSON(query.meta[i])/>

            <cfset structured_data = StructNew()/>
            <cfif StructKeyExists(meta,'google_structured_data')>
                <cftry>
                    <cfset structured_data = DeserializeJSON(meta['google_structured_data'])/>
                    <cfcatch>
                        <!---cfset tmp['error.structured_data'] = cfcatch.message/--->
                    </cfcatch>
                </cftry>
            </cfif>

            <cfset hours_note = StructNew()/>
            <cfif StructKeyExists(meta,'hours_note')>
                <cftry>
                    <cfset hours_note = DeserializeJSON(meta['hours_note'])/>
                    <cfcatch>
                        <!---cfset tmp['error.hours_note'] = cfcatch.message/--->
                    </cfcatch>
                </cftry>
            </cfif>

            <cfset tmp['id'] = query.name[i]/>
            <cfset tmp['store_city'] = query.title[i]/>
            <cfset tmp['store_province'] = query.provstate[i]/>
            <cfset tmp['meta.google_structured_data'] = structured_data/>
            <cfset tmp['meta.hours_note'] = hours_note/>
            <cfset ArrayAppend(data, tmp)/>
        </cfloop>

        <cfif store_id GT 0>
            <cfset result['data'] = data[1]/>
        <cfelse>
            <cfset result['data'] = data/>
        </cfif>
        
        <cfset result['status'] = 1/>
    </cfif>
</cfif>

<cfif act EQ "savestorehours">

    <cfset updateCount = 0/>

    <cfif data EQ "">
        <cfset result['status'] = -3.1/>
        <cfset result['message'] = "No data"/>
    </cfif>

    <cfif debug>    
        <cfset ArrayAppend(result['debug'], "1.data=")/>
        <cfset ArrayAppend(result['debug'], data)/>
    </cfif>

    <cfif result['status'] EQ 0>
        <cftry>
            <cfset data = DeserializeJSON(data) />
            
            <!---<cfif debug>    
                <cfset ArrayAppend(result['debug'], "2.data=")/>
                <cfset ArrayAppend(result['debug'], data)/>
            </cfif>--->
            
            <cfcatch>
                <cfset result['status'] = -3.2/>
                <cfset result['message'] = "Deserialize data error: " & cfcatch.message/>
                <cfset ArrayAppend(result['debug'], "cfcatch=")/>
                <cfset ArrayAppend(result['debug'], cfcatch.message)/>
            </cfcatch>
        </cftry>
    </cfif>

    <cfif result['status'] EQ 0>

        <!--- build articles array --->
        <cfset articles = ArrayNew(1)/>
        <cftry>
            <cfif IsArray(data)>
                <cfloop from="1" to="#ArrayLen(data)#" index="i">
                    <cfset ArrayAppend(articles, {"name"=data[i].id, "id"=0, "data"=data[i], "status"=""})/>
                </cfloop>
                
            <cfelseif IsStruct(data)>
                <cfset ArrayAppend(articles, {"name"=data.id, "id"=0, "data"=data, "status"=""})/>
                
            <cfelse>
                <cfset result['status'] = -3.31/>
                <cfset result['message'] = "Data not struct"/>
                <cfif debug>    
                    <cfset ArrayAppend(result['debug'], "data=")/>
                    <cfset ArrayAppend(result['debug'], data)/>
                </cfif>
            </cfif>

            <cfif debug>    
                <cfset ArrayAppend(result['debug'], "1.articles [#ArrayLen(articles)#]=")/>
                <!---<cfset ArrayAppend(result['debug'], articles)/>--->
            </cfif>
                
            <cfcatch>
                <cfset result['status'] = -3.3/>
                <cfset result['message'] = "Store ids error: " & cfcatch.message/>
                <cfset ArrayAppend(result['debug'], "cfcatch=")/>
                <cfset ArrayAppend(result['debug'], cfcatch)/>
            </cfcatch>
        </cftry>            
    </cfif>

    <cfif result['status'] EQ 0>
        
        <cfset updateCount = 0/>
<!---        
    <cfset result['message'] = "Test-6"/>
    <cfset result['status'] = -1/>
--->        
<cftry>
    
            <cfif debug>    
                <cfset ArrayAppend(result['debug'], "process: len=[#ArrayLen(articles)#]")/>
            </cfif>
    
        <cfloop from="1" to="#ArrayLen(articles)#" index="i">
        
            <cfset article = articles[i]/>
            
            <cfif debug>    
                <cfset ArrayAppend(result['debug'], "process: id=[article.name]")/>
            </cfif>
            
            <cfset articles[i]['status'] = "Start"/>
            
            <!--- Load article --->
            <cfquery name="query" datasource="#Application.DSN#">
                SELECT TOP 1 a.id, a.name, a.title, a.meta
                FROM
                    tbl_article AS a
                WHERE
                    a.collection_id = 2
                    AND a.status = 1
                    AND a.name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#article.name#"/>
            </cfquery>
            <cfset articles[i]['status'] = ListAppend(articles[i]['status'], "found[#query.RecordCount#]")/>

            <cfif query.RecordCount GT 0>

<cfif debug>    
    <cfset ArrayAppend(result['debug'], "query=")/>
    <cfset ArrayAppend(result['debug'], query)/>
</cfif>
                
                <cfset article.id = query.id[1]/>
                <cfset articles[i].id = query.id[1]/>

                <cfset articles[i]['status'] = ListAppend(articles[i]['status'], "id[#article.id#]")/>
                
                <cfif debug>    
                    <cfset ArrayAppend(result['debug'], "id=[#query.id[1]#]")/>
                    <!---
                    <cfset ArrayAppend(result['debug'], "query=")/>
                    <cfset ArrayAppend(result['debug'], query)/>
                    --->
                </cfif>
                
                <!--- Decode meta --->
                <cfif result['status'] EQ 0>
                    <cftry>
                        <cfset meta = DeserializeJSON(query.meta[1])/>
                        <cfcatch>
                            <cfif debug>    
                                <cfset ArrayAppend(result['debug'], "cfcatch=")/>
                                <cfset ArrayAppend(result['debug'], cfcatch)/>
                            </cfif>
                            <cfset result['status'] = -3.4/>
                            <cfset result['message'] = "Deserialize meta error [#i#|#article.id#|#article.name#]: " & cfcatch.message/>
                            <cfset articles[i]['status'] = "Error: " & result['status'] & " " & result['message']/>
                        </cfcatch>
                    </cftry>
                </cfif>
<cfset articles[i]['status'] = ListAppend(articles[i]['status'], "1{#result['status']#}")/>
                
                <cfif result['status'] EQ 0>
                    <cfif meta['google_structured_data'] NEQ "">
                        <cftry>
                            <cfset meta['google_structured_data'] = DeserializeJSON(meta['google_structured_data'])/>
                            <cfcatch>
                                <cfset meta['google_structured_data'] = StructNew()/>
                                <!---
                                <cfif debug>    
                                    <cfset ArrayAppend(result['debug'], "cfcatch=")/>
                                    <cfset ArrayAppend(result['debug'], cfcatch)/>
                                </cfif>
                                <cfset result['status'] = -3.5/>
                                <cfset result['message'] = "Deserialize meta.google_structured_data error [#i#|#article.id#|#article.name#]: " & cfcatch.message/>
                                <cfset articles[i]['status'] = "Error: " & result['status'] & " " & result['message']/>
                                --->
                            </cfcatch>
                        </cftry>
                    <cfelse>
                        <cfset meta['google_structured_data'] = StructNew()/>
                    </cfif>
                </cfif>
<cfset articles[i]['status'] = ListAppend(articles[i]['status'], "2{#result['status']#}")/>
                
                <cfif result['status'] EQ 0>
                    <cfif meta['hours_note'] NEQ "">
                        <cftry>
                            <cfset meta['hours_note'] = DeserializeJSON(meta['hours_note'])/>
                            <cfcatch>
                                <cfset meta['hours_note'] = StructNew()/>
                                <!---
                                <cfif debug>    
                                    <cfset ArrayAppend(result['debug'], "cfcatch=")/>
                                    <cfset ArrayAppend(result['debug'], cfcatch)/>
                                </cfif>
                                <cfset result['status'] = -3.6/>
                                <cfset result['message'] = "Deserialize meta.hours_note error [#i#|#article.id#|#article.name#]: " & cfcatch.message/>
                                <cfset articles[i]['status'] = "Error: " & result['status'] & " " & result['message']/>
                                --->
                            </cfcatch>
                        </cftry>
                    <cfelse>
                        <cfset meta['hours_note'] = StructNew()/>
                    </cfif>
                </cfif>
<cfset articles[i]['status'] = ListAppend(articles[i]['status'], "3{#result['status']#}")/>

                <!--- Update meta from data --->
                <cfif StructKeyExists(article.data,'meta.google_structured_data')>
                    <cfset meta['google_structured_data'] = article.data['meta.google_structured_data']/>
                <!---
                <cfelse>                    
                    <cfset result['status'] = -3.7/>
                    <cfset result['message'] = "meta.google_structured_data not found in data"/>
                    <cfset articles[i]['status'] = "Error: " & result['status'] & " " & result['message']/>
                --->
                </cfif>
                <cfif StructKeyExists(article.data,'meta.hours_note')>
                    <cfset meta['hours_note'] = article.data['meta.hours_note']/>
                <!---
                <cfelse>                    
                    <cfset result['status'] = -3.8/>
                    <cfset result['message'] = "meta.hours_note not found in data"/>
                    <cfset articles[i]['status'] = "Error: " & result['status'] & " " & result['message']/>
                --->
                </cfif>
<cfset articles[i]['status'] = ListAppend(articles[i]['status'], "4{#result['status']#}")/>

                <!--- Encode meta --->
                <cfif result['status'] EQ 0>
                    <cftry>
                        <cfset meta['google_structured_data'] = SerializeJSON(meta['google_structured_data'])/>
                        <cfcatch>
                            <cfif debug>    
                                <cfset ArrayAppend(result['debug'], "cfcatch=")/>
                                <cfset ArrayAppend(result['debug'], cfcatch)/>
                            </cfif>
                            <cfset result['status'] = -3.9/>
                            <cfset result['message'] = "Serialize meta.google_structured_data error: " & cfcatch.message/>
                            <cfset articles[i]['status'] = "Error: " & result['status'] & " " & result['message']/>
                        </cfcatch>
                    </cftry>
                </cfif>
<cfset articles[i]['status'] = ListAppend(articles[i]['status'], "5{#result['status']#}")/>

                <cfif result['status'] EQ 0>
                    <cftry>
                        <cfset meta['hours_note'] = SerializeJSON(meta['hours_note'])/>
                        <cfcatch>
                            <cfif debug>    
                                <cfset ArrayAppend(result['debug'], "cfcatch=")/>
                                <cfset ArrayAppend(result['debug'], cfcatch)/>
                            </cfif>
                            <cfset result['status'] = -3.10/>
                            <cfset result['message'] = "Serialize meta.hours_note error [#i#|#article.id#|#article.name#]: " & cfcatch.message/>
                            <cfset articles[i]['status'] = "Error: " & result['status'] & " " & result['message']/>
                        </cfcatch>
                    </cftry>
                </cfif>
<cfset articles[i]['status'] = ListAppend(articles[i]['status'], "6{#result['status']#}")/>

                <!---<cfif debug>    
                    <cfset ArrayAppend(result['debug'], "2.meta=")/>
                    <cfset ArrayAppend(result['debug'], meta)/>
                </cfif>--->
                    
                <!--- Save article --->
                
                <cfif result['status'] EQ 0>
                    <cftry>
                        <cfset articleMeta = SerializeJSON(meta)>
                        <!---<cfif debug>    
                            <cfset ArrayAppend(result['debug'], "articleMeta=")/>
                            <cfset ArrayAppend(result['debug'], articleMeta)/>
                        </cfif>--->
                        <cfcatch>
                            <cfif debug>    
                                <cfset ArrayAppend(result['debug'], "cfcatch=")/>
                                <cfset ArrayAppend(result['debug'], cfcatch)/>
                            </cfif>
                            <cfset result['status'] = -3.11/>
                            <cfset result['message'] = "Serialize meta error [#i#|#article.id#|#article.name#]: " & cfcatch.message/>
                            <cfset articles[i]['status'] = "Error: " & result['status'] & " " & result['message']/>
                        </cfcatch>
                    </cftry>
                </cfif>
<cfset articles[i]['status'] = ListAppend(articles[i]['status'], "7{#result['status']#}")/>
                   
                <cfif result['status'] EQ 0>

                    <cfif debug>    
                        <cfset ArrayAppend(result['debug'], "update")/>
                    </cfif>
                    
                    <cfset updateCount = updateCount + 1/>

                    <cfquery name="query" datasource="#Application.DSN#" result="queryResult">
                        UPDATE tbl_article
                        SET meta = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#articleMeta#"/>
                        WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#article.id#"/>
                    </cfquery>

                    <!---<cfif debug>    
                        <cfset ArrayAppend(result['debug'], "queryResult=")/>
                        <cfset ArrayAppend(result['debug'], queryResult)/>
                    </cfif>--->

                    <cfif debug>    
                        <cfset ArrayAppend(result['debug'], "clear cache")/>
                    </cfif>
                        
                    <cfquery name="query" datasource="#Application.DSN#" result="queryResult">
                        UPDATE tbl_cache
                        SET status = #cache_status#
                        WHERE url LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%/store/#article.name#%"/>
                    </cfquery>
                        
                    <cfset articles[i]['status'] = ListAppend(articles[i]['status'], "Saved")/>
                        
                </cfif>

            <cfelse>
                <cfset articles[i]['status'] = ListAppend(articles[i]['status'], "Error: Store not found")/>
                <cfset articles[i]['status'] = "Error: Store not found"/>
                <!---
                <cfset result['status'] = -3.3/>
                <cfset result['message'] = "Store not found"/>
                --->
            </cfif>

            <cfset articles[i]['status'] = ListAppend(articles[i]['status'], "Done")/>

        </cfloop>
                    
    <cfcatch>
        <cfif debug>    
            <cfset ArrayAppend(result['debug'], "cfcatch=")/>
            <cfset ArrayAppend(result['debug'], cfcatch)/>
        </cfif>
        <cfset result['message'] = cfcatch.message/>
        <cfset result['status'] = -3.99/>
    </cfcatch>
</cftry>

        <cfif debug>    
            <cfset ArrayAppend(result['debug'], "2.articles [#ArrayLen(articles)#]=")/>
            <cfset ArrayAppend(result['debug'], articles)/>
        </cfif>
                    
    </cfif>
                    
    <cfif result['status'] EQ 0>

        <cfif debug>    
            <cfset ArrayAppend(result['debug'], "updateCount=[#updateCount#]")/>
        </cfif>
        
        <cfif updateCount GT 0>                    
            <cfset result['status'] = 1/>
            <cfset result['data'] = "ok, updated #updateCount#"/>
        <cfelse>            
            <cfset result['status'] = 0/>
            <cfset result['data'] = "no change"/>
        </cfif>
                    
    </cfif>
        
</cfif>

<cfif out EQ "json">
    <cfheader name="Content-Type" value="application/json; charset=utf-8" />
    <cfoutput>#SerializeJSON(result)#</cfoutput>
<cfelse>
    <cfdump var="#result#" label="result"/>
</cfif>
    
</cfprocessingdirective>