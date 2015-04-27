<cfif comparenocase("filenotfound",variables.tap.process)>
	<!--- the process could not be found -- include the process not found process 
	-- above condition ensures that the tag doesn't create an infinite loop while attempting to display the filenotfound process --->
	<cfset temp = StructCopy(attributes) />
	<cfset temp.netaction = "filenotfound" />
	<cfset temp.tapdocs = "false" />
	<cfset temp.processnotfound = variables.tap.process />
	<cf_process attributecollection="#temp#" />
<cfelse>
	<!--- neither the process nor the process-not-found process could be found -- throw an error instead --->
	<cfthrow type="ontap.processNotFound" message="onTap: Process Not Found" 
	detail="Unable to locate the onTap framework ""file not found"" process." />
</cfif>
