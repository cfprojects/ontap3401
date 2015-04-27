<cfcomponent displayname="Zip File Format" extends="fileformat">
	<cfset variables.format = "zip">
	
	<cffunction name="initFileFormat" access="private" output="false">
		<cfargument name="version" type="string" required="false" default="#server.ColdFusion.ProductVersion#">
		<cfif val(version) gte 8><cfset variables.engine = CreateObject("component","zipengine").init(fileMan,version)>
		<cfelse><cfset variables.engine = CreateObject("component","zipengine7").init(fileMan,version)></cfif>
	</cffunction>
	
	<cffunction name="getPathTo" access="private" output="false" returntype="string">
		<cfargument name="targetfile" type="string" required="true">
		<cfargument name="fromsource" type="string" required="true">
		<cfreturn getFS().getPathTo(targetfile,"",false,fromsource)>
	</cffunction>
	
	<cffunction name="read" access="public" output="false" returntype="any">
		<cfargument name="file" type="string" required="true">
		<cfreturn variables.engine.read(argumentcollection=arguments)>
	</cffunction>
	
	<cffunction name="write" access="public" output="false" returntype="void">
		<cfargument name="output" type="string" required="true">
		<cfargument name="file" type="string" required="true" default="#REReplaceNoCase(arguments.output,'\.[_[:alnum:]]+$','')#.zip">
		<cfargument name="relativeFrom" type="string" required="false" default="#getDirectoryFromPath(output)#">
		
		<cfset variables.engine.write(argumentcollection=arguments)>
		<cfset variables.fileMan.clearFileCache(getDirectoryFromPath(arguments.file),false)>
	</cffunction>
	
	<cffunction name="extract" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true">
		<cfargument name="destination" type="string" required="true">
		<cfargument name="selectedFile" type="string" required="false" default="">
		
		<cfif not DirectoryExists(destination)><cfset mkdir(destination,"")></cfif>
		<cfset variables.engine.extract(argumentcollection=arguments)>
		<cfset variables.fileMan.clearFileCache(getPath(destination,""),false)>
	</cffunction>
</cfcomponent>