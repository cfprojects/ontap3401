<cfif isSimpleValue(tap.view.content)>
	<cfoutput>#tap.view.content#</cfoutput>
<cfelse>
	<cf_display html="#tap.view.content#" />
</cfif>
