<cfcomponent displayname="ruleCriteria.dayOfWeek" output="false" extends="criteria">
	
	<cfset setProperty("requiredContextProperties","Date")>
	
	<cffunction name="test" returntype="boolean" access="public" output="false">
		<cfargument name="criteria" required="true">
		<cfargument name="ruleContext" required="true">
		
		<cfset var my = structnew()>
		
		<cfset my.weeks = trim(arg(criteria.xmlAttributes,"weeks",""))>
		<cfset my.weekdays = criteria.xmlAttributes.weekdays>
		<cfset my.actiondate = ruleContext.getValue(criteria.xmlAttributes.actiondate)>
		
		<cfif not isdate(my.actiondate)><cfreturn false></cfif>
		<cfif len(my.weeks) and not ListFind(my.weeks,getLib().lsDate(my.actiondate,"","W"))><cfreturn false></cfif>
		
		<cfreturn yesnoformat(listFindNoCase(my.weekdays,DayOfWeek(my.actiondate)))>
	</cffunction>
	
	<cffunction name="getXML" returntype="string" access="public" output="false">
		<cfargument name="data" type="struct" required="true">
		<cfset var xml = "">
		<cfset var property = "">
		
		<cfparam name="data.weeks" type="string" default="">
		
		<cfsavecontent variable="xml"><cfoutput>
			<criteria type="#this.getValue('classPath')#" 
				actiondate="#xmlformat(data.actiondate)#" 
				weeks="#xmlformat(data.weeks)#" 
				weekdays="#xmlformat(data.weekdays)#" />
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
		<cfset my.calendar = getLib().calendar.info(locale)>
		<cfset my.qDays = QueryNew("inputvalue")>
		<cfset QueryAddColumn(my.qDays,"inputlabel",my.calendar.full.weekday)>
		<cfloop query="my.qDays"><cfset my.qDays.inputvalue[currentrow] = currentrow></cfloop>
		
		<cfset my.qWeek = QueryNew("inputlabel,inputvalue")>
		<cfset QueryAddRow(my.qWeek,ceiling(31/my.qDays.recordcount))>
		<cfloop query="my.qWeek">
			<cfset my.qWeek.inputValue[currentrow] = currentrow>
			<cfset my.qWeek.inputLabel[currentrow] = currentrow>
		</cfloop>
		
		<cf_html return="my.html" 
		skin="#this.getValue('skin')#" formdata="#formdata#"><cfoutput>
			<tap:form xmlns:tap="xml.tapogee.com" class="rulecriteria">
				<select name="actiondate" tap:query="dateQuery" 
					tap:default="#xmlformat(ruleContext.getValue('DateRuleDefaultProperty'))#" 
					tap:required="true" label="#xmlformat(my.ls.actiondate)#">
				<cfif dateQuery.recordcount gt 1><option /></cfif></select>
				
				<input type="checkbox" name="weeks" tap:linebreak="false"
				tap:query="my.qWeek" label="#xmlformat(my.ls.weeks)#" />
				
				<select name="weekdays" multiple="true" size="7" 
					tap:query="my.qDays" tap:variable="my.weekdays" 
					label="#xmlformat(my.ls.weekdays)#" tap:required="true" />
			</tap:form>
		</cfoutput></cf_html>
		
		<cfloop index="x" from="1" to="#my.calendar.firstdayofweek#">
			<cfset getLib().html.childMove(my.weekdays,1,0)>
		</cfloop>
		
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
		
		<cfset my.calendar = getLib().calendar.info(locale)>
		<cfset my.shortdays = listToArray(my.weekdays)>
		<cfset my.fulldays = arrayNew(1)>
		<cfloop index="x" from="1" to="#arraylen(my.shortdays)#">
			<cfset my.fulldays[x] = "<xsl:value-of select=""'#xmlformat(my.calendar.full.weekday[my.shortdays[x]])#'"" />">
			<cfset my.shortdays[x] = "<xsl:value-of select=""'#xmlformat(my.calendar.short.weekday[my.shortdays[x]])#'"" />">
		</cfloop>
		<cfset my.shortdays = ArrayToList(my.shortdays,my.ls.comma)>
		<cfset my.fulldays = ArrayToList(my.fulldays,my.ls.comma)>
		
		<cfparam name="my.weeks" type="string" default="">
		<cfset my.weeks = listToArray(trim(my.weeks))><cfloop index="x" from="1" to="#arraylen(my.weeks)#">
		<cfset my.weeks[x] = "<xsl:value-of select=""'#xmlformat(my.ls['week_' & my.weeks[x]])#'"" />"></cfloop>
		<cfset my.weeks = arrayToList(my.weeks,my.ls.comma)>
		
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:variable name="actiondate">#getContextPropertiesXML("date",ruleContext,"@actiondate",locale)#</xsl:variable>
			<xsl:variable name="listweeks">#my.weeks#</xsl:variable>
			<xsl:variable name="weeks">#my.ls.describe_weeks#</xsl:variable>
			<xsl:variable name="listshortdays">#my.shortdays#</xsl:variable>
			<xsl:variable name="listfulldays">#my.fulldays#</xsl:variable>
			<xsl:variable name="weekdays">#my.ls.describe_days#</xsl:variable>
			#my.ls.describe#
		</cfoutput></cfsavecontent>
		
		<cfreturn my.xsl>
	</cffunction>
	
</cfcomponent>

