<cfparam name="tap.view.response" default="#tap.view.content#" />

<cfif isSimpleValue(tap.view.response)>
	<cfset writeoutput(getLib().html.gatewayRespond(tap.view.response)) />
<cfelseif structKeyExists(tap.view.response,"element")>
	<cf_display html="#tap.view.response#" />
<cfelse>
	<cfloop index="x" list="#structKeyList(tap.view.response)#">
		<cfset tmp = tap.view.response[x] />
		<cfset structDelete(tap.view.response, x) />
		
		<cfif isSimpleValue(tmp)>
			<cfset tap.view.response["#lcase(x)#"] = tmp />
		<cfelseif isStruct(tmp) and structKeyExists(tmp,"element")>
			<cfset tap.view.response["#lcase(x)#"] = getLib().html.show(tmp) />
		</cfif>
	</cfloop>
	
	<cfset writeoutput(getLib().html.gatewayRespond(serializeJSON(tap.view.response))) />
	<cfset tap.goto.href = "" />
</cfif>
