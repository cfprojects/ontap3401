<cfcomponent displayname="IoC.ColdSpringAdapter" 
extends="ioccontainer" output="false" hint="An Adapter for IoC with ColdSpring">
	<!--- 
		ColdSpring is an IoC / Dependency Injection Framework developed by Dave Ross 
		for more information about ColdSpring visit the official website at: 
		http://www.coldspringframework.org/
	--->
	
	<cfset setProperty("factoryClass","coldspring.beans.DefaultXmlBeanFactory") />
	<cfset setProperty("attributeList","autowire,singleton") />
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="definitions" type="string" required="true" />
		<cfargument name="autowire" type="boolean" required="false" default="byName" />
		<cfargument name="singleton" type="boolean" required="false" default="true" />
		<cfargument name="defaultProperties" type="struct" required="false" default="#structNew()#" />
		<cfset setProperties(arguments) />
		<cfreturn this>
	</cffunction>
	
	<cffunction name="get_definitions" access="private" output="false" returntype="string">
		<cfset var path = getProperty("definitions") />
		
		<cfif left(path,1) is "/">
			<cfset path = expandpath(path) />
		</cfif>
		
		<cfreturn path />
	</cffunction>
	
	<cffunction name="get_defaultAttributes" access="private" output="false" returntype="struct">
		<cfset var st = structNew() />
		<cfset var x = 0 />
		
		<cfloop index="x" list="#getValue('attributeList')#">
			<cfset st[x] = getValue(x) />
		</cfloop>
		
		<cfreturn st />
	</cffunction>
	
	<cffunction name="createFactory" access="private" output="false" 
	returntype="any" hint="creates the coldspring factory and configures it">
		<cfset var attributes = getValue("defaultAttributes") />
		<cfset var properties = getValue("defaultProperties") />
		<cfset var factory = createObject("component",getValue("factoryClass")).init(attributes,properties) />
		<cfset factory.loadBeansFromXmlFile(getValue("definitions")) />
		<cfreturn factory />
	</cffunction>

</cfcomponent>