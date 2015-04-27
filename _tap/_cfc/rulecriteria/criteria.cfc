<cfcomponent displayname="ruleCriteria.Criteria" extends="cfc.ontap" output="false" 
hint="this is an abstract component intended to provide a blueprint for derived classes 
-- many of the methods in this class may produce errors if this class is intantiated directly">
	<cfproperty name="hasForm" type="boolean" default="true" hint="indicates if the getForm() method is implemented for the current criteria type">
	
	<cfset setProperty("hasForm",true)>
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="ruleManager" type="any" required="false" default="">
		
		<cfif not isSimpleValue(arguments.ruleManager)>
		<cfset variables.ruleManager = arguments.ruleManager></cfif>
		
		<cfset configure() />
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="configure" access="private" output="false">
	</cffunction>
	
	<!--- **********************************************************************************************
	REQUIRED METHODS : The following "interface" methods must be implemented in all descendants of RuleCriteria 
	************************************************************************************************--->
	
	<cffunction name="test" returntype="string" access="public" output="false" 
	hint="examines and evaluates xml meta data for an individual rule criterion - valid return values are true|false|or">
		<cfargument name="criteriaNode" required="true">
		<cfargument name="ruleContext" required="true">
		
		<cfthrow type="ontap.component.methodNotImplemented" message="onTap: Method Not Implemented" 
		detail="the test() method was not implemented in a descendant of the RuleCriteria class">
	</cffunction>
	
	<cffunction name="getXML" returntype="string" access="public" output="false" 
	hint="returns the appropriate XML node syntax when provided with form variables to build a new criteria node">
		<cfargument name="data" required="true" type="struct">
		
		<cfthrow type="ontap.component.methodNotImplemented" message="onTap: Method Not Implemented" 
		detail="the getXML() method was not implemented in a descendant of the RuleCriteria class">
	</cffunction>
	
	<cffunction name="getForm" returntype="struct" access="public" output="false" 
	hint="returns an html element structure containing a form to generate a rule criteria of the indicated type">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="numeric" required="true">
		<cfargument name="formdata" type="struct" required="true">
		<cfargument name="ruleContext" type="any" required="false" default="" 
			hint="a context object from which descriptive elements may be returned">
		<cfargument name="locale" type="string" required="false" default="">

		<cfthrow type="ontap.component.methodNotImplemented" message="onTap: Method Not Implemented" 
		detail="the getForm() method was not implemented in a descendant of the RuleCriteria class">
	</cffunction>
	
	<cffunction name="describe" returntype="string" access="public" output="false"
	hint="provides a means to generate localized descriptions of specific rule criteria">
		<cfargument name="ruleid" type="string" required="true" default="">
		<cfargument name="criteria" type="numeric" required="true" default="0">
		<cfargument name="ruleContext" type="any" required="false" default="" 
			hint="a context object from which descriptive elements may be returned">
		<cfargument name="locale" type="string" required="false" default="">

		<cfthrow type="ontap.component.methodNotImplemented" message="onTap: Method Not Implemented" 
		detail="the describe() method was not implemented in a descendant of the RuleCriteria class">
	</cffunction>
	
	<!--- **********************************************************************************************
	INHERITABLE METHODS : The following methods may be inherited from the RuleCriteria class 
	************************************************************************************************ --->
	
	<cffunction name="getTypeName" returntype="string" access="public" output="false" 
	hint="returns the localized name of the instantiated criteria type">
		<cfargument name="locale" type="string" required="false" default="">
		<cfreturn getResourceBundle(locale).name>
	</cffunction>
	
	<cffunction name="getContextProperties" access="private" returntype="query" output="false" 
	hint="returns a collection of available properties of a specified type from the provided rule-context">
		<cfargument name="propertyType" required="true" type="string">
		<cfargument name="ruleContext" required="true">
		<cfargument name="locale" type="string" required="false" default="">
		<cfset var qry = "">
		
		<cfif isCustomFunction(arg(ruleContext,"getPropertyQuery",""))>
			<cfset qry = ruleContext.getPropertyQuery(PropertyType,locale)>
		<cfelseif isCustomFunction(arg(ruleContext,"getValue",""))>
			<cfset qry = ruleContext.getValue(PropertyType & "RuleProperties")>
		
			<cfif isQuery(qry)>
				<cfset qry = duplicate(qry)>
				<cfloop query="qry">
					<cfset qry.inputlabel = getLib().ls(qry.inputlabel)>
				</cfloop>
			<cfelse>
				<cfset qry = QueryNew("inputvalue,inputlabel")>
			</cfif>
		</cfif>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getContextPropertiesXML" access="private" returntype="string" output="false" 
	hint="converts a context properties query into an xml string for use in xsl transformations">
		<cfargument name="propertyType" type="string" required="true">
		<cfargument name="ruleContext" required="true">
		<cfargument name="select" type="string" required="false" default="#propertyType#">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset var xml = "">
		<cfset var qry = getContextProperties(propertyType,ruleContext,locale)>
		
		<cfsavecontent variable="xml"><cfoutput>
			<xsl:choose><cfloop query="qry">
				<xsl:when test="translate(#select#,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#lcase(xmlformat(qry.inputvalue))#'">#xmlformat(getLib().ls(qry.inputlabel))#</xsl:when></cfloop>
			</xsl:choose>
		</cfoutput></cfsavecontent>
		
		<cfreturn xml>
	</cffunction>
	
	<cffunction name="contextHasProperties" access="private" returntype="boolean" output="false"
	hint="this function tells the rulecriteria component if a collection of properties (query) 
	needed for criteria applicability are available from the ruleContext to which rules are being applied">
		<cfargument name="propertyType" required="true" type="string">
		<cfargument name="ruleContext" required="true">
		
		<cfreturn yesnoformat(getContextProperties(propertyType,ruleContext).recordcount)>
	</cffunction>
	
	<cffunction name="contextHasRequiredProperties" returntype="boolean" access="public" output="false"
	hint="this method allows some rule criteria types to appear as options conditionally when managing rules">
		<cfargument name="ruleContext" type="any" required="false" default="">
		
		<cfset var x = 0>
		<cfset var ptype = this.getValue("requiredContextProperties")>
		
		<cfif not isCustomFunction(arg(ruleContext,"getValue",""))><cfreturn false></cfif>
		
		<cfif issimplevalue(ptype) and not len(trim(ptype))><cfreturn true>
		<cfelseif issimplevalue(ptype)><cfset ptype = listtoarray(ptype)></cfif>
		
		<cfloop index="x" from="1" to="#arraylen(ptype)#">
			<cfif not contextHasProperties(pType[x],ruleContext)><cfreturn false></cfif>
		</cfloop><cfreturn true>
	</cffunction>
	
	<cffunction name="appliesToContext" returntype="boolean" access="public" output="false"
	hint="this method allows some rule criteria types to appear as options conditionally when managing rules">
		<cfargument name="ruleContext" type="any" required="false" default="">
		
		<cfreturn contextHasRequiredProperties(ruleContext)>
	</cffunction>
	
	<cffunction name="getSupportedLanguages" access="private" output="false" returntype="string">
		<cfreturn getTap().getLocal().supportedLanguages>
	</cffunction>
	
	<cffunction name="jLocale" access="private" output="false">
		<cfargument name="locale" type="any" required="true">
		<cfreturn getTap().getLocal().jLocale(locale)>
	</cffunction>
	
	<cffunction name="getResourceBundle" returntype="struct" access="public" output="false"
	hint="returns the language resource bundle for the current locale and criteria type">
		<cfargument name="locale" type="string" required="false" default="" 
			hint="allows resource bundles for the criteria type to be loaded for locales other than the default locale of the current request">
		<cfargument name="lenient" type="string" required="false" default="true" 
			hint="when true the function will attempt to get a resource bundle for any supported language if a bundle is not found for the current locale">
		
		<cfset var bundle = structnew() />
		<cfset var classpath = this.getValue("classpath") />
		<cfset var my = structnew() />
		<cfset var aLocale = "" />
		<cfset var x = 0 />
		
		<cfset locale = lcase(jLocale(locale).toString())>
		<cfset aLocale = listtoarray(locale,"_")>
		<cfparam name="variables.resourcebundle" type="struct" default="#structnew()#">
		
		<cfif not structKeyExists(variables.resourcebundle,locale)>
			<cfloop index="x" from="1" to="#arraylen(aLocale)#">
				<cfif x gt 1><cfset aLocale[x] = listAppend(aLocale[x-1],aLocale[x],"_")></cfif>
				<cfset my.filepath = "rulemanager/#replace(classpath,'.','-','ALL')#-#aLocale[x]#.cfm">
				<cfif fileexists(getFS().getPath(my.filepath,"inc"))>
				<cfset structAppend(bundle,getFS().fileRead(my.filepath,"inc","resourcebundle"),true)></cfif>
			</cfloop>
			
			<cfif lenient and structIsEmpty(bundle)>
				<!--- if a resourcebundle could not be found for the current locale, attempt to get a resource bundle for any supported language --->
				<cfloop index="x" list="#getSupportedLanguages()#">
					<cfset bundle = getResourceBundle(x,false)>
					<cfif not structIsEmpty(bundle)><cfbreak></cfif>
				</cfloop>
			</cfif>
			
			<!--- don't cache an empty bundle --->
			<cfif not structisempty(bundle)>
				<cfset variables.resourcebundle[locale] = bundle>
			</cfif>
		<cfelse>
			<cfset bundle = variables.resourcebundle[locale]>
		</cfif>
		
		<cfparam name="bundle.name" type="string" default="">
		
		<cfreturn bundle>
	</cffunction>
	
	<cffunction name="ls" returntype="string" access="public" output="false" 
	hint="returns the locale-specific string identifier for a specified label belonging to the current criteria object">
		<cfargument name="label" type="string" required="true">
		<cfargument name="locale" type="string" required="false" default="">
		<cfset var my = getResourceBundle(locale)>
		<cfreturn my[label]>
	</cffunction>
	
</cfcomponent>

