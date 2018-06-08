<cfapplication
name = "tbsstores2"
clientmanagement = "No"
setclientcookies = "Yes"
sessionmanagement = "Yes"
sessiontimeout = #CreateTimeSpan(0, 1, 0, 0)#
applicationtimeout = #CreateTimeSpan(0, 1, 0, 0)#
setdomaincookies = "No">
<cfset Application.COMPANY = 'tbsstores2dev'>
<cfset Application.DSN = 'tbsstores2_dev'>
<cfset Application.PATH = 'c:/inetpub/wwwroot/tbsstores2/'>
<cfset Application.DIRECTORY = '/'>
<cfset Application.FFMAP = 'forefront_6'>
<cfset Application.TRACKLEVEL = 1>
<cfset Application.CACHEEXPIRE = CreateTimeSpan(0,2,0,0)><!--- Days,Hours,Minutes,Seconds --->
<cfset Application.STATUS = 'dev'>

<cfif StructKeyExists(Application,'custom') EQ false>
	<cfset Application.custom = StructNew()/>
</cfif>
	
<cfif StructKeyExists(Application.custom,'zones') EQ false>
	<cfset Application.custom.zones = StructNew()/>
	<cfquery name="query" datasource="#Application.DSN#">
		SELECT role_id,role FROM tbl_application_roles WHERE description LIKE 'Zone:%'
	</cfquery>
	<cfloop from="1" to="#query.RecordCount#" index="i">
		<cfset Application.custom.zones[query.role_id[i]] = query.role[i]/>
	</cfloop>
</cfif>

<cfset Application.custom.domains = ArrayNew(1)/>
<cfif Application.status EQ "dev">
	<cfset ArrayAppend(Application.custom.domains, ["tbsstores2dev.innovasium.com",	"D2FC2C88-D7A5-4275-9DC3-3B41AFD7BE38",	"tbs",	"The Bargain Shop"])/>
	<cfset ArrayAppend(Application.custom.domains, ["rastores2dev.innovasium.com",	"C46C5B09-BF6E-495E-98BF-757821ED7825",	"ra",	"Red Apple Stores"])/>
<cfelse>
	<cfset ArrayAppend(Application.custom.domains, ["tbsstores2.innovasium.com,www.thebargainshop.com,www.tbsstores.com,www.tbsstores.net,tbsstores2dev.innovasium.com",			"D2FC2C88-D7A5-4275-9DC3-3B41AFD7BE38",	"tbs",	"The Bargain Shop"])/>
	<cfset ArrayAppend(Application.custom.domains, ["rastores2.innovasium.com,www.redapplestores.com,www.redapplestores.ca,rastores2dev.innovasium.com",	"C46C5B09-BF6E-495E-98BF-757821ED7825",	"ra",	"Red Apple Stores"])/>
</cfif>
	
<!---
<cfif StructKeyExists(Application,'locations') EQ false>
	<cfheader name="Debug-App-Reset" value="1"/>
	
	<cfobject component="forefront_6.components.location" name="comLocations"/>
	
	<cfinvoke component="#comLocations#" method="init">
		<cfinvokeargument name="dsn" value="#Application.DSN#" />
	</cfinvoke>

	<cfset Application.locations = comLocations.locations/>
</cfif>
--->
	
<cfsetting showdebugoutput="yes"/>
