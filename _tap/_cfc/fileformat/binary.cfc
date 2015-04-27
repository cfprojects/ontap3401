<cfcomponent displayname="Binary File Format" extends="fileformat">
	<cfset variables.format = "binary">
	<cfset variables.binaryFormat = true>
	
	<cffunction name="textToOutput" access="private" output="false" returntype="binary">
		<cfargument name="output" type="binary" required="true">
		<cfreturn arguments.output>
	</cffunction>
	
	<cffunction name="outputToText" access="private" output="false" returntype="binary">
		<cfargument name="output" type="any" required="true" hint="accepts binary or base64 data">
		<cfif not isBinary(arguments.output)>
			<cftry>
				<cfset arguments.output = toBinary(arguments.output) />
				<cfcatch>
					<cfthrow type="onTap.FileFormat.Binary" message="onTap: Binary file contents must be binary or base64 encoded." />
				</cfcatch>
			</cftry>
		</cfif>
		<cfreturn arguments.output>
	</cffunction>
</cfcomponent>
