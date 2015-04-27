<!--- *** DO NOT MODIFY THIS FILE *** --->
<cfcomponent extends="cfc.config" hint="your path components should extend this class">
	<!--- 
		if this component depents on another pathconfig, you can specify that here, 
		using the method loadAfter("nameOfPathSettingsComponent") 
		- you can specify multiple loadAfter() statements if you need more than one config to load first 
		
		EXAMPLE: load these path settings after the docs path settings 
		<cfset loadAfter("docs") />
	--->
	
	<cffunction name="configure" access="public" output="false" returntype="void" hint="set path and url aliases in this method">
		<!--- here are some examples of how to configure path and url aliases 
			<cfscript>
				// set absolute paths 
				setPathAlias("myfiles","c:\my\other\directory","these are my files for doing x"); 
				setURLAlias("members","http://mysite.com/members/","this is the member home page"); 
				
				// HOWEVER the above is rather primitive and doesn't offer the advantage of making 
				// paths or URLs relative to paths or URLs already known to the application 
				
				// relative to the application root directory - "front end" 
				setPathAlias("myfiles",getFilePath("my/other/directory"),"these are my files for doing x"); 
				setURLAlias("members",getURL("members/"),"this is the member home page"); 
				
				// relative to the application code directory - "back end" 
				setPathAlias("myfiles",getFilePath("my/other/directory","P"),"these are my files for doing x"); 
				setURLAlias("myCSS",getURL("SiteStyle","P"),"these are my style sheets"); 
			</cfscript>
			
			NOTE: you do NOT need to call super.configure() 
		--->
		
		<cfset setPathAlias("docs",getFilePath("docs/index","P"),"path to the framework documentation site") />
		<cfset setURLAlias("docs",getURL("/docs/index.cfm?"),"framework documentation site") />
		
	</cffunction>
	
	<cffunction name="getHREF" access="private" output="false">
		<cfreturn getTap().getHREF() />
	</cffunction>
	
	<cffunction name="getURL" access="private" output="false">
		<cfargument name="path" type="string" required="true" default="" />
		<cfargument name="domain" type="string" required="false" default="T" />
		<cfargument name="protocol" type="string" required="false" default="" hint="http:// or https:// or telnet:// etc." />
		<cfreturn getHREF().getURL(argumentCollection=arguments) />
	</cffunction>
	
	<cffunction name="setPathAlias" access="private" output="false" hint="sets a file-path alias for directory management">
		<cfargument name="alias" type="string" required="true" hint="name of the path alias" />
		<cfargument name="path" type="string" required="true" hint="absolute file path" />
		<cfargument name="description" type="string" required="false" default="" hint="optional description of the directory" />
		<cfset getPath().setAlias(alias,path,description) />
	</cffunction>
	
	<cffunction name="setURLAlias" access="private" output="false" hint="sets a URL alias for link-management">
		<cfargument name="alias" type="string" required="true" hint="name of the URL alias" />
		<cfargument name="path" type="string" required="true" hint="absolute URL" />
		<cfargument name="description" type="string" required="false" default="" hint="optional description of the URL" />
		<cfset getHREF().setAlias(alias,path,description) />
	</cffunction>
	
</cfcomponent>
