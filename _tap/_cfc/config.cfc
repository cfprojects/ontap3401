<cfcomponent displayname="config" output="false" hint="an abstract framework configuration class">
	<cfset variables.dependencies = ArrayNew(1) />
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="tap" type="any" required="true" />
		<cfargument name="sessionScope" type="struct" required="false" default="#structNew()#" />
		<cfargument name="applicationScope" type="struct" required="false" default="#structNew()#" />
		<cfset structAppend(variables,arguments,true) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" output="false" 
	hint="this is where actual configuration should occur">
	</cffunction>
	
	<cffunction name="loadAfter" access="private" output="false" 
	hint="allows the config object to specify dependency on other configs in the same directory - an alternative to numbered files">
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
	
	<cffunction name="getTap" access="private" output="false">
		<cfreturn variables.tap />
	</cffunction>
	
	<cffunction name="getIoC" access="private" output="false">
		<cfargument name="container" type="string" required="false" default="" hint="a specific IoC Container name" />
		<cfreturn getTap().getIoC(container) />
	</cffunction>
	
	<cffunction name="getContainer" access="public" output="false" returntype="any">
		<cfargument name="name" type="string" required="true" />
		<cfreturn getIoC().getContainer(arguments.name) />
	</cffunction>
	
	<cffunction name="getPath" access="private" output="false">
		<cfreturn getTap().getPath() />
	</cffunction>

	<cffunction name="getFilePath" access="private" output="false">
		<cfargument name="path" type="string" required="true" default="" />
		<cfargument name="domain" type="string" required="false" default="T" />
		<cfreturn getPath().getPath(path,domain,false,false) />
	</cffunction>
	
	<cffunction name="getApplication" access="private" output="false" hint="returns a pointer to the application scope">
		<cfreturn iif(isDefined("application"),"application","variables.applicationScope")>
	</cffunction>
	
	<cffunction name="getSession" access="private" output="false" hint="returns a pointer to the session scope">
		<cfreturn iif(isDefined("session"),"session","variables.sessionScope")>
	</cffunction>
	
</cfcomponent>