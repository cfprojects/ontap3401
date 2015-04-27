<cfcomponent displayname="ruleCriteria.timeOfDay" output="false" extends="criteria">
	
	<cfset setProperty("requiredContextProperties","Time")>
	
	<cffunction name="test" returntype="boolean" access="public" output="false">
		<cfargument name="criteria" required="true">
		<cfargument name="ruleContext" required="true">
		
		<cfset var my = structnew()>
		<cfset var tf = "HHmm">
		<cfset structappend(my,criteria.xmlattributes,true)>
		<cfset my.actionTime = ruleContext.getValue(my.actionTime)>
		<cfif not isdate(my.actiontime)><cfreturn false></cfif>
		
		<cfif structkeyexists(my,"after")>
			<cfset my.afterliteral = ruleContext.getValue(my.after)>
			<cfif not isdate(my.afterliteral)><cfreturn false></cfif>
		</cfif><cfif structkeyexists(my,"afterliteral") and 
		timeformat(my.afterliteral,tf) gt timeformat(my.actiontime,tf)><cfreturn false></cfif>
		
		<cfif structkeyexists(my,"before")>
			<cfset my.beforeliteral = ruleContext.getValue(my.before)>
			<cfif not isdate(my.beforeliteral)><cfreturn false></cfif>
		</cfif><cfif structkeyexists(my,"beforeliteral") and 
		timeformat(my.beforeliteral,tf) lt timeformat(my.actiontime,tf)><cfreturn false></cfif>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getXML" returntype="string" access="public" output="false">
		<cfargument name="data" type="struct" required="true">
		<cfset var xml = "">
		<cfset var property = "">
		
		<cfparam name="data.after" type="string" default="">
		<cfparam name="data.before" type="string" default="">
		<cfparam name="data.afterliteral" type="string" default="">
		<cfparam name="data.beforeliteral" type="string" default="">
		
		<cfsavecontent variable="xml"><cfoutput>
			<criteria type="#this.getValue('classPath')#" 
				actiontime="#xmlformat(data.actionTime)#" 
				<cfif len(data.after)>after="#xmlformat(data.after)#" 
				<cfelseif len(trim(data.afterliteral))>
				afterliteral="#timeformat(data.afterliteral,'HH:mm')#"</cfif>
				<cfif len(data.before)>before="#xmlformat(data.before)#" 
				<cfelseif len(trim(data.beforeliteral))>
				beforeliteral="#timeformat(data.beforeliteral,'HH:mm')#"</cfif> />
		</cfoutput></cfsavecontent>
		
		<cfreturn xml>
	</cffunction>
	
	<cffunction name="formatTimeQuery" returntype="query" access="private" output="false">
		<cfargument name="qry" type="query" required="true">
		<cfargument name="locale" type="string" required="true">
		
		<cfloop query="qry">
			<cfset qry.inputlabel = getLib().lsTime(qry.inputvalue,arguments.locale,3,"UTC")>
			<cfset qry.inputvalue = TimeFormat(qry.inputvalue,"HH:mm")>
		</cfloop>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="buildTimeQuery" returntype="query" access="private" output="false">
		<cfargument name="increments" required="true">
		
		<cfset var my = structnew()>
		<cfset my.rs = QueryNew("inputlabel")>
		
		<cfif not isnumeric(increments)><cfset increments = 30></cfif>
		<cfset my.inputvalue = ArrayNew(1)>
		<cfset my.midnight = CreateDateTime(year(now()),month(now()),day(now()),0,0,0)>
		
		<cfif increments gt 0>
			<cfloop index="my.x" from="0" to="#(24*60)-1#" step="#increments#">
			<cfset ArrayAppend(my.inputvalue,DateAdd("n",my.x,my.midnight))></cfloop>
		</cfif><cfset QueryAddColumn(my.rs,"inputvalue",my.inputvalue)>
		
		<cfreturn my.rs>
	</cffunction>
	
	<cffunction name="getLiteralTimeQuery" returntype="query" access="private" output="false">
		<cfargument name="ruleContext" required="true">
		<cfargument name="locale" required="true">
		
		<cfset var qry = ruleContext.getValue("TimeRuleTimes")>
		
		<cfif not isQuery(qry)>
			<cfset qry = buildTimeQuery(ruleContext.getValue("TimeRuleMinutes"))>
		</cfif>
		
		<cfreturn formatTimeQuery(qry,arguments.locale)>
	</cffunction>
	
	<cffunction name="getForm" returntype="struct" access="public" output="false">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="numeric" required="true">
		<cfargument name="formdata" type="struct" required="true">
		<cfargument name="ruleContext" type="any" required="true">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset var my = structnew()><cfset var x = 0>
		<cfset var rcNode = variables.ruleManager.getCriteriaNode(ruleid,criteria)>
		<cfset var timeQuery = getContextProperties("Time",ruleContext,locale)>
		<cfset var literalTimeQuery = getLiteralTimeQuery(ruleContext,locale)>
		<cfset structappend(formdata,rcNode.xmlattributes,false)>
		<cfset my.ls = getResourceBundle(locale)>
		
		<cf_html return="my.html" 
		skin="#this.getValue('skin')#" formdata="#formdata#"><cfoutput>
			<tap:form xmlns:tap="xml.tapogee.com" class="rulecriteria">
				<select name="actiontime" tap:query="timeQuery" 
					tap:default="#xmlformat(ruleContext.getValue('TimeRuleDefaultProperty'))#" 
					tap:required="true" label="#xmlformat(my.ls.actiontime)#">
					<cfif timeQuery.recordcount gt 1><option /></cfif></select>
				
				<tap:validate type="requireOneOf">
					<tap:validate type="acceptExclusive">
						<select name="after" tap:query="timeQuery" label="#xmlformat(my.ls.after)#"><option /></select>
						<cfif literalTimeQuery.recordcount>
							<select name="afterliteral" tap:query="literalTimeQuery" 
							label="#xmlformat(my.ls.afterliteral)#"><option /></select>
						</cfif>
					</tap:validate>
					<tap:validate type="acceptExclusive">
						<select name="before" tap:query="timeQuery" label="#xmlformat(my.ls.before)#"><option /></select>
						<cfif literalTimeQuery.recordcount>
							<select name="beforeliteral" tap:query="literalTimeQuery" 
							label="#xmlformat(my.ls.beforeliteral)#"><option /></select>
						</cfif>
					</tap:validate>
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
		<cfset var rc = variables.ruleManager.getCriteriaNode(ruleid,criteria)>
		<cfset structappend(my,rc.xmlattributes,true)>
		<cfset my.ls = getResourceBundle(locale)>
		
		<cfif structkeyexists(my,"after")><cfset my.after = getContextPropertiesXML("Time",ruleContext,"@after",locale)>
		<cfelseif structkeyexists(my,"afterliteral")><cfset my.after = xmlformat(getLib().lsTime(my.afterliteral,arguments.locale,3,"UTC"))></cfif>
		<cfif structkeyexists(my,"before")><cfset my.before = getContextPropertiesXML("Time",ruleContext,"@before",locale)>
		<cfelseif structkeyexists(my,"beforeliteral")><cfset my.before = xmlformat(getLib().lsTime(my.beforeliteral,arguments.locale,3,"UTC"))></cfif>
		
		<cfparam name="my.after" type="string" default="">
		<cfparam name="my.before" type="string" default="">
		
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:variable name="actiontime">#getContextPropertiesXML("Time",ruleContext,"@actiontime",locale)#</xsl:variable>
			<xsl:variable name="after">#my.after#</xsl:variable>
			<xsl:variable name="before">#my.before#</xsl:variable>
			<cfif len(trim(my.before)) and len(trim(my.after))>#my.ls.describe_between#
			<cfelseif len(trim(my.before))>#my.ls.describe_before#
			<cfelse>#my.ls.describe_after#</cfif>
		</cfoutput></cfsavecontent>
		
		<cfreturn my.xsl>
	</cffunction>
	
</cfcomponent>

