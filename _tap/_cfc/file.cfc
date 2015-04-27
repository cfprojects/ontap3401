<cfcomponent output="false" displayname="File" extends="ontap" hint="provides enhanced file-management tools">
	<cfproperty name="file" type="string" hint="a relative path to the file represented by this object">
	<cfproperty name="domain" type="string" hint="an absolute file path or path alias from which the file property is relative">
	<cfproperty name="filePath" type="string" hint="the full path to the loaded file -- this property is read-only">
	<cfproperty name="type" type="string" default="text" hint="determines the method used to read and write a loaded file">
	<cfproperty name="cacheFileInfo" type="boolean" default="true" hint="indicates if the framework's file-caching features should be applied to the loaded file">
	<cfproperty name="attributes" type="string" default="Normal" hint="determines what file-system attributes (if any) should be applied to a written file">
	<cfproperty name="mode" type="string" default="775" hint="indicates the unix mode in which files are written when using a unix file-system">
	<cfproperty name="charset" type="string" default="##getTap().getPage().charset##" hint="indicates the character set used to write files">
	<cfproperty name="addNewLine" type="boolean" default="false" hint="indicates if new lines are added when file append opterations are performed against text files">
	<cfproperty name="caseSensitive" type="boolean" default="false" hint="determines if xml type files are case-sensitive when read">
	<cfproperty name="nameConflict" type="string" default="overwrite" hint="error|overwrite|skip|makeunique - determines how name conflicts are handled during uploads">
	
	<cfset variables.fso = createObject("java","java.io.File")>
	<cfset setProperty("domain","T")>
	<cfset setProperty("type","text")>
	<cfset setProperty("casesensitive",false)>
	<cfset setProperty("cacheFileInfo",true)>
	<cfset setProperty("attributes","Normal")>
	<cfset setProperty("mode","775")>
	<cfset setProperty("charset",getDefaultCharset())>
	<cfset setProperty("addnewline",false)>
	<cfset setProperty("nameconflict","overwrite")>
	
	<cffunction name="init" access="public" output="false" 
	hint="sets the path information for an individual file or directory">
		<cfargument name="file" type="string" required="false" default="">
		<cfargument name="domain" type="string" required="false" default="#this.getValue('domain')#" 
			hint="an absolute file path or path alias from which the file attribute is relative - defaults to the framework root directory">
		<cfargument name="type" type="string" required="false" default="#this.getValue('type')#"
			hint="indicates the type of content stored in the specified file - defaults to text">
		<cfargument name="cacheFileInfo" type="boolean" required="false" default="#this.getValue('cacheFileInfo')#"
			hint="indicates if the framework's file-caching features should be enabled for the loaded file object">
		
		<cfset setProperties(arguments)>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getFormat" access="private" output="false">
		<cfargument name="format" type="string" required="false" default="">
		<cfif not len(arguments.format)>
			<cfreturn variables.format>
		<cfelse>
			<cfreturn getFileManager().getFormat(arguments.format)>
		</cfif>
	</cffunction>
	
	<cffunction name="setFormat" access="private" output="false">
		<cfargument name="format" required="true">
		<cfif isSimpleValue(arguments.format)>
			<cfset arguments.format = getFormat(arguments.format)>
		</cfif>
		<cfset variables.format = arguments.format>
	</cffunction>
	
	<cffunction name="set_type" access="private" output="false">
		<cfargument name="propertyname" type="string" required="true">
		<cfargument name="propertyvalue" type="string" required="true">
		<cfset setFormat(arguments.propertyvalue)>
		<cfset setProperty(propertyname,propertyvalue)>
	</cffunction>
	
	<cffunction name="getPath" access="private" output="false" returntype="string">
		<cfargument name="file" type="string" required="true" default="#getProperty('file')#">
		<cfargument name="domain" type="string" required="true" default="#getProperty('domain')#">
		<cfreturn getFS().getPath(file,domain)>
	</cffunction>
	
	<cffunction name="getDefaultCharset" access="private" output="false" returntype="string">
		<cfreturn getTap().getPage().charset>
	</cffunction>
	
	<cffunction name="setFilePath" access="private" output="false" returntype="void"
	hint="used internally to update the filepath property when the file or domain properties are modified">
		<cfset var my = structnew()>
		<cfset my.file = this.getValue("file")>
		<cfset my.domain = this.getValue("domain")>
		
		<cfif len(trim(my.domain))>
			<cfset my.filepath = getPath(my.file, my.domain)>
			<cfset setProperty("filepath", my.filepath)>
			<cfset variables.fso.init(replace(my.filepath, "\", "/", "ALL"))>
		<cfelse>
			<cfset my.filepath = "">
			<cfset setProperty("filepath","")>
			<cfset variables.fso.init("")>
		</cfif>
	</cffunction>
	
	<cffunction name="set_filepath" output="false" returntype="void" access="private">
		<!--- the filepath property is read-only --->
	</cffunction>
	
	<cffunction name="expand" access="private" output="false" returntype="string">
		<cfargument name="path" type="string" required="true" />
		<cfif left(path,1) is "%">
			<cfset path = getTap().getPath().getAlias(removechars(listfirst(path,"\/"),1,1)) & "/" & listrest(path,"\/") />
		</cfif>
		<cfreturn path />
	</cffunction>
	
	<cffunction name="set_file" output="false" access="private" returntype="void">
		<cfset var tmp = expand(trim(arguments.propertyValue)) />
		<cfset var mydir = getDirectoryFromPath(tmp) />
		
		<cfif directoryExists(tmp)>
			<cfset setProperty("domain", tmp) />
			<cfset setProperty("file", "") />
		<cfelseif FileExists(tmp) or DirectoryExists(mydir)>
			<cfset setProperty("domain", mydir) />
			<cfset setProperty("file", getFileFromPath(tmp)) />
		<cfelse>
			<cfset setProperty("file",arguments.propertyValue) />
		</cfif>
		
		<cfset setFilePath() />
	</cffunction>
	
	<cffunction name="set_domain" output="false" access="private" returntype="void">
		<cfset setProperty("domain",arguments.propertyValue)>
		<cfset setFilePath()>
	</cffunction>
	
	<cffunction name="set_readonly" output="false" access="private" returntype="boolean">
		<cfargument name="propertyname" type="string" required="true">
		<cfargument name="propertyvalue" type="string" required="true">
		
		<cftry>
			<cfif arguments.propertyvalue is true>
				<cfset variables.fso.setWritable(false,false)>
				<cfreturn true>
			<cfelse>
				<cfset variables.fso.setWritable(true,false)>
				<cfreturn true>
			</cfif>
			
			<cfcatch>
				<cfreturn false>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="get_modified" output="false" access="private" returntype="date" 
	hint="returns a UTC adjusted date indicating the absolute time at which the file was last modified">
		<cfreturn getUTCTime(createObject("java","java.util.Date").init(variables.fso.lastModified()))>
	</cffunction>
	
	<cffunction name="get_size" output="false" access="private" returntype="numeric">
		<cfset var rs = "">
		<cfif this.isFile()>
			<cfreturn CreateObject("java","java.io.File").init(getValue("filepath")).length()>
		<cfelseif this.isDirectory()>
			<cfdirectory action="list" name="rs" directory="#getValue('filepath')#" recurse="true">
			<cfreturn ArraySum(rs["size"])>
		<cfelse><cfreturn 0></cfif>
	</cffunction>
	
	<cffunction name="get_hidden" output="false" access="private" returntype="boolean">
		<cfreturn variables.fso.isHidden()>
	</cffunction>

	<cffunction name="get_readable" output="false" access="private" returntype="boolean">
		<cfreturn variables.fso.canRead()>
	</cffunction>

	<cffunction name="get_writeable" output="false" access="private" returntype="boolean">
		<cfreturn variables.fso.canWrite()>
	</cffunction>

	<cffunction name="get_length" output="false" access="private" returntype="numeric">
		<cfreturn variables.fso.length()>
	</cffunction>
	
	<cffunction name="get_availableRoots" output="false" access="private" returntype="array">
		<cfset var filearray = variables.fso.listRoots()><cfset var x = 0>
		<cfloop index="x" from="1" to="#arraylen(filearray)#">
		<cfset filearray[x] = filearray[x].getAbsolutePath()></cfloop>
		<cfreturn filearray>
	</cffunction>
	
	<cffunction name="get_directory" output="false" access="private" returntype="string">
		<cfreturn variables.fso.getParentFile().getAbsolutePath() />
	</cffunction>
	
	<cffunction name="get_parent" output="false" access="private">
		<cfreturn getFileObject("",this.getValue("directory")) />
	</cffunction>
	
	<cffunction name="get_isFile" access="private" output="false" returntype="boolean"
	hint="indicates if the loaded file path is a file which exists">
		<cfreturn FileExists(this.getValue("filepath")) />
	</cffunction>
	
	<cffunction name="get_isDirectory" access="private" output="false" returntype="boolean"
	hint="indicates if the loaded file path is a directory which exists">
		<cfreturn DirectoryExists(this.getValue("filepath"))>
	</cffunction>
	
	<cffunction name="get_exists" access="public" output="false" returntype="boolean"
	hint="indicates if the loaded file path is a directory which exists">
		<cfreturn yesnoformat(this.isFile() or this.isDirectory())>
	</cffunction>
	
	<cffunction name="isFile" access="public" output="false" returntype="boolean"
	hint="indicates if the loaded file path is a file which exists">
		<cfreturn this.getValue("isFile")>
	</cffunction>
	
	<cffunction name="isDirectory" access="public" output="false" returntype="boolean"
	hint="indicates if the loaded file path is a directory which exists">
		<cfreturn this.getValue("isDirectory")>
	</cffunction>
	
	<cffunction name="exists" access="public" output="false" returntype="boolean"
	hint="indicates if the loaded file path is a directory which exists">
		<cfreturn this.getValue("exists")>
	</cffunction>
	
	<cffunction name="mkdir" access="public" output="false" 
	hint="creates the loaded file path as a directory with any necessary parent directories">
		<cfif not this.isDirectory()>
			<cfset CreateObject("java","java.io.File").init(this.getValue("filepath")).mkdirs()>
		</cfif>
		<cfreturn this>
	</cffunction>	
	
	<cffunction name="read" returntype="any" access="public" output="false" 
	hint="reads and returns formatted data from the initialized file">
		<cfargument name="refresh" type="boolean" required="false" default="#getDefaultRefresh()#">
		<cfset var fileContent = "">
		
		<cfinvoke component="#getFormat()#" method="read" 
								file="#getValue('filepath')#" 
								refresh="#arguments.refresh#" 
								cache="#getValue('cachefileinfo')#" 
								charset="#getValue('charset')#"
								returnvariable="fileContent" />
		<cfreturn fileContent />
	</cffunction>
	
	<cffunction name="dir" output="false" access="public" returntype="query" 
	hint="returns a query containing information about files and directories in the loaded file path">
		<cfargument name="filter" type="string" required="false" default="*">
		<cfargument name="sort" type="string" required="false" default="name">
		<cfargument name="recurse" type="boolean" required="false" default="false">
		<cfargument name="UTC" type="boolean" required="false" default="false" hint="indicates if the file modification dates should be converted to UTC">
		<cfargument name="timezone" type="string" required="false" default="" hint="indicates the timezone from which file dates should be converted">
		<cfset var rsfile = 0>
		
		<cfdirectory name="rsfile" action="list" 
				directory="#getValue('filepath')#" recurse="#arguments.recurse#" 
				filter="#arguments.filter#" sort="#arguments.sort#">
		
		<cfif arguments.utc>
			<cfloop query="rsfile">
				<cfset rsfile.datelastmodified[currentrow] = getUTCTime(rsfile.datelastmodified[currentrow],arguments.timezone)>
			</cfloop>
		</cfif>
		
		<cfreturn rsfile>
	</cffunction>
	
	<cffunction name="map" returntype="query" access="public" output="false" 
	hint="returns a query containing a map of all files and directories within the loaded file path">
		<cfargument name="UTC" type="boolean" required="false" default="false" hint="indicates if the file modification dates should be converted to UTC">
		<cfargument name="timezone" type="string" required="false" default="" hint="indicates the timezone from which file dates should be converted">
		<cfset var rsfile = dir(filter="*",sort="name",recurse=true,utc=arguments.utc,timezone=arguments.timezone)>
		<cfset var remove = incrementvalue(len(getValue("filepath")))>
		<cfset var path = ArrayNew(1)>
		
		<cfloop query="rsfile">
			<cfset ArrayAppend(path,removechars(rsfile.directory[currentrow],1,remove))>
		</cfloop>
		
		<cfset QueryAddColumn(rsfile,"path",path)>
		
		<cfreturn rsfile>
	</cffunction>
	
	<cffunction name="info" output="false" access="public" returntype="struct" 
	hint="returns a structure containing information about the loaded file path">		
		<cfset var my = StructNew()>
		<cfset my.info = structnew()>
		<cfset my.info.filepath = this.getValue("filepath")>
		<cfset my.info.directory = this.getValue("directory")>
		<cfset my.info.datelastmodified = this.getValue("modified")>
		<cfset my.info.exists = this.exists()>
		<cfset my.info.isFile = this.isFile()>
		<cfset my.info.isDirectory = this.isDirectory()>
		
		<cfreturn my.info>
	</cffunction>
	
	<cffunction name="getDefaultRefresh" access="private" output="false" returntype="boolean">
		<cfreturn iif(getTap().development or not getValue("cacheFileInfo"),true,false)>
	</cffunction>
	
	<cffunction name="write" access="public" output="false" 
	hint="reads and returns formatted data from the initialized file">
		<cfargument name="output" type="any" required="true">
		<cfargument name="overwrite" type="boolean" required="false" default="true">
		
		<cfinvoke component="#getFormat()#" method="write" 
								file="#getValue('filepath')#" 
								relativefrom="#getValue('domain')#" 
								output="#arguments.output#" 
								overwrite="#arguments.overwrite#" 
								charset="#getValue('charset')#" 
								mode="#getValue('mode')#" 
								attributes="#getValue('attributes')#">
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="append" access="public" output="false" 
	hint="appends content to the loaded file path">
		<cfargument name="output" type="any" required="true">
		<cfargument name="addnewline" type="string" required="false" default="false">
		
		<cfinvoke component="#getFormat()#" method="write" 
								file="#getValue('filepath')#" 
								output="#arguments.output#" 
								addnewline="#arguments.addnewline#" 
								overwrite="false">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="copy" access="public" output="false" 
	hint="coppies the file or directory from the loaded file path">
		<cfargument name="file" type="string" required="true" hint="indicates the destination file path">
		<cfargument name="domain" type="string" required="false" default="#this.getValue('domain')#" hint="location from which the file argument is relative">
		<cfargument name="overwrite" type="boolean" required="false" default="true">
		<cfargument name="map" type="query" required="false" default="#QueryNew('')#">
		<cfset var format = getFormat()>
		<cfset var arg = structNew()>
		<cfset var s = getValue("filepath")>
		<cfset var d = getPath(arguments.file,arguments.domain)>
		<cfset arg.overwrite = arguments.overwrite>
		<cfset arg.mode = getValue("mode")>
		<cfset arg.attributes = getValue("attributes")>
		
		<cfif this.isFile()>
			<cfset arg.file = s><cfset arg.destination = d>
			<cfinvoke component="#format#" method="copy" argumentcollection="#arg#">
		<cfelseif this.isDirectory()>
			<cfif not map.recordcount><cfset map = this.map()></cfif>
			<cfloop query="map">
				<cfset arg.file = getPath("#map.path#/#map.name#",s)>
				<cfset arg.destination = getPath("#map.path#/#map.name#",d)>
				<cfif map.type is "file">
					<cfinvoke component="#format#" method="copy" argumentcollection="#arg#">
				<cfelse>
					<cfset format.mkdir(arg.destination)>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn CreateObject("component","cfc.file").setProperties(getProperties()).init(arguments.file,arguments.domain)>
	</cffunction>
	
	<cffunction name="move" access="public" output="false" 
	hint="moves the file or directory from the loaded file path to another location and resets the object file path - source and destination paths are relative from the same domain">
		<cfargument name="file" type="string" required="true" hint="the destination of the moved file">
		<cfargument name="domain" type="string" required="false" default="#this.getValue('domain')#" hint="path from which the file argument is relative">
		<cfargument name="map" type="query" required="false" default="#QueryNew('')#" hint="indicates specific files within a subdirectory to move - see the map method to generate a file list - defaults to all files in a directory">
		<cfset var format = getFormat()>
		<cfset var arg = structNew()>
		<cfset var s = getValue("filepath")>
		<cfset var d = getPath(arguments.file,arguments.domain)>
		<cfset arg.file = s>
		<cfset arg.destination = d>
		<cfset arg.charset = getValue("charset")>
		<cfset arg.mode = getValue("mode")>
		<cfset arg.attributes = getValue("attributes")>
		
		<cfif this.exists()>
			<cfif this.isFile()>
				<cfinvoke component="#format#" method="move" argumentcollection="#arg#"> 
			<cfelseif this.isDirectory()>
				<cfif not map.recordcount><cfset map = this.map()></cfif>
				<cfloop query="map">
					<cfset arg.file = getPath("#map.path#/#map.name#",s)>
					<cfset arg.destination = getPath("#map.path#/#map.name#",d)>
					<cfif map.type is "file">
						<cfset arg.destination = getDirectoryFromPath(arg.destination)>
						<cfinvoke component="#format#" method="move" argumentcollection="#arg#">
					<cfelse>
						<cfset format.mkdir(arg.destination)>
					</cfif>
				</cfloop>
				<!--- if no files remain in the source directory, delete the directory --->
				<cfdirectory name="map" directory="#s#" action="list" filter="*" recurse="true">
				<cfif not listfindnocase(valuelist(map.type),"file")><cfset this.delete()></cfif>
			</cfif>
			<!--- relocate the file object to the destination path --->
			<cfset this.setValue("file","")>
			<cfset this.setValue("domain",d)>
		</cfif>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="rename" access="public" output="false">
		<cfargument name="name" type="string" required="true">
		<cfset var currentFile = getValue("filepath")>
		<cfset var parent = CreateObject("java","java.io.File").init(currentFile).getParentFile().getCanonicalPath()>
		<cfset var relative = removechars(parent,1,len(getPath("",getValue("domain"))))>
		<cfset var renamed = false>
		<cfset currentFile = removechars(currentFile,1,len(parent))>
		
		<cfif rereplace(arguments.name,"^[\/]","") is not rereplace(currentFile,"^[\/]","")>
			<cfif this.isFile()>
				<cfset getFormat().rename(file=getValue("filepath"),destination=name)>
				<cfset renamed = true>
			<cfelseif this.isDirectory()>
				<cfdirectory action="rename" directory="#getValue('filepath')#" newdirectory="#name#">
				<cfset getFileManager().clearFileCache(parent,false)>
				<cfset setValue("file",relative & "/" & name)>
				<cfset renamed = true>
			</cfif>
		</cfif>
		
		<cfif renamed><cfset setValue("file",relative & "/" & name)></cfif>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="delete" access="public" output="false" 
	hint="deletes the file or directory from the loaded file path">
		<cfif this.isFile()>
			<cfset getFormat().delete(getValue("filepath"))>
		<cfelseif this.isDirectory()>
			<cfset getFormat().deltree(getValue("filepath"))>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getUTCTime" access="private" output="false">
		<cfargument name="time" type="date" required="true">
		<cfargument name="timezone" type="string" required="false" default="#getTap().time.zone#">
		<cfreturn getLib().lsTimeToUTC(arguments.time,arguments.timezone)>
	</cffunction>
	
	<cffunction name="archive" returntype="file" access="public" output="false" 
	hint="compresses the loaded file path into a zip-formatted archive and returns a file object loaded with the compressed file path">
		<cfargument name="zipfile" type="string" required="false" default="#REReplace(getValue('file'),'\.[^.]+$','')#.zip" 
			hint="indicates the path to the zip file to create - files to be archived are located at the instantiated path">
		<cfargument name="domain" type="string" required="false" default="#getValue('domain')#" 
			hint="an absolute path or path alias from which the zipfile argument is relative">
		
		<cfset getFormat("zip").write(
			output=this.getValue("filepath"),
			file=getPath(zipfile,domain),
			relativeFrom=getValue("domain"))>
		
		<cfreturn getFileObject(zipfile,domain,"zip")>
	</cffunction>
	
	<cffunction name="extract" returntype="file" access="public" output="false" 
	hint="extracts a loaded zip-format archive or any contained file to a specified path">
		<cfargument name="destination" type="string" required="false" default="" hint="indicates the path to receive extracted files relative from the file object's domain property">
		<cfargument name="selectedFile" type="string" required="false" default="" hint="allows an individual file to be selected for extraction by name or index">
		<cfargument name="domain" type="string" required="false" default="#getValue('domain')#" hint="a path or path alias from which the destination argument is relative">
		
		<cfset getFormat().extract(
			file=this.getValue('filepath'),
			destination=getPath(destination,domain),
			selectedFile=selectedFile)>
		
		<cfreturn getFileObject(destination,domain)>
	</cffunction>
	
	<cffunction name="getFileObject" access="private" output="false">
		<cfargument name="destination" type="string" required="true" />
		<cfargument name="domain" type="string" required="false" default="T" />
		<cfargument name="type" type="string" required="false" default="#getProperty('type')#" />
		<cfreturn CreateObject("component","cfc.file").init(destination,domain,type) />
	</cffunction>
	
	<cffunction name="clearCache" access="public" output="false" 
	hint="clears the cache for the loaded file and its containing directory">
		<cfset var path = getValue("filepath")>
		
		<cfif fileExists(path) or not directoryExists(path)>
			<cfset getFileManager().clearFileCache(filepath,true)>
		</cfif>
		
		<cfif directoryExists(path) or not FileExists(path)>
			<cfset getFileManager().clearFileCache(filepath,false)>
		</cfif>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getFileManager" access="private" output="false">
		<cfif not structKeyExists(variables,"filemanager")>
			<cfset variables.filemanager = getIoC().getBean("filemanager") />
		</cfif>
		<cfreturn variables.filemanager />
	</cffunction>
	
	<cffunction name="download" output="false" access="public" hint="delivers a file to the client browser">
		<cfargument name="deletefile" type="boolean" required="false" default="false" hint="indicates if the delivered file should be deleted after it is delivered">
		<cfargument name="file" type="string" required="false" default="#this.getValue('file')#" hint="a file to deliver, relative from the file object's domain property">
		<cfargument name="filename" type="string" required="false" default="#getFileFromPath(arguments.file)#" hint="tells the browser what to name the file">
		
		<cfreturn getFormat().download(file=getPath(file,getProperty('domain')),deletefile=arguments.deletefile,filename=arguments.filename)>
	</cffunction>
	
	<cffunction name="upload" output="false" access="public" returntype="struct" hint="receives a file from the client browser">
		<cfargument name="filefield" type="string" required="true" hint="a form field containing the file to upload">
		<cfargument name="nameconflict" type="string" required="false" default="#this.getValue('nameconflict')#" hint="error|overwrite|skip|makeunique - applies to nameconflict attribute of cffile tag">
		<cfargument name="accept" type="string" required="false" default="#this.getValue('accept')#" hint="mime type of acceptable files">
		<cfset var f = "">
		
		<cfinvoke component="#getFormat()#" method="upload"
					filefield="#arguments.filefield#" 
					destination="#getValue('filepath')#" 
					nameconflict="#arguments.nameconflict#" 
					accept="#arguments.accept#" 
					attributes="#this.getValue('attributes')#" 
					mode="#this.getValue('mode')#"
					returnvariable="f">
		<cfif f.fileWasSaved>
			<cfset this.setValue("file",getDirectoryFromPath(this.getValue("file")) & "/" & f.serverfile)>
		</cfif>
		
		<cfreturn f>
	</cffunction>
	
	<cffunction name="formUpload" output="false" access="public" returntype="struct" hint="uploads all file fields in an html form">
		<cfargument name="myform" type="struct" required="true" hint="an html form element">
		<cfargument name="nameconflict" type="string" required="false" default="#this.getValue('nameconflict')#" hint="error|overwrite|skip|makeunique - applies to nameconflict attribute of cffile tag">
		<cfargument name="accept" type="string" required="false" default="#this.getValue('accept')#" hint="mime type of acceptable files">
		
		<cfreturn getLib().html.formUpload(arguments.myform,this.getValue("file"),this.getValue("domain"),
			arguments.nameconflict,arguments.accept,this.getValue("attributes"),this.getValue("mode"))>
	</cffunction>
	
	<cffunction name="setProperties" output="false" access="public" 
	hint="sets all properties for a cfc simultaneously using the setValue method to preserve custom setValue functions and observer functionality">
		<cfargument name="properties" required="true" hint="a structure or query containing keys which match the keys of the property structure">
		<cfargument name="overwrite" type="boolean" required="false" default="true" hint="when false the component's existing properties will be preserved">
		<cfargument name="index" type="numeric" required="false" default="1" hint="if the properties argument is a query the index argument can be used to determine what row of the query is used to populate the object">
		<cfset var x = "">
		
		<!--- if properties are set including the file value, 
		file needs to be set last, in case the file is an absolute path to an existing file --->
		<cfscript>
			if (isStruct(properties)) { 
				var hasFile = structKeyExists(properties, "file"); 
				if (hasFile) { local.file = trim(properties.file); } 
				
				super.setProperties(properties); 
				
				if (hasFile) { setValue("file", local.file); } 
			} else { super.setProperties(argumentCollection = arguments); } 
		</cfscript>
		
		<cfreturn this>
	</cffunction>	
</cfcomponent>