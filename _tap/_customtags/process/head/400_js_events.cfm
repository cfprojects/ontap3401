<cfif getTap().getPage().script>
	<cfset dp = getTap().getHTML().getDatePicker() />
	<cfoutput>
		<cfif dp.isEnabled()>#dp.getHTMLHead()#</cfif>
		
		<cfloop item="x" collection="#getTap().getPage().events#">
			<cfif len(trim(getTap().getPage().events[x]))>
				<cfset variables.fname = getLib().serialize()>
				#getLib().jsout(getLib().js.function(variables.fname,getTap().getPage().events[x]))# 
				<cfset getTap().getPage().body[x] = variables.fName & "();">
			</cfif>
		</cfloop>
	</cfoutput>
</cfif>
