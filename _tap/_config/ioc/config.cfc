<!--- *** DO NOT MODIFY THIS FILE *** --->
<cfcomponent extends="cfc.config" hint="your IoC configs should extend this class">
	<!--- 
		if this component depents on another configuration, 
		you can specify that here, using the method loadAfter("nameOfConfig") 
		- you can specify multiple loadAfter() statements if you need more than one config to load first 
		
		EXAMPLE: load these configs after "otherconfigs.cfc" 
		<cfset loadAfter("OtherIoCConfig") />
	--->
	
	<cffunction name="configure" access="public" output="false" returntype="void" hint="attach IoC containers to the manager here">
		<!--- create new IoC Containters and attach them to the IoC Manager like this 
			<cfset newContainer("MyAppName","coldspringadapter").init("/path/to/definitions.xml") />
			<cfset newContainer("OtherAppName","lightwireadapter").init("path.to.config.component") />
			
			- OR - if you want to create the container / adapter manually before adding it to the manager 
			<cfset var adapter = CreateObject("component","my.ioc.adapter").init(args) />
			<cfset addContainer("MyAppName",adapter) />
		--->
	</cffunction>
	
	<cffunction name="getContainer" access="public" output="false" returntype="any">
		<cfargument name="name" type="string" required="false" default="" />
		<cfreturn iif(len(trim(name)), "getIoC().getContainer(arguments.name)", "getIoC().getContainer()") />
	</cffunction>
	
	<cffunction name="newContainer" access="private" output="false" returntype="any" 
	hint="creates a new IoC Container / Adapter for you to configure pre-attached to the manager">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="className" type="string" required="false" default="ioccontainer" />
		<cfreturn getIoC().newContainer(name,className) />
	</cffunction>
	
	<cffunction name="addContainer" access="public" output="false" 
	hint="adds a configured IoC Container / Adapter to the manager">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="container" type="any" required="true" />
		<cfset getIoC().addContainer(name,container) />
	</cffunction>
	
</cfcomponent>