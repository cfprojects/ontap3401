<cfcomponent displayname="ruleCriteria.weekOfYear" output="false" extends="criteria">
	
	<cfset setProperty("requiredContextProperties","Date")>
	
	<cffunction name="test" returntype="boolean" access="public" output="false">
		<cfargument name="criteria" required="true">
		<cfargument name="ruleContext" required="true">
		
		<cfset var my = structnew()>
		<cfset structappend(my,criteria.xmlAttributes)>
		<cfset my.actiondate = ruleContext.getValue(criteria.xmlAttributes.actiondate)>
		
		<cfif not isdate(my.actiondate)><cfreturn false></cfif>
		<cfset my.testweek = getLib().lsDate(my.actionDate,"","w")>
		<cfreturn yesnoformat(my.testweek gte my.after and my.testweek lte my.before)>
	</cffunction>
	
	<cffunction name="getXML" returntype="string" access="public" output="false">
		<cfargument name="data" type="struct" required="true">
		<cfset var xml = "">
		<cfset var property = "">
		
		<cfsavecontent variable="xml"><cfoutput>
			<criteria type="#this.getValue('classPath')#" 
				actiondate="#xmlformat(data.actiondate)#" 
				after="#getLib().lsNumberParse(data.after,'int')#" 
				before="#getLib().lsNumberParse(data.before,'int')#" />
		</cfoutput></cfsavecontent>
		
		<cfreturn xml>
	</cffunction>
	
	<cffunction name="getForm" returntype="struct" access="public" output="false">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="numeric" required="true">
		<cfargument name="formdata" type="struct" required="true">
		<cfargument name="ruleContext" type="any" required="true">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset var my = structnew()><cfset var x = 0>
		<cfset var rcNode = variables.ruleManager.getCriteriaNode(ruleid,criteria)>
		<cfset var dateQuery = getContextProperties("Date",ruleContext,locale)>
		<cfset structappend(formdata,rcNode.xmlattributes,false)>
		<cfset my.ls = getResourceBundle(locale)>
		
		<cf_html return="my.html" skin="#this.getValue('skin')#" formdata="#formdata#"><cfoutput>
			<tap:form xmlns:tap="xml.tapogee.com" class="rulecriteria">
				<select name="actiondate" tap:query="dateQuery" 
					tap:default="#xmlformat(ruleContext.getValue('DateRuleDefaultProperty'))#" 
					tap:required="true" label="#xmlformat(my.ls.actiondate)#">
				<cfif dateQuery.recordcount gt 1><option /></cfif></select>
				
				<tap:validate type="numeric" min="1" max="#365/7#">
					<input type="text" name="after" label="#xmlformat(my.ls.after)#" tap:required="true" />
					<input type="text" name="before" label="#xmlformat(my.ls.before)#" tap:required="true" />
				</tap:validate>
			</tap:form>
		</cfoutput></cf_html>
		
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
		<cfset structappend(my,rc.xmlattributes,true)>
		<cfset my.ls = getResourceBundle(locale)>
		
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:variable name="actiondate">#getContextPropertiesXML("date",ruleContext,"@actiondate",locale)#</xsl:variable>
			#my.ls.describe#
		</cfoutput></cfsavecontent>
		
		<cfreturn my.xsl>
	</cffunction>
	
</cfcomponent>

