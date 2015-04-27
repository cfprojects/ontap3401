<cfcomponent displayname="Zip File Format" extends="zipengine7">
	<cfset variables.format = "zip">
	
	<cffunction name="read" access="public" output="false" returntype="any">
		<cfargument name="file" type="string" required="true">
		<cfset var qZip = QueryNew("comment,name,directory,compressedsize,size,crc,type")>
		
		<cfif DirectoryExists(file)><cfreturn qZip></cfif>
		
		<cftry>
			<cfzip action="list" name="qZip" file="#arguments.file#" filter="*" showDirectory="true" />
			<cfcatch></cfcatch>
		</cftry>
		
		<cfreturn qZip>
	</cffunction>
	
	<cffunction name="write" access="public" output="false" returntype="void">
		<cfargument name="output" type="string" required="true">
		<cfargument name="file" type="string" required="true">
		<cfargument name="relativeFrom" type="string" required="true">
		<cfset var entryPath = getPathTo(arguments.output,arguments.relativeFrom)>
		
		<cfzip action="zip" file="#arguments.file#" storePath="true" overwrite="true">
			<cfzipparam source="#arguments.output#" recurse="true" 
				entryPath="#entryPath#" prefix="#entryPath#" />
		</cfzip>
	</cffunction>
	
	<cffunction name="extract" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true">
		<cfargument name="destination" type="string" required="true">
		<cfargument name="selectedFile" type="string" required="false" default="">
		
		<cfzip action="unzip" file="#arguments.file#" 
		destination="#arguments.destination#" 
		recurse="true" storePath="true" overwrite="true">
			<cfif len(trim(arguments.selectedFile))>
				<cfzipparam entrypath="#arguments.selectedFile#" recurse="true" />
			</cfif>
		</cfzip>
	</cffunction>
</cfcomponent>