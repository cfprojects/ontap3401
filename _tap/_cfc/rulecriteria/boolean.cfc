<cfcomponent displayname="ruleCriteria.Boolean" output="false" extends="criteria">
	
	<cfset setProperty("requiredContextProperties","Boolean")>
	
	<cffunction name="test" returntype="boolean" access="public" output="false">
		<cfargument name="criteria" required="true">
		<cfargument name="ruleContext" required="true">
		
		<cfset var isTrue = criteria.xmlattributes.isTrue>
		<cfset var aProperty = XMLSearch(criteria,"./property")>
		<cfset var x = 0>
		
		<cfloop index="x" from="1" to="#ArrayLen(aProperty)#">
			<cfset aProperty[x] = ruleContext.getValue(aProperty[x].xmlAttributes.name)>
			<cfif not isBoolean(aProperty[x])><cfreturn false></cfif>
			<cfif aProperty[x] xor isTrue><cfreturn false></cfif>
		</cfloop>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getXML" returntype="string" access="public" output="false">
		<cfargument name="data" type="struct" required="true">
		<cfset var xml = "">
		<cfset var property = "">
		
		<cfsavecontent variable="xml"><cfoutput>
			<criteria type="#this.getValue('classPath')#" istrue="#iif(data.istrue,true,false)#">
				<cfloop index="property" list="#data.property#">
				<property name="#xmlformat(property)#" /></cfloop>
			</criteria>
		</cfoutput></cfsavecontent>
		
		<cfreturn xml>
	</cffunction>
	
	<cffunction name="getFormXML" returntype="string" access="private" output="false">
		<cfargument name="size" type="boolean" default="true">
		<cfargument name="locale" type="string" required="false" default="">
		<cfset var temp = ""><cfset var my = structnew()>
		<cfset my.ls = getResourceBundle(locale)>
		
		<cfsavecontent variable="temp"><cfoutput>
			<tap:form xmlns:tap="xml.tapogee.com" class="rulecriteria">
				<select name="property" tap:query="propertyQuery" 
					<cfif arguments.size gt 1>multiple="true" size="#min(5,arguments.size)#"</cfif> 
					tap:required="true" label="#xmlformat(my.ls.property)#" />
				
				<input type="radio" name="istrue" tap:boolean="true" tap:required="true" 
					label="#xmlformat(my.ls.istrue)#" tap:default="true" />
			</tap:form>
		</cfoutput></cfsavecontent>
		<cfreturn temp>
	</cffunction>
	
	<cffunction name="getPropertiesList" access="private" output="false" returntype="string">
		<cfargument name="rcNode" required="true"><cfset var x = 0>
		<cfset var aProperty = XMLSearch(rcNode,"./property")>
		<cfloop index="x" from="1" to="#arraylen(aProperty)#">
		<cfset aProperty[x] = aProperty[x].xmlAttributes.name></cfloop>
		<cfreturn ArrayToList(aProperty)>
	</cffunction>
	
	<cffunction name="getForm" returntype="struct" access="public" output="false">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="numeric" required="true">
		<cfargument name="formdata" type="struct" required="true">
		<cfargument name="ruleContext" type="any" required="true">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset var my = structnew()><cfset var x = 0>
		<cfset var rcNode = variables.ruleManager.getCriteriaNode(ruleid,criteria)>
		<cfset var propertyQuery = getContextProperties("Boolean",ruleContext,locale)>
		<cfparam name="formdata.property" type="string" default="#getPropertiesList(rcNode)#">
		
		<cfset structappend(formdata,rcNode.xmlattributes,false)>
		<cfif propertyQuery.recordcount is 1>
			<cfset rcNode.xmlattributes.property = propertyQuery.inputvalue>
		</cfif>
		
		<cf_html return="my.html" skin="#this.getValue('skin')#" formdata="#formdata#">
			<cfoutput>#getFormXML(propertyQuery.recordcount)#</cfoutput>
		</cf_html>
		
		<cfreturn my.html>
	</cffunction>
	
	<cffunction name="describe" returntype="string" access="public" output="false">
		<cfargument name="ruleid" type="string" required="true" default="">
		<cfargument name="criteria" type="numeric" required="true" default="0">
		<cfargument name="ruleContext" type="any" required="false" default="">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset var my = structnew()>
		<cfset var x = 0><cfset var idx = 0>
		<cfset var rc = variables.ruleManager.getCriteriaNode(ruleid,criteria)>
		<cfset my.ls = getResourceBundle(locale)>
		
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:variable name="fields">
				<xsl:for-each select="property">
					<xsl:if test="position()>1">#my.ls.describe_and#</xsl:if>
					#getContextPropertiesXML("Boolean",ruleContext,"@name",locale)# 
				</xsl:for-each>
			</xsl:variable>
			#my.ls.describe#
		</cfoutput></cfsavecontent>
		
		<cfreturn my.xsl>
	</cffunction>
	
</cfcomponent>

