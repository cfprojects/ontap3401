<!--- this is a mixin for generic framework functions --->
<cffunction name="getTap" access="public" output="false" hint="gives the component access to the framework configuration component">
	<cfreturn request.tap />
</cffunction>

<cffunction name="getLib" access="public" output="false" hint="gives the component access to the framework libraries">
	<cfreturn request.tapi />
</cffunction>

<cffunction name="getFS" access="public" output="false" hint="gives the component access to the framework file-system utilities">
	<cfreturn request.fs />
</cffunction>

<cffunction name="getIoC" access="public" output="false" hint="gives the component access to the framework IoC Manager">
	<cfargument name="container" type="string" required="false" default="" hint="a specific IoC Container name" />
	<cfreturn getTap().getIoC(container) />
</cffunction>

<cffunction name="arg" access="public" output="false" returntype="any">
	<cfargument name="args" type="any" required="true">
	<cfargument name="item" type="any" required="true">
	<cfargument name="def" type="any" required="true">
	
	<cfif IsArray(args) and arraylen(args) gte item><cfreturn args[item]>
	<cfelseif isXMLElem(args) and structkeyexists(args,item)><cfreturn args[item]>
	<cfelseif IsStruct(args) and structkeyexists(args,item)><cfreturn args[item]>
	<cfelseif isObject(args) and not isnumeric(left(item,1)) 
			and not refindnocase("[^_[:alnum:]]",item) 
			and isdefined("args.#item#")><cfreturn evaluate("args.#item#")>
	<cfelse><cfreturn def></cfif>
</cffunction>
