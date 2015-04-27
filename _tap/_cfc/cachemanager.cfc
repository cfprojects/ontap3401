<cfcomponent displayname="cachemanager" output="false" 
hint="I integrate the onTap framework with the new CacheBox cache management framework">
	
	<cfset variables.instance = structNew() />
	<cfset instance.agent = structNew() />
	
	<cffunction name="init" access="public" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="store" access="public" output="false" hint="I store a value in the cache">
		<cfargument name="cachename" type="string" required="true" />
		<cfargument name="content" type="any" required="true" />
		<cfargument name="cachedwithin" type="string" required="false" default="" />
		<cfargument name="datepart" type="string" required="false" default="n" />
		<cfset var result = getScope(cachename) />
		<cfset var agent = getAgent(result.agentname,result.scope) />
		<cfreturn agent.store(result.cachename,arguments.content,getTimespan(arguments.cachedwithin,arguments.datepart)) />
	</cffunction>
	
	<cffunction name="fetch" access="public" output="false" hint="retrieves a value from the cache">
		<cfargument name="cachename" type="string" required="true" />
		<cfargument name="cachedafter" type="string" required="false" default="" />
		<cfset var result = getScope(cachename) />
		<cfset var agent = getAgent(result.agentname,result.scope) />
		<cfreturn agent.fetch(result.cachename,arguments.cachedafter) />
	</cffunction>
	
	<cffunction name="delete" access="public" output="false" hint="removes content from the cache">
		<cfargument name="cachename" type="string" required="true" />
		<cfset var result = getScope(cachename) />
		<cfset var agent = getAgent(result.agentname,result.scope) />
		<cfreturn agent.delete(result.cachename) />
	</cffunction>
	
	<cffunction name="expire" access="public" output="false" hint="marks cache content for later removal">
		<cfargument name="cachename" type="string" required="true" />
		<cfset var result = getScope(cachename) />
		<cfset var agent = getAgent(result.agentname,result.scope) />
		<cfreturn agent.expire(result.cachename) />
	</cffunction>
	
	<cffunction name="getTimespan" access="public" output="false" 
	hint="returns a timespan value from a number and a datepart string">
		<cfargument name="cachedwithin" type="string" required="true" />
		<cfargument name="datepart" type="string" required="false" default="N" />
		<cfset var dpart = structNew() />
		
		<!--- there is no timespan if there isn't a positive cachedwithin number --->
		<cfif val(cachedwithin) lt 1><cfreturn 0 /></cfif>
		
		<cfset dpart.d = 0 />
		<cfset dpart.h = 0 />
		<cfset dpart.n = 0 />
		<cfset dpart.s = 0 />
		
		<cfset dpart[arguments.datepart] = arguments.cachedwithin />
		<cfreturn CreateTimespan(dpart.d,dpart.h,dpart.n,dpart.s) />
	</cffunction>
	
	<cffunction name="getAgent" access="public" output="false" 
	hint="returns a CacheBox agent with a specified scope and name">
		<cfargument name="agentname" type="string" required="true" />
		<cfargument name="scope" type="string" required="false" default="application" />
		<cfargument name="evict" type="string" required="false" default="auto" />
		<cfset var key = scope & "_" & agentname />
		<cfset var agent = 0 />
		
		<cfif not structKeyExists(instance.agent,key)>
			<cfset agent = CreateObject("component","cacheboxagent").init(agentname,scope,evict) />
			<cfset instance.agent[key] = CreateObject("component","cacheboxnanny").init(agent) />
		</cfif>
		
		<cfreturn instance.agent[key] />
	</cffunction>
	
	<cffunction name="getScope" access="private" output="false" returntype="struct"
	hint="returns the scope ane name of an agent from a cachename">
		<cfargument name="cachename" type="string" required="true" />
		<cfset var result = structNew() />
		<cfset result.scope = listfirst(cachename,".") />
		
		<cfswitch expression="#result.scope#">
			<cfcase value="application,server,cluster">
				<cfset result.cachename = listrest(arguments.cachename,".") />
				<cfset result.agentname = listfirst(result.cachename,".") />
				<cfset result.cachename = listrest(arguments.cachename,".") />				
			</cfcase>
			<cfcase value="session">
				<cfset result.scope = "application" />
				<cfset result.agentname = "session" />
				<cfset result.cachename = rereplace(cachename,"^session.",session.sessionid & ".") />
			</cfcase>
			<cfdefaultcase>
				<cfset result.scope = "application" />
				<cfset result.agentname = listfirst(arguments.cachename,".") />
				<cfset result.cachename = listrest(arguments.cachename,".") />
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn result />
	</cffunction>
	
</cfcomponent>
