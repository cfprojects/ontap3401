<cflock name="#attributes.file#" type="readonly" timeout="#attributes.timeout#">
	<cfif fileexists(attributes.file)>
		<cfinclude template="#request.fs.getPathTo(attributes.file)#">
	</cfif>
</cflock>

<cfparam name="variables.returnvalue" default="">
<cfset caller.filedata = variables.returnvalue>
