<!--- display nested layout headers --->
<cfif getTap().getPage().layout is "body" and findnocase("html",getTap().getPage().doctype)>
	<cfset variables.tap.layout = "header">
	<cfloop index="t" from="1" to="#arraylen(variables.tap.nest)#">
		<cfset variables.layoutpath = variables.tap.nest[t] & "/_layout.cfm">
		<cfset variables.abslayout = getFS().getPath(variables.layoutpath,"P")>
		
		<cfif getTap().brand>
			<!--- check for a branded layout template and occlude the default layout if it is found --->
			<cfset variables.absbrand = getFS().getPath(variables.layoutpath,"B")>
			<cfif fileexists(variables.absbrand)><cfset variables.abslayout = variables.absbrand></cfif>
		</cfif>
		
		<cfif fileexists(variables.abslayout) and 
			not structkeyexists(getTap().getPage().layouts,variables.abslayout)>
			<cfset getTap().getPage().layouts[variables.abslayout] = variables.tap.layout>
			<cfif getTap().development><cfset arrayappend(getTap().getCF().onrequestend.patharray,numberformat(iif(fileexists(variables.abslayout),1,0),00) & " - " & variables.abslayout)></cfif>
			<cfinclude template="#getFS().getPathTo(variables.abslayout)#">
		</cfif>
	</cfloop>
</cfif>
