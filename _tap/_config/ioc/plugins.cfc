<cfcomponent extends="config" hint="configure the plugin manager as an IoC Container">
	
	<cffunction name="configure" access="public" output="false" returntype="void">
		<cfset newContainer("plugins","cfc.pluginmanager").init() />
	</cffunction>
	
</cfcomponent>