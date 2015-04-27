<cfcomponent displayname="IoC.LightWireAdapter" 
extends="ioccontainer" output="false" hint="An adapter for IoC with Lightwire">
	<!--- 
		LightWire is an IoC / Dependency Injection Framework developed by Pete Bell 
		For more information about LightWire, visit Pete's Blog 
		http://www.pbell.com/index.cfm/LightWire 
	--->
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="configClass" type="string" required="true" />
		<cfargument name="lazyload" type="boolean" required="false" default="true" />
		<cfargument name="factoryClass" type="string" required="false" default="lightwire.LightWire" />
		<cfset setProperties(arguments) />
	</cffunction>
	
	<cffunction name="createFactory" access="private" output="false" 
	returntype="any" hint="creates the lightwire factory and configures it">
		<cfreturn createObject("component", getValue("factoryClass")).init(createConfig()) />
	</cffunction>
	
	<cffunction name="createConfig" output="false" access="private" 
	returntype="any" hint="creates the lightwire config object">
		<cfset var config = CreateObject("component", getValue("configPath")).init() />
		<cfset config.setLazyLoad(getValue("lazyload")) />
		<cfreturn config />
	</cffunction>

</cfcomponent>