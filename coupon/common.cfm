<cfprocessingdirective suppresswhitespace="yes" pageencoding="utf-8">
<cfsetting enablecfoutputonly="yes"/>
    
<cfparam name="coupon_id" type="string" default=""/>
<cfparam name="contest_id" type="string" default="0"/>
<cfparam name="debug" type="string" default="0"/>

<cfset coupon_id = Trim(coupon_id)/>
<cfset contest_id = Val(contest_id)/>
<cfset debug = Val(debug)/>
    
<cfset pdffile = ArrayNew(1)/>
<cfset pdffile[1] = ExpandPath("./tbs-coupon-template.pdf")/><!--- For TBS --->
<cfset pdffile[2] = ExpandPath("./tbs-coupon-template.pdf")/><!--- For RA --->
    
<cfset customer_id = 0/>
<cfset site_id = 0/>
<cfset timestamp = 0/>

<cfset customer = StructNew()/>
<cfset customer.id = 0/>
<cfset customer.site_id = 0/>
<cfset customer.date_registered = 0/>
<cfset customer.fname = ""/>
<cfset customer.lname = ""/>
    
<cfif Left(coupon_id,4) EQ "test">
    <cfset tmp = Mid(coupon_id,5,99)/>
	<cfset customer.id = Val(tmp)/>
<cfelseif Left(coupon_id,2) EQ "mc">
	<cfset fromMC = true/>
	<cfset tmp = MID(coupon_id,3,99)/>
	<cfset tmp = Replace(tmp,",","","all")/>
	<cfset customer.id = Val(tmp)/>
<cfelseif coupon_id NEQ "">
	<cfset tmp = dcode(coupon_id,2)/>
	<cfset parameters = ListToArray(tmp,'|')/>
	<cfset customer.id = Val(parameters[1])/>
	<cfset customer.site_id = Val(parameters[2])/>
	<cfif ArrayLen(parameters) GT 2>
		<cfset customer.date_registered = REReplace(parameters[3],"/[^\d]/","","all")/>
		<cfif customer.date_registered NEQ parameters[3]>
            <cfset customer.date_registered = 0/>
        </cfif>
    </cfif>
<cfelse>
</cfif>

<cfif debug>
    <cfoutput>
<cfdump var="#customer#" label="customer:before"/>
    </cfoutput>
</cfif>
    
<cfif customer.id GT 0>
	<cfquery name="query" datasource="tbsstores_users">
        SELECT
            r.customer_date_registered
            <!---r.customer_date_modified--->
            ,r.customer_fname
            ,r.customer_lname
            ,s.site_id
        FROM
            registration AS r
            LEFT JOIN stores AS s on s.store_id = r.customer_store_id
        WHERE
            r.customer_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#customer.id#"/>
    </cfquery>
    <cfif debug>
        <cfoutput><cfdump var="#query#"/></cfoutput>
    </cfif>
    
    <cfif query.RecordCount GT 0>  
        <cfif customer.date_registered EQ 0>
            <cfset customer.date_registered = ParseDateTime(query.customer_date_registered[1])/>
        </cfif>
        <cfif customer.site_id EQ 0>
            <cfset customer.site_id = query.site_id[1]/>
        </cfif>
        <cfset customer.fname = query.customer_fname[1]/>
        <cfset customer.lname = query.customer_lname[1]/>
    <cfelse>
        <cfoutput>Error: Not found</cfoutput>
        <cfabort/>
    </cfif>
            
</cfif>

<cfif debug>
    <cfoutput>
<cfdump var="#customer#" label="customer:after"/>
    </cfoutput>
</cfif>
    
<!--- ============================= --->
    
<cffunction name="dcode" returntype="string">
    <cfargument name="s" type="string"/>
    <cfargument name="l" type="numeric"/>
    <cfset var i = 0/>
    <!---cfloop from="1" to="#l#" index="i"--->
        <cfset s = ToString( ToBinary( Reverse(s) ) ) />               
    <!---/cfloop--->
<!---
    for($i=0;$i<$l;$i=$i+4) {
        $s=base64_decode(strrev($s));
    }
    return $s;
--->                         
    <cfreturn s/>
</cffunction>

<cffunction name="ecode" returntype="string">
    <cfargument name="s" type="string"/>
    <cfargument name="l" type="numeric"/>
    <cfset s = Reverse(ToBase64(s)) />
<!---    
function ecode($s,$l) {
  for($i=0;$i<$l;$i=$i+4) $s=strrev(base64_encode($s)); return $s;
}
--->
    <cfreturn s/>
</cffunction>
    
<!--- ================== --->

<cfheader name="customer_id" value="#customer_id#"/>

</cfprocessingdirective>    