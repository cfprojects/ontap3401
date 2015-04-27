<!--- *** DO NOT MODIFY THIS FILE *** --->
<cfcomponent extends="cfc.config" hint="your event configs should extend this class">
	<!--- 
		if this component depents on another configuration, 
		you can specify that here, using the method loadAfter("nameOfConfig") 
		- you can specify multiple loadAfter() statements if you need more than one config to load first 
		
		EXAMPLE: load these configs after "OtherEventConfig.cfc" 
		<cfset loadAfter("OtherEventConfig") />
	--->
	
	<cffunction name="configure" access="public" output="false" returntype="void" hint="execute event code in this method">
		<!--- perform any activities necessary for the application event such as configuring or cleaning up services 
			<cfset getContainer("MyAppName").getBean("MyAppManager").cleanUpSession(getSession()) />
		--->
	</cffunction>
	
</cfcomponent>