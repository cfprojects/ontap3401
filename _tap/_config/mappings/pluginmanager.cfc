<cfcomponent extends="config">
	<cffunction name="configure" access="public" output="false" returntype="void">
		
		<cfset addMapping("plugins",getFilePath("admin/plugins/source","P"),true) />
		
	</cffunction>
</cfcomponent>
