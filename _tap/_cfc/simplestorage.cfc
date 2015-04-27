<cfcomponent displayname="SimpleStorage" output="false" 
hint="implements a generic storage pool for object-instantiation / caching services - this is a simpler alternative to the CacheBoxAgent component">
	<cfset variables.lockname = CreateUUID() />
	<cfset variables.storage = structnew() />
	
	<cffunction name="init" access="public" output="false">
		<cfset structAppend(variables,arguments,true) />
		<cfset reset() />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="hasObject" returntype="boolean" access="private" output="false" hint="indicates if a specified object has been stored">
		<cfargument name="cachename" type="string" required="true" />
		<cfreturn structkeyexists(variables.storage,arguments.cachename) />
	</cffunction>
	
	<cffunction name="fetch" access="public" output="false" returntype="struct" hint="retreives an object from storage - returns a struct with content and a status indicator">
		<cfargument name="cachename" type="string" required="true" />
		<cfset var result = structNew() />
		<cfset result.status = 0 />
		
		<cflock name="#variables.lockname#" type="readonly" timeout="10">
			<cftry>
				<cfset result.content = structFind(variables.storage,arguments.cachename) />
				<cfcatch>
					<!--- status 1 indicates that content was not found in storage --->
					<cfset result.content = "" />
					<cfset result.status = 1 />
				</cfcatch>
			</cftry>
		</cflock>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="delete" access="public" output="false" hint="removes a single object from storage">
		<cfargument name="cachename" type="string" required="true" />
		<cflock name="#variables.lockName#" type="exclusive" timeout="10">
			<cfset structDelete(variables.storage,arguments.cachename) />
		</cflock>
	</cffunction>
	
	<cffunction name="expire" access="public" output="false" hint="removes a single object from storage">
		<cfargument name="cachename" type="string" required="false" default="%" />
		<cfif cachename is "%">
			<cfset reset() />
		<cfelse>
			<cfset delete(cachename) />
		</cfif>
	</cffunction>
	
	<cffunction name="store" access="public" output="false" returntype="struct" hint="stores an object locally - returns a struct with stored content and a status indicator">
		<cfargument name="cachename" type="string" required="true" />
		<cfargument name="content" type="any" required="true" />
		<cfset var result = structNew() />
		
		<cflock name="#variables.lockname#" type="exclusive" timeout="10">
			<cfif not isSimpleValue(arguments.content) and hasObject(arguments.cachename)>
				<!--- this lets us use this storage object for singletons 
				-- the object returned from the store() method is always the first one in --->
				<cfset result.content = variables.storage[arguments.cachename] />
				<!--- status 2 indicates the dogpile condition --->
				<cfset result.status = 2 />
			<cfelse>
				<cfset result.content = arguments.content />
				<cfset variables.storage[arguments.cachename] = arguments.content />
			</cfif>
		</cflock>
		
		<cfreturn arguments />
	</cffunction>
	
	<cffunction name="reset" access="public" output="false" hint="clears storage">
		<cflock name="#variables.lockname#" type="exclusive" timeout="10">
			<cfset structClear(variables.storage) />
		</cflock>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="debug" access="public" output="true" hint="dumps storage to output">
		<cfdump var="#variables.storage#" />
	</cffunction>
	
</cfcomponent>

