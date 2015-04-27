<!--- get the content directory for this content from the application framework --->
<cfset variables.tap.layout = "content" />
<cfset variables.tap_templates = getFS().processTemplates(variables.tap.nest,variables.tap.layout) />

<cfif arraylen(tap_templates)>
	<cfloop index="cfmod" list="#arrayToList(tap_templates)#">
	<cfinclude template="#cfmod#"></cfloop>
<cfelse>
	<!--- there are no content templates for the process - use default display modes --->
	<cfinclude template="/inc/displaymode/master.cfm">
</cfif>

