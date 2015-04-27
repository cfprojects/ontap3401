<!--- *** DO NOT MODIFY THIS FILE *** --->
<cfcomponent hint="your mapping components should extend this class">
	<cfset variables.dependencies = ArrayNew(1) />
	<!--- 
		if this component depents on another mapping, you can specify that here, 
		using the method loadAfter("nameOfMappingComponent") 
		- you can specify multiple loadAfter() statements if you need more than one config to load first 
		
		EXAMPLE: load these mappings after "othermappings.cfc" 
		<cfset loadAfter("othermappings") />
		
		NOTE! Mappings can not be *used* yet when these components are configured 
		- to use one, you must reference and apply it manually using getMapping() 
		EXAMPLE: addMapping("x",getMapping("y") & "../other/path"); 
	--->
	
	<cffunction name="configure" access="public" output="false" returntype="void" hint="set path and url aliases in this method">
		<!--- here are some examples of how to configure mappings and custom tags 
			<cfscript>
				addMapping("datafaucet","../datafaucet/"); 
				
				// add custom tags in an absolute directory 
				addCustomTags("c:\my\tags\"); 
				
				// add custom tags relative to the application root 
				addCustomTags(getFilePath("/../my/tags")); 
				
				// add custom tags relative to the framework custom tags directory 
				addCustomTags(getFilePath("/my/other/tags","CT")); 
				
				NOTE: you do NOT need to call super.configure() 
			</cfscript>
		--->
		
		<cfscript>
			addMapping("tap",getFilePath(""),true); 
			addMapping("inc",getFilePath("_includes","P"),true); 
			addMapping("brand",getFilePath("_brand","P"),true); 
			addMapping("lib",getFilePath("","LIB"),true); 
			addMapping("cfc",getFilePath("","CFC"),true); 
			addMapping("tags",getFilePath("","CT"),true); 
			addMapping("style",getFilePath("_styles","P"),true); 
			addCustomTags(getFilePath("","CT")); 
			addCustomTags(getFilePath("local","CT")); 
		</cfscript>
	</cffunction>
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="tap" type="any" required="true" />
		<cfset variables.tap = arguments.tap />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="loadAfter" access="private" output="false">
		<cfargument name="settings" type="string" required="true" />
		<cfset arrayAppend(variables.dependencies,arguments.settings) />
	</cffunction>
	
	<cffunction name="canLoad" access="public" output="false">
		<cfargument name="isLoaded" type="string" required="true" />
		<cfset var comp = "" />
		
		<cfloop index="comp" list="#ArrayToList(variables.dependencies)#">
			<cfif not listfindnocase(arguments.isloaded,comp)>
				<cfreturn false />
			</cfif>
		</cfloop>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="addMapping" access="private" output="false" hint="adds a ColdFusion server mapping">
		<cfargument name="name" type="string" required="true" hint="value used in cfinclude tags" />
		<cfargument name="directory" type="string" required="true" hint="absolute path to the mapped directory" />
		<cfargument name="critical" type="boolean" required="false" default="false" hint="indicates if the created mapping is required for the framework to function" />
		<cfset getTap().addMapping(rereplace(name,"^/",""),directory,critical) />
	</cffunction>
	
	<cffunction name="getMapping" access="private" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfreturn getCF().getMapping(name) />
	</cffunction>
	
	<cffunction name="addCustomTags" access="public" output="false"
	hint="adds a directory to the custom tag paths for the current request 
	- allows tag paths to be set relative to the application root directory">
		<cfargument name="directory" type="string" required="true" />
		<cfset getTap().addCustomTags(directory) />
	</cffunction>
	
	<cffunction name="getTap" access="private" output="false">
		<cfreturn variables.tap />
	</cffunction>
	
	<cffunction name="getPath" access="private" output="false">
		<cfreturn getTap().getPath() />
	</cffunction>
	
	<cffunction name="getFilePath" access="private" output="false">
		<cfargument name="path" type="string" required="true" default="" />
		<cfargument name="domain" type="string" required="false" default="T" />
		<cfreturn getPath().getPath(path,domain,false,false) />
	</cffunction>
</cfcomponent>