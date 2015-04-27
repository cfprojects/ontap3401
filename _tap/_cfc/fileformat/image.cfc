<cfcomponent displayname="Image File Format" extends="binary">
	<cfset variables.format = "image">
	
	<cffunction name="readFromDisk" access="private" output="false">
		<cfargument name="file" type="string" required="true">
		<cfreturn ImageRead(arguments.file)>
	</cffunction>
	
	<cffunction name="writeToDisk" access="private" output="false">
		<cfargument name="file" type="string" required="true">
		<cfargument name="output" type="any" required="true">
		<cfargument name="mode" type="numeric" required="false" default="#variables.defaultmode#">
		<cfargument name="attributes" type="string" required="false" default="#variables.defaultattributes#">
		
		<cfif isBinary(arguments.output)>
			<cfset super.writeToDisk(argumentcollection=arguments)>
		<cfelseif isSimpleValue(arguments.output)>
			<cfset ImageWrite(ImageReadBase64(arguments.output),arguments.file)>
		<cfelse>
			<cfset ImageWrite(arguments.output,arguments.file)>
		</cfif>
	</cffunction>
	
	<cffunction name="delete" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true">
		<cfargument name="lockwait" type="numeric" default="#variables.defaulttimeout#">
		
		<cfset super.delete(arguments.file,arguments.lockwait)>
		<cfset getIoC().getBean("thumbnail").CleanUp(arguments.file)>
	</cffunction>
</cfcomponent>