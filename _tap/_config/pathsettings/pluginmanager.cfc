<cfcomponent extends="config">

	<cffunction name="configure" access="public" output="false">
		<cfset var plugins = "admin/plugins/" />
		<cfset setPathAlias("plugins",getFilePath(plugins,"P"),"path to plugin manager directory") />
		<cfset setURLAlias("plugins",getURL(plugins,"T"),"url to plugin manager application") />
	</cffunction>
</cfcomponent>
