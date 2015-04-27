<cfcomponent displayname="File Format">
	<cfinclude template="/cfc/mixin/tap.cfm" />
	
	<cfset variables.binaryFormat = false>
	<cfset variables.defaultoverwrite = true>
	<cfset variables.defaultcharset = getTap().getPage().charset>
	<cfset variables.defaultmode = 775>
	<cfset variables.defaultattributes = "normal">
	<cfset variables.defaulttimeout = 5>
	<cfset variables.defaultnewline = false>
	<cfset variables.defaultnameconflict = "overwrite">
	<cfset variables.defaultaccept = "">
	<cfset variables.defaultdeletefile = false>
	<cfset variables.defaultcache = true>
	<cfset variables.defaultrefresh = getTap().development>
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="FileManager" required="true">
		<cfset variables.fileMan = arguments.fileManager>
		<cfset initFileFormat(argumentcollection=arguments)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="readDirectory" output="false" access="public" returntype="query" 
	hint="returns a query containing information about files and directories in the loaded file path">
		<cfargument name="directory" type="string" required="true">
		<cfargument name="filter" type="string" required="false" default="*">
		<cfargument name="sort" type="string" required="false" default="name">
		<cfargument name="recurse" type="boolean" required="false" default="false">
		<cfset var rsfile = 0>
		
		<cfdirectory name="rsfile" action="list" 
				directory="#arguments.directory#" recurse="#arguments.recurse#" 
				filter="#arguments.filter#" sort="#arguments.sort#">
		
		<cfreturn rsfile>
	</cffunction>
	
	<cffunction name="initFileFormat" access="private" output="false">
		<!--- put initialization requirements for subclasses in this function --->
	</cffunction>
	
	<cffunction name="getPath" access="public" output="false" returntype="string">
		<cfargument name="path" type="string" required="true">
		<cfargument name="domain" type="string" required="true">
		<cfreturn getFS().getPath(arguments.path,arguments.domain)>
	</cffunction>
	
	<cffunction name="mkDir" access="public" output="false">
		<cfargument name="path" type="string" required="true">
		<cfset fileMan.mkDir(arguments.path)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="clearCache" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true">
		<cfset fileMan.clearFileCache(arguments.file,true)>
	</cffunction>
	
	<cffunction name="read" access="public" output="false" returntype="any">
		<cfargument name="file" type="string" required="true">
		<cfargument name="charset" type="string" required="false" default="#variables.defaultcharset#">
		<cfargument name="refresh" type="boolean" required="false" default="#variables.defaultrefresh#">
		<cfargument name="lockwait" type="numeric" required="false" default="#variables.defaulttimeout#">
		<cfset var result = structNew() />
		<cfset arguments.output = "">
		
		<cfif DirectoryExists(file)>
			<cfreturn readDirectory(arguments.file) />
		</cfif>
		
		<cfif not arguments.refresh>
			<cfset result = fileMan.getFileCache(arguments.file,variables.format) />
			<cfif not result.status>
				<cfreturn duplicate(result.content) />
			</cfif>
		</cfif>
		
		<cflock name="#arguments.file#" type="readonly" timeout="#arguments.lockwait#">
			<cfif fileExists(arguments.file)>
				<cfset arguments.output = readFromDisk(arguments.file,arguments.charset)>
			</cfif>
		</cflock>
		
		<cfinvoke method="textToOutput" argumentcollection="#arguments#" returnvariable="arguments.output">
		
		<cfset fileMan.setFileCache(arguments.file,variables.format,arguments.output,true) />
		
		<cfreturn duplicate(arguments.output)>
	</cffunction>
	
	<cffunction name="readFromDisk" access="private" output="false">
		<cfargument name="file" type="string" required="true">
		<cfset var fileAction = "read">
		<cfif variables.binaryFormat><cfset fileAction = "readBinary"></cfif>
		<cffile action="#fileaction#" variable="arguments.file" file="#arguments.file#">
		<cfreturn arguments.file>
	</cffunction>
	
	<cffunction name="write" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true">
		<cfargument name="output" type="any" required="true">
		<cfargument name="addnewline" type="boolean" default="#variables.defaultnewline#">
		<cfargument name="overwrite" type="boolean" default="#variables.defaultoverwrite#">
		<cfargument name="charset" type="string" required="false" default="#variables.defaultcharset#">
		<cfargument name="mode" type="numeric" required="false" default="#variables.defaultmode#">
		<cfargument name="attributes" type="string" required="false" default="#variables.defaultattributes#">
		<cfargument name="lockwait" type="numeric" default="#variables.defaulttimeout#">
		
		<cflock name="#getDirectoryFromPath(arguments.file)#" type="exclusive" timeout="#arguments.lockwait#">
			<cflock name="#arguments.file#" type="exclusive" timeout="#arguments.lockwait#">
				<cfif fileExists(arguments.file) and not arguments.overwrite>
					<cfthrow type="ontap.file.overwrite" message="onTap: File Overwrite Not Enabled" extendedinfo="#arguments.file#" 
					detail="The file #arguments.file# already exists. Use the attribute overwrite=""true"" to allow this file to be overwritten.">
				</cfif>
				
				<cfinvoke method="outputToText" argumentcollection="#arguments#" returnvariable="arguments.output">
				
				<cfset mkdir(getdirectoryfrompath(arguments.file))>
				<cfset arguments.overwrite = FileExists(arguments.file)>
				<cfinvoke method="writetodisk" argumentcollection="#arguments#">
				<cfif arguments.overwrite>
					<cfset fileMan.setModified(arguments.file)>
				<cfelse>
					<cfset fileMan.clearFileCache(getDirectoryFromPath(arguments.file),false)>
				</cfif>
			</cflock>
		</cflock>
	</cffunction>
	
	<cffunction name="writeToDisk" access="private" output="false">
		<cfargument name="file" type="string" required="true">
		<cfargument name="output" type="any" required="true">
		<cfargument name="addnewline" type="boolean" default="#variables.defaultnewline#">
		<cfargument name="charset" type="string" required="false" default="#variables.defaultcharset#">
		<cfargument name="mode" type="numeric" required="false" default="#variables.defaultmode#">
		<cfargument name="attributes" type="string" required="false" default="#variables.defaultattributes#">
		
		<cffile action="write" file="#arguments.file#" output="#arguments.output#" 
			addnewline="#arguments.addnewline#" charset="#arguments.charset#" 
			mode="#arguments.mode#" attributes="#arguments.attributes#">
	</cffunction>
	
	<cffunction name="setWritable" access="public" output="false">
		<cfargument name="file" type="string" required="true">
		<cfargument name="writable" type="boolean" required="false" default="true">
		<cfset CreateObject("java","java.io.File").init(arguments.file).setWritable(arguments.writable,false)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="delete" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true">
		<cfargument name="lockwait" type="numeric" default="#variables.defaulttimeout#">
		
		<cfif fileExists(arguments.file)>
			<cflock name="#arguments.file#" type="exclusive" timeout="#arguments.lockwait#">
				<cfif fileExists(arguments.file)>
					<cfset setWritable(arguments.file)>
					<cffile action="delete" file="#arguments.file#">
				</cfif>
				<cfset fileMan.clearFileCache(getDirectoryFromPath(arguments.file),false)>
			</cflock>
		<cfelseif directoryExists(arguments.file)>
			<cfset delTree(file, lockwait) />
		</cfif>
	</cffunction>
	
	<cffunction name="move" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true">
		<cfargument name="destination" type="string" required="true">
		<cfargument name="charset" type="string" required="false" default="#variables.defaultcharset#">
		<cfargument name="mode" type="numeric" required="false" default="#variables.defaultmode#">
		<cfargument name="attributes" type="string" required="false" default="#variables.defaultattributes#">
		<cfargument name="lockwait" type="numeric" default="#variables.defaulttimeout#">
		
		<cflock name="#getdirectoryfrompath(arguments.file)#" type="exclusive" timeout="#arguments.lockwait#">
			<cflock name="#getdirectoryfrompath(arguments.destination)#" type="exclusive" timeout="#arguments.lockwait#">
				<cflock name="#arguments.destination#" type="exclusive" timeout="#arguments.lockwait#">
					<cflock name="#arguments.file#" type="exclusive" timeout="#arguments.lockwait#">
						<cfset mkdir(arguments.destination)>
						<cffile action="move" source="#arguments.file#" destination="#arguments.destination#"
						charset="#arguments.charset#" mode="#arguments.mode#" attributes="#arguments.attributes#">
						<cfset fileMan.clearFileCache(getDirectoryFromPath(arguments.file),false)>
						<cfset fileMan.clearFileCache(arguments.destination,false)>
						<cfset fileMan.setModified(arguments.destination)>
					</cflock>
				</cflock>
			</cflock>
		</cflock>
	</cffunction>
	
	<cffunction name="copy" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true">
		<cfargument name="destination" type="string" required="true">
		<cfargument name="overwrite" type="boolean" default="#variables.defaultoverwrite#">
		<cfargument name="mode" type="numeric" required="false" default="#variables.defaultmode#">
		<cfargument name="attributes" type="string" required="false" default="#variables.defaultattributes#">
		<cfargument name="lockwait" type="numeric" default="#variables.defaulttimeout#">
		
		<cfif directoryExists(arguments.destination)>
			<!--- if no filename is specified for the destination path, append the existing filename to the path --->
			<cfset arguments.destination = getPath(getFileFromPath(arguments.file),arguments.destination)>
		</cfif>
		
		<cflock name="#getdirectoryfrompath(arguments.destination)#" type="exclusive" timeout="#arguments.lockwait#">
			<cflock name="#arguments.file#" type="exclusive" timeout="#arguments.lockwait#">
				<cflock name="#arguments.destination#" type="exclusive" timeout="#arguments.lockwait#">
					<cfif fileExists(arguments.destination) and not arguments.overwrite>
						<cfthrow type="ontap.file.overwrite" message="onTap: File Overwrite Not Enabled" extendedinfo="#arguments.destination#" 
						detail="The file #arguments.destination# already exists. Use the attribute overwrite=""true"" to allow this file to be overwritten.">
					</cfif>
					
					<cfset arguments.overwrite = fileExists(arguments.destination)>
					<cfset mkdir(getdirectoryfrompath(arguments.destination))>
					<cffile action="copy" mode="#arguments.mode#" attributes="#arguments.attributes#"
						source="#arguments.file#" destination="#arguments.destination#">
					<cfif arguments.overwrite>
						<cfset fileMan.setModified(arguments.destination)>
					<cfelse>
						<cfset fileMan.clearFileCache(getDirectoryFromPath(arguments.destination),false)>
					</cfif>
				</cflock>
			</cflock>
		</cflock>
	</cffunction>
	
	<cffunction name="rename" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true">
		<cfargument name="destination" type="string" required="true">
		<cfargument name="mode" type="numeric" required="false" default="#variables.defaultmode#">
		<cfargument name="attributes" type="string" required="false" default="#variables.defaultattributes#">
		<cfargument name="lockwait" type="numeric" default="#variables.defaulttimeout#">
		
		<cfset destination = getFileFromPath(destination)>
		<cflock name="#getdirectoryfrompath(arguments.file)#" type="exclusive" timeout="#arguments.lockwait#">
			<cflock name="#arguments.file#" type="exclusive" timeout="#arguments.lockwait#">
				<cfif fileExists(arguments.file)>
					<cffile action="rename" source="#arguments.file#" destination="#destination#"
					mode="#arguments.mode#" attributes="#arguments.attributes#">
					<cfset fileMan.clearFileCache(getDirectoryFromPath(arguments.file),false)>
				</cfif>
			</cflock>
		</cflock>
	</cffunction>
	
	<cffunction name="upload" access="public" output="false" returntype="struct">
		<cfargument name="filefield" type="string" required="true">
		<cfargument name="destination" type="string" required="true">
		<cfargument name="nameconflict" type="string" required="false" default="#variables.defaultnameconflict#">
		<cfargument name="accept" type="string" required="false" default="#variables.defaultaccept#">
		<cfargument name="mode" type="numeric" required="false" default="#variables.defaultmode#">
		<cfargument name="attributes" type="string" required="false" default="#variables.defaultattributes#">
		<cfargument name="lockwait" type="numeric" default="#variables.defaulttimeout#">
		
		<cflock name="#getdirectoryfrompath(arguments.destination)#" type="exclusive" timeout="#arguments.lockwait#">
			<cflock name="#arguments.destination#" type="exclusive" timeout="#arguments.lockwait#">
				<cfset mkdir(getdirectoryfrompath(arguments.destination))>
				<cffile action="upload" filefield="#arguments.filefield#" destination="#arguments.destination#" 
				accept="#arguments.accept#" nameconflict="#arguments.nameconflict#"
				mode="#arguments.mode#" attributes="#arguments.attributes#">
				
				<cfif cffile.fileWasOverwritten>
					<cfset fileMan.setModified(getPath(cffile.serverfile,arguments.destination))>
				<cfelse>
					<cfset fileMan.clearFileCache(arguments.destination,false)>
				</cfif>
				
				<cfreturn cffile>
			</cflock>
		</cflock>
	</cffunction>
	
	<cffunction name="download" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true">
		<cfargument name="filename" type="string" required="false" default="#getFileFromPath(arguments.file)#">
		<cfargument name="deletefile" type="string" required="false" default="#variables.defaultdeletefile#">
		<cfargument name="lockwait" type="numeric" default="#variables.defaulttimeout#">
		
		<cflock name="#arguments.file#" type="readonly" timeout="#arguments.lockwait#">
			<cfheader name="Content-Disposition" value="inline; filename=""#arguments.filename#""">
			<cfcontent type="application/x-unknown" file="#arguments.file#" deletefile="false">
		</cflock>
		
		<cfif arguments.deleteFile><cfset delete(arguments.file,arguments.lockwait)></cfif>
	</cffunction>
	
	<cffunction name="properties" access="public" output="false" returntype="any">
		<cfargument name="file" type="string" required="true" />
		<cfargument name="refresh" type="boolean" required="false" default="#variables.defaultrefresh#" />
		<cfreturn fileMan.getProperties(file,refresh) />
	</cffunction>
	
	<cffunction name="deltree" access="public" output="false">
		<cfargument name="path" type="string" required="true">
		<cfargument name="lockwait" type="numeric" required="false" default="#variables.defaulttimeout#">
		<cfset var fso = CreateObject("java","java.io.File")>
		<cfset var rsfile = 0>
		<cfset var file = 0>
		<cfset var i = 0>
		
		<cftry>
			<cfdirectory action="delete" directory="#path#" recurse="true" />
			<cfcatch>
				<!--- the above operation may have failed for several reasons, 
				one of which is the presence of read-only files 
				which the below original code can fix -- the line above is faster - below is more thorough --->
				<cfdirectory name="rsfile" action="list" directory="#path#" filter="*" sort="name" recurse="true">
				<cfquery name="rsfile" dbtype="query">
					select * from rsfile order by type desc, directory desc, name 
				</cfquery>
				
				<cfloop query="rsfile">
					<cfset fso.init(getPath(rsfile.name,rsfile.directory))>
					<cftry>
						<cfif fso.exists()>
							<cfset fso.setWritable(true,false)>
							<cfset fso.delete()>
							<cfset fileMan.clearFileCache(fso.getCanonicalPath(),yesnoformat(rsfile.type is "file"))>
						</cfif>
						<cfcatch></cfcatch>
					</cftry>
				</cfloop>
				
				<cftry>
					<cfset fso.init(arguments.path)>
					<cfset fso.setWritable(true,false)>
					<cfset fso.delete()>
					<cfcatch></cfcatch>
				</cftry>
			</cfcatch>
		</cftry>
		
		<cfset fileMan.clearFileCache(arguments.path,false)>
	</cffunction>
</cfcomponent>