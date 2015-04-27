<cfcomponent displayname="PluginManager" output="false" 
extends="cfc.ioc.ioccontainer" hint="a facade for managing application plugins">
	
	<cffunction name="init" access="public" output="false">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="jsLocation" access="private" output="false">
		<cfargument name="href" type="string" required="true" />
		<cfargument name="window" type="string" required="false" default="window" />
		<cfreturn getLib().js.location(href,"plugins",arguments.window) />
	</cffunction>
	
	<cffunction name="jsOut" access="private" output="false">
		<cfargument name="script" type="string" required="true" />
		<cfreturn getLib().jsOut(script) />
	</cffunction>
	
	<cffunction name="getPage" access="private" output="false">
		<cfreturn getTap().getPage() />
	</cffunction>
	
	<cffunction name="goHome" access="public" output="false" returntype="string" 
	hint="returns a string of javascript which redirects the page to the Plugin Manager index">
		<cfargument name="window" type="string" required="false" default="window">
		<cfset var result = jsLocation("?",arguments.window) />
		
		<cfif getPage().doctype is not "javascript">
			<cfset result = jsout(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getPluginSource" access="public" output="false" returntype="string"
	hint="returns the absolute path to the directory in which the installer for a specified plugin resides">
		<cfargument name="plugin" type="string" required="true">
		<cfreturn getDirectoryFromPath(ExpandPath(getPluginPath(arguments.plugin)))>
	</cffunction>
	
	<cffunction name="getPluginName" access="private" output="false" returntype="string" 
	hint="simple hack to let the application use the framework process path to instantiate a plugin">
		<cfargument name="plugin" type="string" required="true">
		<cfif findnocase("/plugins/source/",arguments.plugin)>
			<cfreturn rereplacenocase(arguments.plugin,"^.*/plugins/source/([^/]+).*$","\1")>
		<cfelse><cfreturn arguments.plugin></cfif>
	</cffunction>
	
	<cffunction name="getPluginPath" access="public" output="false" returntype="string"
	hint="returns a relative path from the PluginManager directory to the installer CFC for an individual plugin">
		<cfargument name="plugin" type="string" required="true">
		<cfreturn "/plugins/#getPluginName(arguments.plugin)#/plugin.cfc">
	</cffunction>
	
	<cffunction name="pluginExists" access="public" output="false" returntype="string" 
	hint="indicates if the installer CFC for a specified plugin exists in the file system">
		<cfargument name="plugin" type="string" required="true">
		<cfargument name="installed" type="boolean" required="false" default="false" hint="if true this method will only return true if the plugin is also installed" />
		<cfset var exists = FileExists(ExpandPath(getPluginPath(arguments.plugin))) />
		<cfif exists and arguments.installed>
			<cfset exists = getManifest().hasPlugin(plugin) />
		</cfif>
		<cfreturn exists />
	</cffunction>
	
	<cffunction name="setSource" access="private" output="false" returntype="void">
		<cfargument name="plugin" required="false" default="">
		<cfargument name="source" required="false" default="">
		<cfset var methodname = "pluginManagerSetSource">
		<cfif isObject(plugin) and isSimpleValue(source) and len(trim(source))>
			<cfset plugin.setValue("source",arguments.source)>
			<cfset plugin[methodname] = variables.setSource>
			<cfinvoke component="#plugin#" method="#methodName#">
		<cfelseif structkeyexists(this,methodName)>
			<cfset variables.set_source = this[methodName]>
			<cfset structDelete(this,methodName)>
		<cfelse>
			<cfthrow type="onTap" message="Source Property is Read Only"
			detail="<p>You have attempted to set the &quot;source&quot; property of /#getValue('source')#/plugin.cfc</p>
			<p>This property is read only - see the Plugin Manager documentation for details</p>">
		</cfif>
	</cffunction>
	
	<cffunction name="getPluginObject" access="public" output="false" 
	hint="returns an instance of the installer CFC for a specified plugin">
		<cfargument name="plugin" type="string" required="true" hint="canonical name of the plugin to return">
		<cfargument name="installed" type="boolean" required="false" default="false" hint="if true the plugin will reflect installed version information" />
		<cfset var obj = 0 />
		
		<cfset arguments.plugin = getPluginName(arguments.plugin) />
		<cfset obj = CreateObject("component","plugins.#arguments.plugin#.plugin").init(this) />
		
		<cfif arguments.installed>
			<cfset obj.setProperties(getManifest().getPluginData(arguments.plugin)) />
		</cfif>
		
		<cfset setSource(obj,arguments.plugin) />
		<cfset obj.configure() />
		<cfreturn obj />
	</cffunction>
	
	<cffunction name="getBean" access="public" output="false" returntype="any" hint="returns an installed plugin - used by the IoC Manager">
		<cfargument name="beanName" type="string" required="true" />
		<cfreturn getPluginObject(beanName,true) />
	</cffunction>
	
	<cffunction name="containsBean" access="public" output="false" returntype="boolean" hint="indicates if a specified plugin is present and installed - used by the IoC Manager">
		<cfargument name="beanName" type="string" required="true" />
		<cfreturn pluginExists(beanName,true) />
	</cffunction>
	
	<cffunction name="getPluginProperty" access="public" output="false" returntype="any"
	hint="returns an individual property from an instance of the installer CFC for a specified plugin if the plugin is installed - returns an empty string if the plugin is not installed">
		<cfargument name="plugin" type="string" required="true">
		<cfargument name="property" type="string" required="true">
		
		<cfif isInstalled(arguments.plugin)>
			<cfreturn getPluginObject(arguments.plugin).getValue(arguments.property)>
		<cfelse><cfreturn ""></cfif>
	</cffunction>
	
	<cffunction name="getPluginVersion" access="public" output="false" returntype="string">
		<cfargument name="plugin" type="string" required="true">
		<cfreturn getPluginProperty(arguments.plugin,"version")>
	</cffunction>
	
	<cffunction name="getPluginReleasedate" access="public" output="false" returntype="string">
		<cfargument name="plugin" type="string" required="true">
		<cfreturn getPluginProperty(arguments.plugin,"releasedate")>
	</cffunction>
	
	<cffunction name="getPluginBuildNumber" access="public" output="false" returntype="string">
		<cfargument name="plugin" type="string" required="true">
		<cfreturn getPluginProperty(arguments.plugin,"buildnumber")>
	</cffunction>
	
	<cffunction name="versionCompare" access="public" output="false" returntype="boolean"
	hint="indicates if a specified version number is greater than or equal to a specified minimum version number">
		<cfargument name="version" type="string" required="true">
		<cfargument name="minversion" type="string" required="true">
		<cfset var aVersion = listToArray(arguments.version,".,")>
		<cfset var mVersion = listToArray(arguments.minversion,".,")>
		<cfset var x = 0>
		<cfset var y = 0>
		
		<cfloop condition="arraylen(aVersion) gt arraylen(mVersion)"><cfset arrayAppend(mVersion,0)></cfloop>
		<cfloop condition="arraylen(aVersion) lt arraylen(mVersion)"><cfset arrayAppend(aVersion,0)></cfloop>
		
		<cfloop index="x" from="1" to="#arrayLen(mVersion)#">
			<cfset y = val(aVersion[x])>
			<cfif val(mVersion[x]) lt y>
				<cfreturn true>
			<cfelseif val(mVersion[x]) gt y>
				<cfreturn false>
			</cfif>
		</cfloop>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="isInstalled" access="public" output="false" returntype="boolean"
	hint="indicates if a specified plugin is installed and meets specific minimum version requirements">
		<cfargument name="plugin" type="string" required="true">
		<cfargument name="minversion" type="string" required="false" default="">
		<cfargument name="minbuildnumber" type="numeric" required="false" default="0">
		<cfargument name="minreleasedate" type="string" required="false" default="">
		
		<cfset var installed = false />
		<cfset var manifest = getManifest() />
		
		<cfif manifest.hasPlugin(arguments.plugin)>
			<cfset plugin = getPluginObject(arguments.plugin,true) />
			<cfset installed = true />
			
			<cfif not versionCompare(plugin.getValue("version"),arguments.minversion)>
				<cfset installed = false />
			<cfelseif val(arguments.minbuildnumber) gt 0 
			and val(plugin.getValue("buildnumber")) lt val(arguments.minbuildnumber)>
				<cfset installed = false />
			<cfelseif isDate(arguments.minreleasedate) 
			and datediff("d",arguments.minreleasedate,plugin.getValue("releasedate")) lt 0>
				<cfset installed = false />
			</cfif>
		</cfif>
		
		<cfreturn installed>
	</cffunction>
	
	<cffunction name="scanForArchives" access="public" output="false">
		<cfset var MyDir = ExpandPath("/plugins") />
		<cfset var f = CreateObject("component","cfc.file").init(file="%plugins/nothing.zip", type="zip") />
		<cfdirectory action="list" name="local.list" directory="#myDir#" filter="*.zip" />
		<cfloop query="local.list">
			<cfif not DirectoryExists(myDir & "/" & listfirst(name, ".")) and isPluginArchive(f.setFile("%plugins/source/#name#"))>
				<cfset importPluginArchive(f, false) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="getPluginList" access="public" output="false" 
	hint="returns the head of a chain of LinkedList.cfc components initialized with the installer CFCs for a collection of plugins">
		<cfargument name="plugintype" type="string" required="false" default="" hint="new|installed|all - indicates which plugins should be included in the returned list">
		<cfset var list = CreateObject("component","cfc.linkedlist") />
		<cfset var source = ExpandPath("/plugins") />
		<cfset var plugin = createObject("java","java.io.File").init(JavaCast("string",source)).list() />
		<cfset var manifest = structNew() />
		<cfset var next = 0 />
		<cfset var x = 0 />
		<cfset var installed = "" />
		
		<cfswitch expression="#arguments.plugintype#">
			<cfcase value="new"><cfset installed = false></cfcase>
			<cfcase value="installed"><cfset installed = true></cfcase>
		</cfswitch>
		
		<cfif plugintype is not "new">
			<!--- get version information for all previously installed plugins --->
			<cfset manifest = getManifest().getAll() />
		</cfif>
		
		<cfloop index="x" from="#arrayLen(plugin)#" to="1" step="-1">
			<cfif pluginExists(plugin[x])>
				<cfset next = getPluginObject(plugin[x])>
				
				<!--- overwrite the plugin version information with the installed version information --->
				<cfif structKeyExists(manifest,plugin[x])>
					<cfset next.setProperties(manifest[plugin[x]]) />
				</cfif>
				
				<cfif not isBoolean(installed) or (installed xor not next.isInstalled())>
					<cfset list.insertAfter(CreateObject("component","cfc.linkedlist").init(next))>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfset list.sort("version","numeric","asc")>
		<cfset list.sort("name","text","asc")>
		<cfreturn list>
	</cffunction>
	
	<cffunction name="getListeners" returntype="struct" output="false" access="private">
		<cfparam name="variables.listeners" type="struct" default="#structnew()#">
		<cfreturn variables.listeners>
	</cffunction>
	
	<cffunction name="addListener" returntype="boolean" access="public" output="false" 
	hint="allows components to listen for the installation, removal or configuration of various plugins">
		<cfargument name="event" type="string" required="true" hint="install|uninstall|statechange - indicates the event which should be broadcast to the registered listener">
		<cfargument name="listener" type="any" required="true" hint="a component object which listens to plugin events">
		<cfargument name="plugin" type="string" required="false" default="" hint="a comma delimited list of the plugins for which the listener wishes to be notified of changes">
		<cfset var queue = getListeners()>
		<cfif not structKeyExists(queue,arguments.event)>
		<cfset queue[arguments.event] = ArrayNew(1)></cfif>
		<cfset arrayAppend(queue[arguments.event],arguments)>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="broadcast" returntype="boolean" access="private" output="false" hint="broadcasts plugin events to listener objects">
		<cfargument name="eventname" type="string" required="true" hint="indicates the event to broadcast">
		<cfargument name="plugin" type="string" required="true" hint="indicates the plugin which created the event">
		
		<cfset var x = 0>
		<cfset var queue = getListeners()>
		<cfset var pluginpath = arguments.plugin>
		<cfset arguments.plugin = getPluginObject(arguments.plugin)>
		
		<cfif structKeyExists(queue,arguments.eventname)>
			<cfset queue = queue[arguments.eventname]>
			<cfloop index="x" from="1" to="#arraylen(queue)#">
				<cfif not len(trim(queue[x].plugin)) or listFindNoCase(queue[x].plugin,pluginpath)>
					<cfset queue[x].respond(eventname,arguments.plugin)>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="resetApplication" access="private" output="false" returntype="void">
		<cfset getTap().reinit() />
	</cffunction>
	
	<cffunction name="getManifest" access="private" output="false">
		<cfreturn getIoC().getBean("pluginmanifest") />
	</cffunction>
	
	<cffunction name="announceInstall" access="public" output="false" returntype="void" 
	hint="broadcasts an install event to all registered listeners - a stateChange event is announced prior to the install event">
		<cfargument name="plugin" type="any" required="true" hint="indicates the plugin which created the event" />
		<cfset var source = plugin.getValue("source") />
		<cfset getManifest().install(plugin) />
		<cfset broadCast("statechange",source) />
		<cfset broadcast("install",source) />
		<cfset resetApplication() />
	</cffunction>
	
	<cffunction name="announceUninstall" access="public" output="false" returntype="void" 
	hint="broadcasts an uninstall event to all registered listeners - a stateChange event is announced prior to the uninstall event">
		<cfargument name="plugin" type="any" required="true" hint="indicates the plugin which created the event" />
		<cfset var source = plugin.getValue("source") />
		<cfset getManifest().uninstall(source) />
		<cfset broadcast("statechange",source) />
		<cfset broadcast("uninstall",source) />
		<cfset resetApplication() />
	</cffunction>
	
	<cffunction name="announceStateChange" access="public" output="false" returntype="void" 
	hint="broadcasts a stateChange event to all listeners - used to indicate a change in plugin configuration - this may or may not include installing or uninstalling the plugin">
		<cfargument name="plugin" type="string" required="true" hint="indicates the plugin which created the event" />
		<cfset broadcast("stateChange",arguments.plugin) />
		<cfset resetApplication() />
	</cffunction>
	
	<cffunction name="isPluginArchive" access="public" output="false" returntype="boolean"
	hint="indicates if a specified zip file is a valid plugin archive">
		<cfargument name="archive" type="any" required="true">
		<cfargument name="domain" type="string" required="false" default="plugins">
		
		<cftry>
			<cfif isSimpleValue(archive)>
				<cfset archive = CreateObject("component","cfc.file").init(file=archive, domain=domain, type="zip") />
			</cfif>
			
			<cfset archive = archive.read()>
			
			<cfloop query="archive">
				<cfif archive.type is "file" and 
				refindnocase("^\w+[\\/]plugin\.cfc$",archive.name)><cfreturn true></cfif>
			</cfloop>
			
			<cfcatch></cfcatch>
		</cftry>
		
		<cfreturn false>
	</cffunction>
	
	<cffunction name="throwArchiveError" access="private" output="false" returntype="void">
		<cfthrow type="onTap.PluginManager.InvalidArchive" message="plugin.cfc not found in archive" 
		detail="The specified file is does not exist, is not a valid zip-formatted archive, or is not a valid onTap framework plugin">
	</cffunction>
	
	<cffunction name="importPluginArchive" access="public" output="false" returntype="void">
		<cfargument name="archive" type="any" required="true">
		<cfargument name="delete" type="boolean" required="false" default="true">
		
		<cfif not isPluginArchive(archive)><cfset throwArchiveError()></cfif>
		<cfset archive.extract("source/","","plugins")>
		<cfif arguments.delete><cfset archive.delete()></cfif>
	</cffunction>
	
	<cffunction name="uploadPluginArchive" access="public" output="false" returntype="void">
		<cfargument name="filefield" type="string" required="true">
		<cfargument name="directory" type="string" required="false" default="">
		<cfargument name="domain" type="string" required="false" default="plugins">
		
		<cfset var archive = CreateObject("component","cfc.file").init(directory,domain,"zip")>
		<cfset var upload = archive.upload(arguments.filefield,"makeunique")>
		
		<cfif upload.clientfileext is not "zip">
			<cfset archive.delete() />
			<cfset throwArchiveError() />
		</cfif>
		
		<cfif not isPluginArchive(archive)>
			<cfset archive.delete() />
			<cfset throwArchiveError() />
		</cfif>
		
		<cfset importPluginArchive(archive,true)>
	</cffunction>
</cfcomponent>
