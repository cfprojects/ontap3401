<cfcomponent output="false" displayname="FTP" extends="ontap" 
hint="provides a wrapper for the cfftp tag enhanced with framework file tools">
	<cfproperty name="server" type="string" hint="url to the ftp server">
	<cfproperty name="usr" type="string" default="" hint="the usr used to connect to the ftp server">
	<cfproperty name="pwd" type="string" default="" hint="the pwd used to connect to the ftp server">
	<cfproperty name="wait" type="numeric" default="30" hint="time in seconds to wait for the ftp server response">
	<cfproperty name="port" type="string" default="21" hint="the port on which the ftp server listens for requests">
	<cfproperty name="proxyServer" type="string" hint="the name of a proxy server to use if applicable">
	<cfproperty name="connection" type="string" hint="a variable name to store the ftp connection - defaults to a random string">
	<cfproperty name="retryCount" type="numeric" default="1" hint="number of retries for each operation before a failure is reported">
	<cfproperty name="stopOnError" type="boolean" default="false" hint="indicates if ColdFusion exceptions should be thrown from failed ftp operations">
	<cfproperty name="passive" type="boolean" default="false" hint="indicates if passive-mode ftp should be used">
	<cfproperty name="transferMode" type="string" default="Atuo" hint="indicates the default ftp transfer mode">
	<cfproperty name="ASCIIExtensions" type="string" default="txt; htm; html; cfm; cfml; shtm; shtml; css; asp; asa; xml; xhtml; js;" 
		hint="indicates the file extensions which will force ASCII-mode transfers when transferMode is auto">
	<cfproperty name="skip" type="struct" hint="allows specific files or file-masks to be skipped using regular expressions">
	<cfproperty name="failIfExists" type="boolean" default="false" hint="when true getfile operations fail if a local file exists matching the destination file path">
	<cfproperty name="local" type="string" default="T" hint="an absolute file path or path alias which corresponds with the remote property">
	<cfproperty name="remote" type="string" default="/" hint="a relative file path from the ftp root directory which corresponds with the local property">
	<cfproperty name="timezone" type="string" default="" hint="indicates the java timezone id in which the ftp server is located">
	<cfproperty name="tolerance" type="numeric" default="180" hint="indicates how much time (seconds) must elapse between the modified date on the ftp server and the local server before a file is queued for synchronization">
	
	<cfset variables.isOpen = false>
	<cfset setProperty("stopOnError",false)>
	<cfset setProperty("passive",false)>
	<cfset setProperty("timeout",30)>
	<cfset setProperty("port",21)>
	<cfset setProperty("retryCount",1)>
	<cfset setProperty("connection",getLib().uname("ftp_",35,true))>
	<cfset setProperty("transferMode","auto")>
	<cfset setProperty("ASCIIExtensions","txt;htm;html;cfm;cfml;shtm;shtml;css;asp;asa;xml;xhtml;js;")>
	<cfset setProperty("failIfExists",false)>
	<cfset setProperty("skip",structnew())>
	<cfset setProperty("tolerance",180)>
	<cfset variables.fileObject = CreateObject("component","cfc.file")>
	<cfset setProperty("local","T")>
	<cfset setProperty("remote","/")>
	<cfset variables.fileObject.setValue("domain","T")>
	<cfset variables.fileQueue = arraynew(1)>
	
	<cffunction name="init" access="public" output="false" 
	hint="sets the path information for an individual file or directory">
		<cfargument name="server" type="string" required="true" hint="url to the ftp server">
		<cfargument name="usr" type="string" required="false" default="" hint="the username used to connect to the ftp server">
		<cfargument name="pwd" type="string" required="false" default="" hint="the password used to connect to the ftp server">
		<cfargument name="wait" type="numeric" required="false" default="#this.getValue('timeout')#" hint="time in seconds to wait for the ftp server response">
		<cfargument name="port" type="string" required="false" default="#this.getValue('port')#" hint="the port on which the ftp server listens for requests">
		<cfargument name="proxyServer" type="string" required="false" default="#this.getValue('proxyServer')#" hint="the name of a proxy server to use if applicable">
		
		<cfset setProperties(arguments)>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="addASCIIExtension" access="public" output="false" hint="adds a single extension to the ascii file extension list">
		<cfargument name="extension" type="string" required="true">
		<cfset var extensionList = this.getValue("ASCIIExtensions")>
		<cfif not listFindNoCase(extensionList,extension,";")>
		<cfreturn this.setValue("ASCIIExtensions",ListAppend(extensionList,extension,";"))></cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="removeASCIIExtension" access="public" output="false" hint="removes a single extension from the ascii file extension list">
		<cfargument name="extension" type="string" required="true">
		<cfset var extensionList = this.getValue("ASCIIExtensions")>
		<cfset var idx = listFindNoCase(extensionList,extension,";")>
		<cfif idx><cfreturn this.setValue("ASCIIExtensions",ListDeleteAt(extensionList,idx,";"))></cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="skipFileMask" access="public" output="false"
	hint="adds or removes a file mask from the list of files to skip during transfers">
		<cfargument name="mask" type="string" required="true" hint="the file mask to apply">
		<cfargument name="skip" type="boolean" required="false" default="true" hint="indicates if the mask should be added or removed">
		<cfargument name="REX" type="boolean" required="false" default="false" hint="indicates if the mask is a regular expression">
		<cfset var stSkip = this.getValue("skip")>
		<cfif skip><cfset stSkip[mask] = rex>
		<cfelse><cfset structDelete(stSkip,mask)></cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getListeners" returntype="struct" output="false" access="private">
		<cfparam name="variables.listeners" type="struct" default="#structnew()#">
		<cfreturn variables.listeners>
	</cffunction>
	
	<cffunction name="addListener" access="public" output="false">
		<cfargument name="event" type="string" required="true" hint="indicates the event which should be broadcast to the registered listener">
		<cfargument name="listener" type="any" required="true" hint="a component object which listens to ftp events">
		<cfset var queue = getListeners()>
		<cfif not structKeyExists(queue,arguments.event)>
		<cfset queue[arguments.event] = ArrayNew(1)></cfif>
		<cfset arrayAppend(queue[arguments.event],arguments.listener)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="broadcast" returntype="void" access="private" output="false" hint="broadcasts ftp events to listener objects">
		<cfargument name="eventname" type="string" required="true" hint="indicates the event to broadcast">
		<cfargument name="eventdata" type="struct" required="true" hint="an ftp result structure to return to the listening object">
		<cfargument name="eventaction" type="string" required="false" default="#arguments.eventname#" hint="indicates the ftp action attempted">
		
		<cfset var x = 0>
		<cfset var queue = getListeners()>
		
		<cfif structKeyExists(queue,arguments.eventname)>
			<cfset queue = queue[arguments.eventname]>
			<cfloop index="x" from="1" to="#arraylen(queue)#">
				<cfinvoke component="#queue[x]#" method="respond" argumentcollection="#arguments#">
			</cfloop>
		</cfif>
		
		<cfif arguments.eventdata.ErrorCode eq 226><cfset variables.isOpen = false></cfif>
		<cfif arguments.eventname is not "error" and not arguments.eventdata.Succeeded and arguments.eventdata.ErrorCode neq 250>
		<cfset broadcast("error",eventdata,eventaction)></cfif>
	</cffunction>
	
	<cffunction name="stopOnError" returntype="boolean" access="private" output="false" hint="returns the current stopOnError value of the ftp object">
		<cfreturn this.getValue("stopOnError")>
	</cffunction>
	
	<cffunction name="connection" returntype="string" access="private" output="false" hint="returns the name of the ftp connection">
		<cfreturn this.getValue("connection")>
	</cffunction>
	
	<cffunction name="open" access="public" output="false" hint="opens the named connection to the ftp server">
		<cfargument name="wait" type="numeric" default="#this.getValue('timeout')#">
		<cfargument name="retryCount" type="numeric" default="#this.getValue('retryCount')#">
		<cfargument name="passive" type="boolean" default="#this.getValue('passive')#">
		
		<cfset var cfftp = structNew()>
		
		<cfif not variables.isOpen>
			<cfftp action="open" result="cfftp" 
				server="#this.getValue('server')#"
				username="#this.getValue('usr')#"
				password="#this.getValue('pwd')#"
				timeout="#arguments.wait#"
				port="#this.getValue('port')#"
				connection="#connection()#"
				proxyserver="#this.getValue('proxyServer')#"
				retrycount="#arguments.retryCount#"
				stoponerror="#stopOnError()#"
				passive="#arguments.passive#">
			<cfset variables.isOpen = iif(cfftp.Succeeded and cfftp.ErrorCode eq 230,true,false)>
			<cfset broadcast("open",cfftp)><cfif variables.isOpen>
			<cfset this.changeDir(this.getValue("remote"))></cfif>
		</cfif>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="close" access="public" output="false" hint="closes the named connection to the ftp server">
		<cfset var connection = connection()>
		<cfset var cfftp = structnew()>
		<cfif len(trim(connection)) and variables.isOpen>
			<cfftp action="close" connection="#connection#" stoponerror="#stopOnError()#">
			<cfset variables.isOpen = yesnoformat(not cfftp.Succeeded)>
			<cfset broadcast("close",cfftp)>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getCurrentDir" returntype="string" access="public" output="false" hint="gets the current directory from the ftp connection">
		<cfset var cfftp = 0><cfif not variables.isOpen><cfset open()></cfif>
		<cfftp action="getCurrentDir" connection="#connection()#" stoponerror="#stopOnError()#">
		<cfif not cfftp.Succeeded><cfset broadcast("error",cfftp,"getCurrentDir")></cfif>
		<cfreturn cfftp.returnvalue>
	</cffunction>
	
	<cffunction name="getCurrentURL" returntype="string" access="public" output="false" hint="gets the current url from the ftp connection">
		<cfset var cfftp = 0><cfif not variables.isOpen><cfset open()></cfif>
		<cfftp action="getCurrentURL" connection="#connection()#" stoponerror="#stopOnError()#">
		<cfif not cfftp.Succeeded><cfset broadcast("error",cfftp,"getCurrentURL")></cfif>
		<cfreturn cfftp.returnvalue>
	</cffunction>
	
	<cffunction name="exists" returntype="boolean" access="public" output="false" 
	hint="indicates if a specified file or directory exists on the ftp server">
		<cfargument name="item" type="string" required="true" hint="indicates the file or direcotry to find">
		<cfargument name="type" type="string" required="false" default="" hint="file or dir - indicates the type of object to detect">
		<cfset var cfftp = 0><cfset arguments.type = "exists" & rereplacenocase(arguments.type,"^(file|dir).*$","\1")>
		<cfset arguments.item = getRemotePath(arguments.item)>
		<cfif not variables.isOpen><cfset open()></cfif>
		<cfswitch expression="#arguments.type#">
			<cfcase value="exists"><cfftp item="#arguments.item#" action="#arguments.type#" connection="#connection()#" stoponerror="#stopOnError()#"></cfcase>
			<cfcase value="existsFile"><cfftp remotefile="#arguments.item#" action="#arguments.type#" connection="#connection()#" stoponerror="#stopOnError()#"></cfcase>
			<cfcase value="existsDir"><cfftp directory="#arguments.item#" action="#arguments.type#" connection="#connection()#" stoponerror="#stopOnError()#"></cfcase>
		</cfswitch>
		<cfif cfftp.ErrorCode neq 250 and not cfftp.Succeeded>
			<cfset cfftp.item = arguments.item>
			<cfset broadcast("error",cfftp,arguments.type)>
		</cfif>
		<cfreturn cfftp.returnvalue>
	</cffunction>
	
	<cffunction name="changeDir" returntype="struct" access="public" output="false" hint="indicates if a specified file or directory exists on the ftp server">
		<cfargument name="directory" type="string" required="true">
		<cfset var cfftp = 0><cfif not variables.isOpen><cfset open()></cfif>
		<cfftp action="changeDir" directory="#arguments.directory#" connection="#connection()#" stoponerror="#stopOnError()#">
		<cfset broadcast("changeDir",cfftp)>
		<cfset setProperty("remote",this.getCurrentDir())>
		<cfreturn cfftp>
	</cffunction>
	
	<cffunction name="createDir" returntype="struct" access="public" output="false" hint="creates a specified directory and any parent directories on the ftp server">
		<cfargument name="directory" type="string" required="true">
		<cfset var cfftp = 0><cfset var parent = REReplaceNoCase(arguments.directory,"[\\/]?[^\\/]+[\\/]?$","")>
		<cfif not variables.isOpen><cfset open()></cfif>
		<cfif REFindNoCase("[^[:punct:]]",parent) and not exists(parent,"directory")><cfset createDir(parent)></cfif>
		<cfftp action="createDir" directory="#arguments.directory#" connection="#connection()#" stoponerror="#stopOnError()#">
		<cfset broadcast("createDir",cfftp)><cfreturn cfftp>
	</cffunction>
	
	<cffunction name="remove" returntype="struct" access="public" output="false" 
	hint="removes a specified directory from the ftp server">
		<cfargument name="item" type="string" required="true">
		<cfargument name="removeRemote" type="boolean" required="false" default="true">
		<cfset var my = structnew()>
		<cfset var cfftp = 0>
		
		<cfif arguments.removeRemote>
			<cfif this.exists(arguments.item,"directory")>
				<cfset my.dir = variables.dir(arguments.item)>
				<cfloop query="my.dir">
					<cfset remove(arguments.item & "/" & my.dir.name)>
				</cfloop>
				<cfftp action="removeDir" directory="#arguments.item#" connection="#connection()#" stoponerror="#stopOnError()#">
				<cfset broadcast("remove",cfftp,"removeDir")>
			<cfelse>
				<cfftp action="remove" item="#arguments.item#" connection="#connection()#" stoponerror="#stopOnError()#">
				<cfset broadcast("remove",cfftp,"remove")>
			</cfif>
		<cfelse>
			<cfset variables.fileObject.init(arguments.item).delete()>
			<cfftp action="exists" item="#arguments.item#" connection="#connection()#" stoponerror="#stopOnError()#">
			<cfset broadcast("remove",cfftp,"")>
		</cfif>
		
		<cfreturn cfftp>
	</cffunction>
	
	<cffunction name="getLocalPath" returntype="string" access="public" output="false" 
	hint="returns the remote file path which corresponds to an absolute path on the local file system">
		<cfargument name="filepath" type="string" required="true">
		<cfset var localpath = this.getValue("local")>
		<cfif findnocase(getFS().getPath("",localpath),arguments.filepath) neq 1>
			<cfset arguments.filepath = getFS().getPath(arguments.filepath,localpath)>
		</cfif>
		<cfreturn arguments.filepath>
	</cffunction>
	
	<cffunction name="getRemotePath" returntype="string" access="public" output="false" 
	hint="returns the remote file path which corresponds to an absolute path on the local file system">
		<cfargument name="filepath" type="string" required="true">
		<cfset var remote = this.getValue("remote")>
		<cfif findnocase("/" & listchangedelims(remote,"/","\/"),arguments.filepath) neq 1>
		<cfset arguments.filepath = "/" & listchangedelims(remote & "/" & arguments.filepath,"/","\/")></cfif>
		<cfreturn arguments.filepath>
	</cffunction>
	
	<cffunction name="skip" returntype="boolean" access="public" output="false" 
	hint="indicates if a specified file path should be skipped during transfer operations">
		<cfargument name="path" type="string" required="true">
		<cfset var file = getFileFromPath(path)>
		<cfset var fullpath = getLocalPath(path)>
		<cfset var mask = ""><cfset var skip = this.getValue("skip")>
		<cfset path = REReplace(path,"[\\/]+","/","ALL")>
		
		<cfloop item="mask" collection="#skip#">
			<cfif skip[mask]><!--- mask is a regular expression --->
				<cfif REFindNoCase(mask,fullpath)><cfreturn true></cfif>
			<cfelse><!--- mask is a flat string --->
				<cfif mask is path or mask is file or mask is fullpath><cfreturn true></cfif>
			</cfif>
		</cfloop>
		
		<cfreturn false>
	</cffunction>
	
	<cffunction name="get" returntype="struct" access="public" output="false" 
	hint="transfers a remote file to the local server">
		<cfargument name="source" type="string" required="true">
		<cfargument name="transfermode" type="string" required="false" default="#this.getValue('transfermode')#">
		<cfargument name="destination" type="string" required="false" default="#arguments.source#">
		<cfset var my = structnew()>
		<cfset var cfftp = StructNew()>
		
		<cfset my.source = getRemotePath(arguments.source)>
		<cfset my.destination = getLocalPath(arguments.destination)>
		
		<cfif skip(arguments.source)>
			<cfset cfftp.errorcode = 0>
			<cfset cfftp.errortext = "skipped">
			<cfset cfftp.returnvalue = arguments.source>
			<cfset cfftp.succeeded = "YES">
			<cfset broadcast("get",cfftp)>
		<cfelseif exists(my.source,"file")>
			<cfif not variables.isOpen><cfset open()></cfif>
			<cfset variables.fileObject.init(getDirectoryFromPath(arguments.destination)).mkdir()>
			
			<cfftp action="getFile" connection="#connection()#" stoponerror="#stopOnError()#"
				remotefile="#my.source#" localfile="#my.destination#" 
				transfermode="#arguments.transfermode#" asciiextensionlist="#this.getValue('asciiextensions')#"
				retrycount="#this.getValue('retrycount')#" failifexists="#this.getValue('failifexists')#">
			
			<cfset variables.fileObject.init(my.destination).clearCache()>
			<cfset broadcast("get",cfftp)>
		<cfelse>
			<cfset my.dir = this.dir(my.source)><cfloop query="my.dir">
			<cfset this.get(my.source & "/" & my.dir.name,arguments.destination & "/" & my.dir.name)></cfloop>
			<cfset cfftp.errorcode = 0>
			<cfset cfftp.errortext = "">
			<cfset cfftp.returnvalue = 0>
			<cfset cfftp.succeeded = "YES">
		</cfif>
		
		<cfreturn cfftp>
	</cffunction>
	
	<cffunction name="put" returntype="struct" access="public" output="false" 
	hint="transfers a local file to the remote server">
		<cfargument name="source" type="string" required="true">
		<cfargument name="transfermode" type="string" required="false" default="#this.getValue('transfermode')#">
		<cfargument name="destination" type="string" required="false" default="#arguments.source#">
		<cfset var my = structnew()>
		<cfset var cfftp = StructNew()>
		<cfset my.source = getLocalPath(arguments.source)>
		
		<cfif skip(arguments.source)>
			<cfset cfftp.errorcode = 0>
			<cfset cfftp.errortext = "skipped">
			<cfset cfftp.returnvalue = arguments.source>
			<cfset cfftp.succeeded = "YES">
			<cfset broadcast("put",cfftp)>
		<cfelseif FileExists(my.source)>
			<cfif not variables.isOpen><cfset open()></cfif>
			<cfset my.directory = getDirectoryFromPath(arguments.destination)>
			<cfif len(my.directory) and not this.exists(my.directory,"directory")>
			<cfset this.createDir(my.directory)></cfif>
			<cfftp action="putFile" connection="#connection()#" stoponerror="#stopOnError()#"
				remotefile="#getRemotePath(arguments.destination)#" localfile="#my.source#"
				transfermode="#arguments.transfermode#" asciiextensionlist="#this.getValue('asciiextensions')#"
				retrycount="#this.getValue('retrycount')#" failifexists="#this.getValue('failifexists')#">
			<cfset broadcast("put",cfftp)>
		<cfelse>
			<cfset my.dir = variables.fileObject.dir()><cfloop query="my.dir">
			<cfset this.put(my.source & "/" & my.dir.name,arguments.destination & "/" & my.dir.name)></cfloop>
			<cfset cfftp.errorcode = 0>
			<cfset cfftp.errortext = "">
			<cfset cfftp.returnvalue = 0>
			<cfset cfftp.succeeded = "YES">
		</cfif>
		
		<cfreturn cfftp>
	</cffunction>
	
	<cffunction name="dir" returntype="query" access="public" output="false" 
	hint="returns a query containing all files in a specified direcotry with modified dates adjusted to UTC">
		<cfargument name="directory" type="string" required="false" default="">
		<cfset var rs = ""><cfset var cfftp = 0>
		<cfset var timezone = this.getValue("timezone")>
		
		<cfif not variables.isOpen><cfset open()></cfif>
		
		<cfftp action="listDir" name="rs" directory="#arguments.directory#" 
			connection="#connection()#" stoponerror="#stopOnError()#">
		
		<cfif isQuery(rs)>
			<cfloop query="rs">
				<cfset rs.lastmodified = getLib().lsTimeToUTC(rs.lastmodified[currentrow],timezone)>
			</cfloop>
		<cfelse>
			<cfset rs = QueryNew("name,path,url,length,lastmodified,attributes,mode,isdirectory")>
		</cfif>
		
		<cfif not cfftp.Succeeded><cfset broadcast("error",cfftp,"listDir")></cfif>
		
		<cfreturn rs>
	</cffunction>
	
	<cffunction name="map" returntype="query" access="public" output="false" 
	hint="returns an index of all files within a specified directory on the ftp server">
		<cfargument name="directory" type="string" required="false" default="">
		<cfset var rs = 0><cfset var rs2 = 0>
		<cfset var c = 0><cfset var x = 0>
		
		<cfset directory = getRemotePath(directory)>
		<cfset rs = this.dir(directory)>
		<cfloop query="rs">
			<cfif rs.isdirectory>
				<cfset rs2 = this.map(directory & "/" & rs.name)>
				<cfloop query="rs2">
					<cfset QueryAddRow(rs,1)>
					<cfset x = rs.recordcount>
					<cfloop index="c" list="#rs2.columnlist#">
						<cfset rs[c][x] = rs2[c][currentrow]>
					</cfloop>
				</cfloop>
			</cfif>
		</cfloop>
		<cfreturn rs>
	</cffunction>
	
	<cffunction name="queue" access="public" output="false" 
	hint="adds a file transfer operation to the ftp object's queue for later transfer">
		<cfargument name="operation" type="string" required="true">
		<cfargument name="source" type="string" required="true">
		<cfargument name="transfermode" type="string" required="false" default="#this.getValue('transfermode')#">
		<cfargument name="destination" type="string" required="false" default="#arguments.source#">
		
		<cfset arguments.item = arguments.source>
		<cfset arguments.removeRemote = iif(isboolean(arguments.transfermode),"arguments.transfermode",true)>
		<cfset arguments.localpath = this.getValue("local")>
		<cfset arguments.remotepath = this.getValue("remote")>
		<cfset arrayAppend(variables.fileQueue,arguments)>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="removeFromQueue" access="public" output="false" 
	hint="removes an individual line-item from the transfer queue">
		<cfargument name="index" type="numeric" required="true">
		<cfif arraylen(variables.fileQueue) gte index>
			<cfset arrayDeleteAt(variables.fileQueue,index)>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="clearQueue" access="public" output="false" hint="removes all transfer operations from the queue">
		<cfset variables.fileQueue = arrayNew(1)>
	</cffunction>
	
	<cffunction name="transferQueue" access="public" output="false" 
	hint="transfers all queued files to/from the loaded ftp server">
		<cfset var localpath = this.getValue("local")>
		<cfset var remotepath = this.getValue("remote")>
		
		<cfloop condition="arrayLen(variables.fileQueue)">
			<cfif variables.fileQueue[1].localpath is not localpath>
				<cfset this.setValue("local",variables.fileQueue[1].localpath)>
			</cfif>
			
			<cfif variables.fileQueue[1].remotepath is not remotepath>
				<cfset this.changeDir(variables.fileQueue[1].remotepath)>
			</cfif>
			
			<cfinvoke method="#variables.fileQueue[1].operation#" argumentcollection="#variables.fileQueue[1]#">
			<cfset arrayDeleteAt(variables.fileQueue,1)>
		</cfloop>
		
		<cfset this.close()>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="queueSynchronization" access="public" output="false" 
	hint="analyzes local and remote directory structures and queues transfer of only files which are new or modified">
		<cfargument name="directory" type="string" required="false" default="">
		<cfargument name="get" type="boolean" required="false" default="true">
		<cfargument name="put" type="boolean" required="false" default="true">
		<cfargument name="remove" type="boolean" required="false" default="true">
		<cfset var rsRemote = this.dir(arguments.directory)>
		<cfset var fso = createObject("java","java.io.File")>
		<cfset var jdate = createObject("java","java.util.Date")>
		<cfset var timezone = this.getValue("timezone")>
		<cfset var tolerance = this.getValue("tolerance")>
		<cfset var localtime = getLib().timeZone.info().timezoneid>
		<cfset var filearray = ArrayNew(1)>
		<cfset var filelist = "">
		<cfset var temp = 0>
		<cfset var x = 0>
		
		<cfif arguments.get and arguments.put><cfset arguments.remove = false></cfif>
		
		<cfif arguments.get>
			<!--- loop over remote files and check for files to be downloaded --->
			<cfset temp = replace(getLocalPath(arguments.directory),"\","/","ALL")>
			
			<cfloop query="rsRemote">
				<cfif rsremote.isdirectory>
					<cfset queueSynchronization(arguments.directory & "/" & rsremote.name,arguments.get,arguments.put,arguments.remove)>
				<cfelse>
					<!--- compare file times to queue get operation --->
					<cfset fso.init(temp & "/" & rsremote.name)>
					<cfif not fso.exists() or dateDiff("s",getLib().lsTimeToUTC(jDate.init(fso.lastModified())),getLib().lsTimeToUTC(rsremote.lastmodified,timezone)) gte tolerance>
						<cfset queue("get",REReplace(arguments.directory & "/" & rsremote.name,"^/",""))>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfif arguments.put>
			<!--- loop over remote files and check for files to be downloaded --->
			<cfset temp = replace(getLocalPath(arguments.directory),"\","/","ALL")>
			<cfset fso.init(temp)>
			
			<cfif fso.exists() and fso.isDirectory()>
				<cfset fileArray = fso.listFiles()>
				
				<cfloop index="x" from="1" to="#arraylen(fileArray)#">
					<cfif fileArray[x].isDirectory()>
						<cfset queueSynchronization(arguments.directory & "/" & fileArray[x].getName(),arguments.get,arguments.put,arguments.remove)>
					<cfelse>
						<!--- compare file times to queue get operation --->
						<cfquery name="temp" dbtype="query" debug="false">
							select * from rsremote where lower(name) = '#lcase(fileArray[x].getName())#'
						</cfquery>
						<cfif not temp.recordcount or dateDiff("s",getLib().lsTimeToUTC(temp.lastmodified,timezone),getLib().lsTimeToUTC(jDate.init(fileArray[x].lastModified()),localtime)) gte tolerance>
							<cfset queue("put",REReplace(arguments.directory & "/" & fileArray[x].getName(),"^/",""))>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		
		<cfif arguments.remove>
			<cfset temp = replace(getLocalPath(arguments.directory),"\","/","ALL")>
			<cfset fso.init(temp)>
			
			<cfif arguments.get>
				<!--- find local files to delete --->
				<cfif fso.exists() and fso.isDirectory()>
				<cfset fileArray = fso.list()></cfif>
				<cfset filelist = ValueList(rsRemote.name,"/")>
			</cfif>
			<cfif arguments.put>
				<!--- find remote files to delete --->
				<cfset fileArray = getLib().QueryColumnToArray(rsRemote,"name")>
				<cfif fso.exists() and fso.isDirectory()>
				<cfset fileList = arrayToList(fso.list(),"/")></cfif>
			</cfif>
			<cfloop index="x" from="1" to="#arraylen(filearray)#">
				<cfif not ListFindNoCase(filelist,fileArray[x],"/")>
					<cfset this.queue("remove",REReplace(arguments.direcotry & "/" & fileArray[x],"^/",""),false)>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn this>
	</cffunction>

	<cffunction name="Synchronize" access="public" output="false" 
	hint="queues and immediately transfers/deletes all new or modified files">
		<cfargument name="directory" type="string" required="false" default="">
		<cfargument name="get" type="boolean" required="false" default="true">
		<cfargument name="put" type="boolean" required="false" default="true">
		<cfargument name="remove" type="boolean" required="false" default="true">
		
		<cfinvoke method="queueSynchronization" argumentcollection="#arguments#">
		<cfreturn this.transferQueue()>
	</cffunction>
	
	<cffunction name="get_queueLength" access="private" output="false" returntype="numeric">
		<cfreturn arraylen(variables.fileQueue)>
	</cffunction>
	
	<cffunction name="get_queue" access="private" output="false" returntype="query" 
	hint="returns a query containing all queued transfer operations">
		<cfset var qry = QueryNew("localpath,remotepath,source,destination,operation,transfermode")>
		<cfset var x = 0>
		<cfset var c = "">
		
		<cfif arrayLen(variables.fileQueue)>
			<cfset QueryAddRow(qry,arraylen(variables.fileQueue))>
		</cfif>
		
		<cfloop index="x" from="1" to="#arraylen(variables.fileQueue)#">
			<cfloop index="c" list="#qry.columnlist#">
				<cfset qry[c][x] = variables.fileQueue[x][c]>
			</cfloop>
		</cfloop>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="set_server" access="private" output="false" returntype="void">
		<cfset this.close()>
		<cfset setProperty(arguments.propertyname,arguments.propertyvalue,arguments.overwrite)>
	</cffunction>
	
	<cffunction name="set_usr" access="private" output="false" returntype="void">
		<cfset this.close()>
		<cfset setProperty(arguments.propertyname,arguments.propertyvalue,arguments.overwrite)>
	</cffunction>
	
	<cffunction name="set_pwd" access="private" output="false" returntype="void">
		<cfset this.close()>
		<cfset setProperty(arguments.propertyname,arguments.propertyvalue,arguments.overwrite)>
	</cffunction>
	
	<cffunction name="set_port" access="private" output="false" returntype="void">
		<cfset this.close()>
		<cfset setProperty(arguments.propertyname,arguments.propertyvalue,arguments.overwrite)>
	</cffunction>
	
	<cffunction name="set_connection" access="private" output="false" returntype="void">
		<cfset this.close()>
		<cfset setProperty(arguments.propertyname,arguments.propertyvalue,arguments.overwrite)>
	</cffunction>

	<cffunction name="set_proxyServer" access="private" output="false" returntype="void">
		<cfset this.close()>
		<cfset setProperty(arguments.propertyname,arguments.propertyvalue,arguments.overwrite)>
	</cffunction>
	
	<cffunction name="set_local" access="private" output="false" returntype="void">
		<cfset variables.fileObject.setValue("domain",arguments.propertyValue)>
		<cfset setProperty(arguments.propertyname,arguments.propertyvalue,arguments.overwrite)>
	</cffunction>
	
	<cffunction name="set_remote" access="private" output="false" returntype="void">
		<cfset arguments.propertyValue = "/" & listchangedelims(arguments.propertyValue,"/","\/")>
		<cfif variables.isOpen><cfset this.close()><cfset this.open()></cfif>
		<cfset setProperty(arguments.propertyname,arguments.propertyvalue,arguments.overwrite)>
	</cffunction>
</cfcomponent>