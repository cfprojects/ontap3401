<cfcomponent displayname="IoC.IoCContainer" 
extends="cfc.ontap" output="false" hint="A generic IoC container">
	<cfset variables.lockname = "tap.ioc.container." & getTickCount() & "." & randrange(0,999999) />
	<cfset variables.factory = "" />
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="factoryClass" type="string" required="true" />
		<cfargument name="CacheAgentName" type="string" required="false" default="" />
		<cfargument name="CacheContext" type="string" required="false" default="application" />
		<cfargument name="cascade" type="string" required="false" default="tap" />
		<cfargument name="package" type="string" required="false" default="" />
		<cfargument name="CacheEvict" type="string" required="false" default="none" />
		<cfset setProperties(arguments) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getBean" access="public" output="false" returntype="any">
		<cfargument name="beanName" type="string" required="true" />
		<cfreturn getFactory().getBean(beanName) />
	</cffunction>
	
	<cffunction name="containsBean" access="public" output="false" returntype="any">
		<cfargument name="beanName" type="string" required="true" />
		<cfreturn getFactory().containsBean(beanName) />
	</cffunction>
	
	<cffunction name="reset" access="public" output="false" hint="reloads the factory configuration">
		<cfset var fact = variables.factory />
		
		<cflock name="#variables.lockname#" type="exclusive" timeout="10">
			<cfset variables.factory = "" />
		</cflock>
		
		<!--- we're throwing away a factory, so if it has a detach method, lets call it to clean up any cache, etc. --->
		<cfif isObject(fact) and structKeyExists(fact,"detach")>
			<cfset fact.detach() />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getFactory" access="public" output="false">
		<cflock name="#variables.lockname#" type="exclusive" timeout="10">
			<cfif isSimpleValue(variables.factory)>
				<cfset variables.factory = createFactory() />
			</cfif>
			<cfreturn variables.factory />
		</cflock>
	</cffunction>
	
	<cffunction name="createFactory" access="private" output="false" 
	returntype="any" hint="creates the factory object and configures it">
		<cfset var agent = "" />
		<cfset var agentname = getValue("cacheagentname") />
		
		<cfif len(trim(agentname))>
			<!--- we got a name for the cachebox agent, so we'll use a cachebox agent for storage --->
			<cfset agent = CreateObject("component","cfc.cacheboxagent").init(agentname,getValue("cachecontext"),getValue("CacheEvict")) />
		<cfelse>
			<!--- no cachebox agent name provided, so we'll default to using a simplestorage object --->
			<cfset agent = CreateObject("component","cfc.simplestorage").init() />
		</cfif>
		
		<cfreturn createObject("component", getValue("factoryClass")).init(agent,getValue("cascade"),getValue("package")) />
	</cffunction>
</cfcomponent>