<cfcomponent displayname="Text File Format" extends="fileformat">
	<cfset variables.format = "text">
	
	<cffunction name="textToOutput" access="private" output="false" returntype="string">
		<cfargument name="output" type="string" required="true">
		<cfreturn arguments.output>
	</cffunction>
	
	<cffunction name="outputToText" access="private" output="false" returntype="string">
		<cfargument name="output" type="string" required="true">
		<cfreturn arguments.output>
	</cffunction>
	
	<cffunction name="append" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true">
		<cfargument name="output" type="any" required="true">
		<cfargument name="charset" type="string" required="false" default="#variables.defaultcharset#">
		<cfargument name="mode" type="numeric" required="false" default="#variables.defaultmode#">
		<cfargument name="attributes" type="string" required="false" default="#variables.defaultattributes#">
		<cfargument name="lockwait" type="numeric" default="#variables.defaulttimeout#">
		
		<cflock name="#getDirectoryFromPath(arguments.file)#" type="exclusive" timeout="#arguments.lockwait#">
			<cflock name="#arguments.file#" type="exclusive" timeout="#arguments.lockwait#">
				<cfif fileExists(arguments.file)>
					<cffile action="append" file="#arguments.file#" output="#arguments.output#" 
					charset="#arguments.charset#" mode="#arguments.mode#" attributes="#arguments.attributes#">
				<cfelse>
					<cfset getFS().mkdir(getdirectoryfrompath(arguments.file),"")>
					<cffile action="write" file="#arguments.file#" output="#arguments.output#" 
					charset="#arguments.charset#" mode="#arguments.mode#" attributes="#arguments.attributes#">
				</cfif>
				<cfset fileMan.setModified(arguments.file)>
			</cflock>
		</cflock>
	</cffunction>
</cfcomponent>