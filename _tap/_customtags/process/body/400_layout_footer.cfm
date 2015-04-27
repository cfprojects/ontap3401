<!--- display nested layout footers --->
<cfif getTap().getPage().layout is "body" and findnocase("html",getTap().getPage().doctype)>
	<cfset variables.tap.layout = "footer">
	<cfloop index="t" from="#arraylen(variables.tap.nest)#" to="1" step="-1">
		<cfset variables.layoutpath = variables.tap.nest[t] & "/_layout.cfm">
		<cfset variables.abslayout = getFS().getPath(variables.layoutpath,"P")>
		
		<cfif getTap().brand>
			<!--- check for a branded layout template and occlude the default layout if it is found --->
			<cfset variables.absbrand = getFS().getPath(variables.layoutpath,"B")>
			<cfif fileexists(variables.absbrand)><cfset variables.abslayout = variables.absbrand></cfif>
		</cfif>
		
		<cfif fileexists(abslayout) and (variables.tap.islocal xor 
			structkeyexists(getTap().getPage().layouts,variables.abslayout))>
			<cfset getTap().getPage().layouts[variables.abslayout] = variables.tap.layout>
			<cfif getTap().development><cfset arrayappend(getTap().getCF().onrequestend.patharray,numberformat(iif(fileexists(variables.abslayout),1,0),00) & " - " & variables.abslayout)></cfif>
			<cfinclude template="#getFS().getPathTo(variables.abslayout)#">
		</cfif>
	</cfloop>
</cfif>
