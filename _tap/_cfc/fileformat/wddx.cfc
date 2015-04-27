<cfcomponent displayname="WDDX File Format" extends="fileformat">
	<cfset variables.format = "wddx">
	
	<cffunction name="textToOutput" access="private" output="false" returntype="any">
		<cfargument name="output" type="string" required="true">
		<cfif len(trim(output))>
			<cfwddx action="wddx2cfml" input="#arguments.output#" output="arguments.output">
		</cfif>
		<cfreturn arguments.output>
	</cffunction>
	
	<cffunction name="outputToText" access="private" output="false" returntype="string">
		<cfargument name="output" type="any" required="true">
		<cfwddx action="cfml2wddx" input="#output#" output="arguments.output">
		<cfreturn arguments.output>
	</cffunction>
</cfcomponent>