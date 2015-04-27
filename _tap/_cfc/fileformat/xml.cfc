<cfcomponent displayname="XML File Format" extends="fileformat">
	<cfset variables.format = "xml">
	<cfset variables.defaultcasesensitive = false>
	
	<cffunction name="textToOutput" access="private" output="false" returntype="any">
		<cfargument name="output" type="string" required="true">
		<cfargument name="casesensitive" type="boolean" default="#variables.defaultcasesensitive#">
		<cfif len(trim(output))>
			<cfset output = XMLParse(arguments.output,arguments.casesensitive)>
		</cfif>
		<cfreturn output>
	</cffunction>
	
	<cffunction name="outputToText" access="private" output="false" returntype="string">
		<cfargument name="output" type="any" required="true">
		<cfreturn toString(arguments.output)>
	</cffunction>
</cfcomponent>