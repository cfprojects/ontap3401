<cfcomponent displayname="ruleCriteria.Text" output="false" extends="criteria">
	
	<cfset setProperty("requiredContextProperties","Text")>
	<cfset setProperty("formatArray",listtoarray("contains,!contains,is,!is,start,!start,end,!end,expression"))>
	
	<cfset setProperty("format:is","^[expression]$")>
	<cfset setProperty("format:start","^[expression]")>
	<cfset setProperty("format:end","[expression]$")>
	<cfset setProperty("format:contains","[expression]")>
	
	<cffunction name="test" returntype="boolean" access="public" output="false">
		<cfargument name="criteria" required="true">
		<cfargument name="ruleContext" required="true">
		
		<cfset var cs = arg(criteria.xmlattributes,"casesensitive",false)>
		<cfset var expression = criteria.xmlattributes.expression>
		<cfset var format = criteria.xmlattributes.format>
		<cfset var aProperty = XMLSearch(criteria,"./property")>
		<cfset var text = "">
		<cfset var result = "">
		<cfset var x = 0>
		
		<cfif not cs><cfset text = lcase(text)><cfset expression = lcase(expression)></cfif>
		<cfif format is not "expression">
			<cfset format = replace(format,"!","")>
			<cfset expression = REReplace(expression,"([[:punct:]])","\\\1","ALL")>
			<cfset expression = ReplaceNoCase(this.getValue("format:#format#"),"[expression]",expression)>
		</cfif>
		
		<cfloop index="x" from="1" to="#ArrayLen(aProperty)#">
			<cfset text = ruleContext.getValue(aProperty[x].xmlAttributes.name)>
			
			<cftry>
				<cfset result = refind(expression,text)>
				<cfcatch><cfset result = false></cfcatch>
			</cftry>
			
			<cfif result><cfbreak></cfif>
		</cfloop>
		
		<cfif left(criteria.xmlattributes.format,1) is "!">
			<cfset result = yesnoformat(not result)>
		</cfif>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="getXML" returntype="string" access="public" output="false">
		<cfargument name="data" type="struct" required="true">
		<cfset var xml = "">
		<cfset var property = "">
		
		<cfsavecontent variable="xml"><cfoutput>
			<criteria type="#this.getValue('classPath')#" 
				format="#xmlformat(data.format)#" 
				expression="#xmlformat(data.expression)#" 
				casesensitive="#arg(data,'casesensitive','false')#">
				<cfloop index="property" list="#data.property#">
					<property name="#xmlformat(property)#" />
				</cfloop>
			</criteria>
		</cfoutput></cfsavecontent>
		
		<cfreturn xml>
	</cffunction>
	
	<cffunction name="getFormatQuery" returntype="query" access="private" output="false">
		<cfargument name="locale" type="string" required="true">
		<cfset var format = querynew("inputlabel")>
		<cfset var ls = getResourceBundle(locale)>
		<cfset queryAddColumn(format,"inputvalue",getValue("FormatArray"))><cfloop query="format">
		<cfset format.inputlabel = ls["format_" & format.inputvalue]></cfloop>
		<cfreturn format>
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
				
				<select name="format" tap:query="formatQuery" tap:required="true" 
					label="#xmlformat(my.ls.format)#" tap:default="contains"><option /></select>
				
				<input type="text" name="expression" tap:required="true" label="#xmlformat(my.ls.expression)#" />
				
				<input type="radio" tap:boolean="true" name="casesensitive" 
					tap:default="false" label="#xmlformat(my.ls.casesensitive)#" />
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
		<cfset var formatQuery = getFormatQuery(locale)>
		<cfset var propertyQuery = getContextProperties("Text",ruleContext,locale)>
		<cfparam name="formdata.property" type="string" default="#getPropertiesList(rcNode)#">
		
		<cfset structappend(formdata,rcNode.xmlattributes,false)>
		<cfif propertyQuery.recordcount is 1>
			<cfset rcNode.xmlattributes.property = propertyQuery.inputvalue>
		</cfif>
		
		<cf_html return="my.html" 
		skin="#this.getValue('skin')#" formdata="#formdata#">
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
			<xsl:variable name="format">#xmlformat(my.ls['format_' & rc.xmlattributes.format])#</xsl:variable>
			<xsl:variable name="fields">
				<xsl:for-each select="property">
					<xsl:if test="position()>1"><xsl:value-of select="' #my.ls.describe_or# '" /></xsl:if>
					#getContextPropertiesXML("text",ruleContext,"@name",locale)# 
				</xsl:for-each>
			</xsl:variable>
			#my.ls.describe#
		</cfoutput></cfsavecontent>
		
		<cfreturn my.xsl>
	</cffunction>
	
</cfcomponent>

