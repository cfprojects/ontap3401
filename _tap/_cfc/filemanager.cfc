<cfcomponent displayname="FileManager" output="false" hint="handles file formats and file-system caching">
	<cfset variables.pathto = structnew()>
	<cfset variables.filecache = CreateObject("component","cacheboxagent").init("tap_filecache","application","IDLE:5") />
	<cfset variables.separator = CreateObject("java", "java.lang.System").getProperty("file.separator") />
	
	<cfinclude template="/cfc/mixin/tap.cfm" />
	
	<cffunction name="init" access="public" output="false">
		<cfset variables.created = getTickCount()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getModified" access="private" output="false" returntype="date">
		<cfargument name="path" type="string" required="true">
		<cfreturn CreateObject("java","java.io.File").init(path).lastModified()>
	</cffunction>
	
	<cffunction name="isChanged" access="public" output="false" returntype="boolean">
		<cfreturn iif(variables.created lt getModified(getCurrentTemplatePath()),true,false)>
	</cffunction>
	
	<cffunction name="getPath" access="private" output="false" returntype="string">
		<cfargument name="file" type="string" required="true">
		<cfargument name="domain" type="string" required="true">
		<cfreturn request.fs.getPath(file,domain)>
	</cffunction>
	
	<cffunction name="getFormat" access="public" output="false">
		<cfargument name="format" type="string" required="true">
		<cfset var result = getCachedFormat(arguments.format)>
		<cfif result.status>
			<cfset result = setFormat(arguments.format,getDefaultFormat(arguments.format)) />
		</cfif>
		<cfreturn result.content>
	</cffunction>
	
	<cffunction name="getFormatPath" access="private" output="false">
		<cfargument name="format" type="string" required="true" />
		<cfreturn ExpandPath("/cfc/file/format/#lcase(trim(arguments.format))#.cfc") />
	</cffunction>
	
	<cffunction name="getCachedFormat" access="private" output="false">
		<cfargument name="format" type="string" required="true">
		<cfreturn filecache.fetch(getFileScope(getFormatPath(format),true,"component")) />
	</cffunction>
	
	<cffunction name="setFormat" access="public" output="false">
		<cfargument name="format" type="string" required="true">
		<cfargument name="component" required="true">
		<cfset var path = getFormatPath(format)>
		<cfif isObject(arguments.component)>
			<cfset component.cachetime = now()>
			<cfreturn setFileCache(path,"component",arguments.component,true)>
		</cfif>
	</cffunction>
	
	<cffunction name="getDefaultFormat" access="private" output="false">
		<cfargument name="format" type="string" required="true">
		<cfreturn CreateObject("component","cfc.fileformat." & arguments.format).init(this)>
	</cffunction>
	
	<cffunction name="mkDir" access="public" output="false">
		<cfargument name="path" type="string" required="true">
		<cfset CreateObject("java","java.io.File").init(JavaCast("string",path)).mkdirs()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="debugCache" access="public" output="true" returntype="void">
		<cfset variables.filecache.debug() />
	</cffunction>
	
	<cffunction name="debugPathTo" access="public" output="true" returntype="void">
		<cfdump var="#variables.pathto#">
	</cffunction>
	
	<cffunction name="getPathTo" access="public" output="false" returntype="string">
		<cfargument name="topath" type="string" required="true">
		<cfargument name="frompath" type="string" required="true">
		
		<cfset var ospd = getTap().getOS().pathdelimiter>
		<cfset var aHere = listchangedelims(frompath,ospd,"\/" & ospd)>
		<cfset var aThere = listchangedelims(topath,ospd,"\/" & ospd)>
		<cfset var rex = replace("[/\#ospd#]","\","\\","ALL")>
		<cfset var rpcache = variables.pathto>
		<cfset var targetfilename = "">
		<cfset var aRel = ArrayNew(1)>
		<cfset var trump = false>
		<cfset var lenThere = 0>
		<cfset var x = 0>
		
		<cfset targetfilename = getfilefrompath(aThere)>
		<cfset aThere = rereplace(getdirectoryfrompath(aThere),"#rex#+",ospd,"ALL")>
			
		<cfif aHere is aThere><cfreturn targetfilename></cfif>
		<cfif not directoryExists(aHere)><cfset aHere = getDirectoryFromPath(aHere)></cfif>
		
		<cfif structkeyexists(rpcache,aThere) and structkeyexists(rpcache[aThere],aHere)>
			<cfreturn getFileCase(listappend(rpcache[aThere][aHere],targetfilename,ospd))>
		</cfif>
		
		<cfset aHere = listtoarray(aHere,ospd)>
		<cfset aThere = ListToArray(aThere,ospd)>
		<cfset lenThere = arraylen(aThere)>
			
		<cfloop index="x" from="1" to="#arraylen(aHere)#">
			<cfif trump OR x GT lenThere OR comparenocase(aHere[x],aThere[x])
			OR (compare(aHere[x],aThere[x]) AND NOT FindNoCase("win",getTap().getOS().name))>
				<cfset ArrayPrepend(aRel,"..")><cfset trump = true>
				<cfif x lte lenThere><cfset ArrayAppend(aRel,aThere[x])></cfif>
			</cfif>
		</cfloop>
		
		<cfloop index="x" from="#x#" to="#arrayLen(aThere)#">
			<cfset ArrayAppend(aRel,aThere[x])>
		</cfloop>
			
		<cfset aHere = arraytolist(aHere,ospd)>
		<cfset aThere = arraytolist(aThere,ospd)>
		<cfset aRel = ArrayToList(aRel,ospd)>
		
		<cflock name="tap.fileMan.pathto.#aThere#" type="exclusive" timeout="1">
			<cfif not structkeyexists(rpcache,aThere)>
				<cfset rpcache[aThere] = structnew()>
			</cfif>
		</cflock>
		
		<cfset rpcache[aThere][aHere] = aRel>
		<cfif len(trim(aRel))>
			<cfset aRel = aRel & ospd & targetfilename>
		<cfelse>
			<cfset aRel = targetfilename>
		</cfif>
		
		<cfreturn rereplace(getFileCase(aRel),"^\#ospd#(.*)$","\1")>
	</cffunction>
	
	<cffunction name="getFileCase" access="public" output="false" returntype="string">
		<cfargument name="path" type="string" required="true">
		<cfreturn getTap().getPath().getFileCase(path) />
	</cffunction>
	
	<cffunction name="getCachePath" access="private" output="false" returntype="string">
		<cfargument name="abspath" type="string" required="true">
		<cfargument name="isFile" type="string" required="false" default="#fileExists(abspath)#">
		
		<cfif arguments.isFile>
			<cfset arguments.cachepath = getCachePath(getDirectoryFromPath(arguments.abspath)) & "./.file." & getFileFromPath(arguments.abspath)>
		<cfelse>
			<cfset arguments.cachepath = ListRest(REReplaceNoCase("-/" & arguments.abspath,"(\\|/)+",".","ALL"),".")>
		</cfif>
		
		<cfreturn arguments.cachepath>
	</cffunction>
	
	<cffunction name="getFileScope" access="private" output="false" returntype="string">
		<cfargument name="abspath" type="string" required="true">
		<cfargument name="isFile" type="string" required="false" default="#fileExists(abspath)#">
		<cfargument name="append" type="string" required="false" default="" />
		<cfset var root = ExpandPath("/tap") />
		
		<cfif fileExists(abspath) or directoryexists(abspath)>
			<cfset abspath = CreateObject("java","java.io.File").init(abspath).getCanonicalPath() />
		</cfif>
		
		<cfif left(abspath,len(root)) is root>
			<cfset abspath = removechars(abspath,1,len(root)) />
		<cfelse>
			<cfreturn "" />
		</cfif>
		
		<cfif not arguments.isFile>
			<cfset abspath = rereplace(abspath,"(\\|/)$","") />
		</cfif>
		
		<cfif len(arguments.append)>
			<cfset abspath = abspath & getCacheConnector(arguments.isFile) & arguments.append />
		</cfif>
		
		<cfreturn abspath />
	</cffunction>
	
	<cffunction name="getCacheConnector" access="private" output="false">
		<cfargument name="isFile" type="boolean" required="true" />
		<cfreturn iif(arguments.isFile,de(":"),"variables.separator & ':'") />
	</cffunction>
	
	<cffunction name="setFileCache" access="public" output="false" returntype="struct">
		<cfargument name="abspath" type="string" required="true">
		<cfargument name="branch" type="string" required="true">
		<cfargument name="content" type="any" required="true">
		<cfargument name="isFile" type="string" required="false" default="#fileExists(abspath)#">
		<cfset var scope = getFileScope(abspath,isFile,branch) />
		<cfif len(scope)>
			<cfreturn filecache.store(scope,content) />
		<cfelse>
			<!--- we're not going to cache it if it's not in the app, 
			-- but we'll pretend we did for the benefit of the calling code --->
			<cfset scope = structNew() />
			<cfset scope.status = 0 />
			<cfset scope.content = arguments.content />
			<cfreturn scope />
		</cfif>
	</cffunction>
	
	<cffunction name="getFileCache" access="public" output="false" returntype="struct">
		<cfargument name="abspath" type="string" required="true">
		<cfargument name="branch" type="string" required="true">
		<cfargument name="isFile" type="string" required="false" default="#fileExists(abspath)#">
		<cfset var scope = getFileScope(abspath,isFile,branch) />
		<cfif len(scope)>
			<cfreturn filecache.fetch(scope) />
		<cfelse>
			<!--- we don't need to attempt to fetch cache if it's not within the application --->
			<cfset scope = structNew() />
			<cfset scope.status = 0 />
			<cfset scope.content = "" />
			<cfreturn scope />
		</cfif>
	</cffunction>
	
	<cffunction name="setModified" access="public" output="false">
		<cfargument name="abspath" type="string" required="true">
		<cfargument name="modified" type="date" required="false" default="#now()#">
		<cfset modified = DateDiff("s","1/1/1970",modified) * 1000>
		<cfset clearFileCache(abspath,true)>
		<cfif FileExists(abspath)>
			<cfset CreateObject("java","java.io.File").init(abspath).setLastModified(modified)>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="clearFileCache" access="public" output="false">
		<cfargument name="abspath" type="string" required="false" default="%">
		<cfargument name="isFile" type="string" required="false" default="#fileExists(abspath)#">
		<cfset var scope = arguments.abspath />
		
		<cfif scope is "%">
			<cfset filecache.expire() />
		<cfelse>
			<cfset scope = getFileScope(scope,arguments.isFile) />
			
			<cfif len(scope)>
				<cfset scope = scope & iif(arguments.isFile,de(":%"),"variables.separator & '%'") />
				<cfset filecache.expire(scope) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="getTemplateList" access="public" output="false" returntype="string">
		<cfargument name="directory" type="string" required="true">
		<cfargument name="filter" type="string" required="false" default="#getTap().contentfilter#">
		<cfargument name="refresh" type="string" required="false" default="#getTap().development#">
		
		<cfset var fso = 0>
		<cfset var templatelist = "">
		<cfset var templatearray = 0>
		<cfset var result = 0 />
		<cfset var x = 0>
		<cfset var cachename = "" />
		
		<cfif not directoryexists(directory)>
			<cfreturn "" />
		</cfif>
		
		<cfset cachename = getFileScope(directory,false,"tl:#hash(filter)#")>
		
		<cfif not arguments.refresh>
			<cfset result = filecache.fetch(cachename) />
			<cfif not result.status>
				<cfreturn result.content />
			</cfif>
		</cfif>
		
		<cfif directoryexists(directory)>
			<!--- use a java object to get a list of templates in the directory -- this is significantly faster than cfdirectory --->
			<cfset templatearray = CreateObject("java","java.io.File").init(JavaCast("string",replace(directory,"\","/","ALL"))).list()>
			
			<cfloop index="x" from="1" to="#arraylen(templatearray)#">
				<!--- preclude file names containing commas (function returns a comma delimited list) 
				or file names containing a ~ character which is used by several popular editors to indicate a temporary file name --->
				<cfif findoneof(",~",templatearray[x]) eq 0 and 
					refindnocase(filter,templatearray[x],1,false) neq 0>
						<cfset templatelist = listappend(templatelist,templatearray[x])>
				</cfif>
			</cfloop>
			
			<!--- java.io.File.list() does not return a sorted array --->
			<cfset templatelist = listsort(templatelist,"textnocase","asc")>
			
			<!--- store this template list in cache --->
			<cfset filecache.store(cachename,templatelist) />
		</cfif>
		
		<cfreturn templatelist>
	</cffunction>
	
	<cffunction name="compress" access="public" output="false" returntype="string">
		<cfargument name="directory" type="string" required="true">
		<cfargument name="filter" type="string" required="false" default="#getTap().contentfilter#">
		<cfargument name="templatepath" type="string" required="false" default="#directory#/~ontap.cfm">
		<cfset var fso = CreateObject("java","java.io.File").init(replace(templatepath,"\","/","ALL"))>
		<cfset var tap = getTap() />
		<cfset var newline = tap.newline() />
		<cfset var fin = 0>
		<cfset var fout = 0>
		<cfset var fis = 0>
		<cfset var isr = 0>
		<cfset var br = 0>
		<cfset var x = 0>
		<cfset var ctemplate = "">
		<cfset var templatelist = "">
		<cfset var thread = 0>
		<cfset var cache = 0>
		<cfset var scope = getFileScope(directory,false,"compressed") />
		<cfset var lockname = "tap.fileMan.compress:#scope#">
		
		<cfif not directoryexists(directory) or not directoryexists(getdirectoryfrompath(templatepath))><cfreturn false></cfif>
		
		<!--- delete the file if in development or not using compression --->
		<cflock name="#lockname#" type="exclusive" timeout="5">
			<cfif tap.development or not tap.compress>
				<cfif fso.exists()>
					<cfset fso.delete()>
					<cfset clearFileCache(templatepath,true)>
				</cfif>
				<cfreturn false>
			</cfif>
		</cflock>
			
		<cflock name="#lockname#" type="exclusive" timeout="10">
			<!--- compression enabled and in production mode -- ensure the file exists and return true --->
			<cfset cache = filecache.fetch(scope) />
			<cfif cache.status>
				<cfset filecache.store(scope,false) />
			<cfelse>
				<!--- return false if another request is currently compressing this directory 
				-- this allows the current request to include the individual templates and 
				potentially compress the next directory in the sequence for the current process --->
				<cfreturn cache.content>
			</cfif>
		</cflock>
		
		<!--- if the file is read only, the fout object won't instantiate --->
		<cfif fso.exists()><cfset fso.delete()></cfif>
		
		<!--- create an outputstream object to write data to the file --->
		<cfset fout = CreateObject("java","java.io.FileWriter")>
		<cfset fout.init(JavaCast("string",templatepath),JavaCast("boolean",true))>
		
		<!--- prepopulate the file with a comment for the benefit of developers --->
		<cfset fout.write(JavaCast("string","<!--- onTap framework compressed template -- do not edit this file --->" & repeatstring(newline,2)))>
		
		<!--- create java classes for the directory and inputstream to read files in the directory --->
		<cfset fso = CreateObject("java","java.io.File").init(JavaCast("string",directory))>
		
		<!--- these 3 classes are required to get string data out of the file -- don't ask, I didn't do it --->
		<cfset fis = CreateObject("java","java.io.FileInputStream")>
		<cfset isr = CreateObject("java","java.io.InputStreamReader")>
		<cfset br = CreateObject("java","java.io.BufferedReader")>
				
		<!--- get an alphabetical list of templates in the directory --->
		<cfset templatelist = listsort(arraytolist(fso.list()),"textnocase","asc")>
		<cfloop index="x" from="1" to="#listlen(templateList)#">
			<cfset ctemplate = listgetat(templatelist,x)>
			<!--- include the current template if it matches the regular expression filter --->
			<cfif not find("~",ctemplate) and refindnocase(filter,ctemplate,1,false)>
				<cfset fis.init(JavaCast("string",directory & "/" & ctemplate))>
				<cfset isr.init(fis)><cfset br.init(isr)>
				
				<!--- loop over the source template and concatenate it to the target template one line at a time 
				-- couldn't find a java class/method to handle the whole file at once --->
				<cfloop condition="br.ready()">
					<cfset fout.write(br.readLine() & newline)>
				</cfloop>
			</cfif>
		</cfloop>
		<cfset fout.close()>
		
		<!--- set the compressed template to read only to prevent overwriting of changed code --->
		<cfset createObject("java","java.io.File").init(JavaCast("string",templatepath)).setReadOnly()>
		
		<cflock name="#lockname#" type="exclusive" timeout="5">
			<cfset filecache.store(scope,true) />
		</cflock>
		
		<!--- now that the template is completely generated indicate that it is ready for inclusion --->
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getProperties" access="public" output="false" returntype="any">
		<cfargument name="abspath" type="string" required="true">
		<cfargument name="refresh" type="boolean" required="false" default="#getTap().development#">
		<cfset var my = structnew() />
		<cfset my.scope = getFileScope(abspath,true,"properties") />
		
		<cfif not refresh and len(my.scope)>
			<cfset my.result = filecache.fetch(my.scope) />
			<cfif not my.result>
				<cfreturn duplicate(my.content) />
			</cfif>
		</cfif>
		
		<cfdirectory action="LIST" name="arguments.output" 
			filter="#getfilefrompath(arguments.file)#" 
			directory="#getdirectoryfrompath(arguments.file)#" />
		
		<cfif len(my.scope)>
			<cfset filecache.store(my.scope,arguments.output) />
		</cfif>
		
		<cfreturn duplicate(arguments.output) />
	</cffunction>
</cfcomponent>
