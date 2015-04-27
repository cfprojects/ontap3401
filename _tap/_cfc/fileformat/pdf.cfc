<cfcomponent displayname="PDF File Format" extends="fileformat">
	<cffunction name="read" access="public" output="false" returntype="any">
		<cfthrow type="ontap.file.unreadable" 
			message="onTap: Unreadable File Format" 
			extendedinfo="#arguments.file#" 
			detail="unable to perform read operation on PDF">
	</cffunction>
	
	<cffunction name="write" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true">
		<cfargument name="output" type="any" required="true">
		<cfargument name="overwrite" type="boolean" default="#variables.defaultoverwrite#">
		<cfargument name="lockwait" type="numeric" default="#variables.defaulttimeout#">
		
		<cflock name="#getDirectoryFromPath(arguments.file)#" type="exclusive" timeout="#arguments.lockwait#">
			<cflock name="#arguments.file#" type="exclusive" timeout="#arguments.lockwait#">
				<cfif fileExists(arguments.file) and not arguments.overwrite>
					<cfthrow type="ontap.file.overwrite" message="onTap: File Overwrite Not Enabled" extendedinfo="#arguments.file#" 
					detail="The file #arguments.file# already exists. Use the attribute overwrite=""true"" to allow this file to be overwritten.">
				</cfif>
				
				<cfset getFS().mkdir(getdirectoryfrompath(arguments.file),"")>
				<cfdocument format="pdf" filename="#attributes.file#">#arguments.output#</cfdocument>
				<cfset fileMan.setModified(arguments.file)>
			</cflock>
		</cflock>
	</cffunction>
</cfcomponent>