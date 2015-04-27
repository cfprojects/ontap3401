<cfcomponent displayname="ruleCriteria.Month" output="false" extends="criteria">
	
	<cfset setProperty("requiredContextProperties","Date")>
	
	<cffunction name="test" returntype="boolean" access="public" output="false">
		<cfargument name="criteria" required="true">
		<cfargument name="ruleContext" required="true">
		
		<cfset var my = structnew()>
		<cfset structappend(my,criteria.xmlAttributes)>
		
		<cfset my.actiondate = ruleContext.getValue(my.actiondate)>
		<cfif not isdate(my.actiondate)><cfreturn false></cfif>
		
		<cfif structkeyexists(my,"months") and len(trim(my.months)) 
			and not listFindNoCase(my.months,month(my.actiondate))><cfreturn false></cfif>
		
		<cfset my.testday = day(my.actionDate)>
		<cfreturn yesnoformat(my.testday gte my.after and my.testday lte my.before)>
	</cffunction>
	
	<cffunction name="getXML" returntype="string" access="public" output="false">
		<cfargument name="data" type="struct" required="true">
		<cfset var xml = "">
		<cfset var property = "">
		
		<cfparam name="data.months" type="string" default="">
		<cfsavecontent variable="xml"><cfoutput>
			<criteria type="#this.getValue('classPath')#" 
				actiondate="#xmlformat(data.actiondate)#" 
				<cfif len(data.months)>months="#xmlformat(data.months)#"</cfif>
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
		<cfset my.calendar = getLib().calendar.info(locale)>
		<cfset my.qMonths = QueryNew("inputvalue")>
		<cfset QueryAddColumn(my.qMonths,"inputlabel",my.calendar.full.month)>
		<cfloop query="my.qMonths"><cfset my.qMonths.inputvalue[currentrow] = currentrow></cfloop>
		
		<cf_html return="my.html" 
		skin="#this.getValue('skin')#" formdata="#formdata#"><cfoutput>
			<tap:form xmlns:tap="xml.tapogee.com" class="rulecriteria">
				<select name="actiondate" tap:query="dateQuery" 
					tap:default="#xmlformat(ruleContext.getValue('DateRuleDefaultProperty'))#" 
					tap:required="true" label="#xmlformat(my.ls.actiondate)#">
				<cfif dateQuery.recordcount gt 1><option /></cfif></select>
				
				<tap:validate type="numeric" min="1" max="31">
					<input type="text" name="after" label="#xmlformat(my.ls.after)#" tap:required="true" tap:default="1" />
					<input type="text" name="before" label="#xmlformat(my.ls.before)#" tap:required="true" tap:default="31" />
				</tap:validate>
				
				<select name="months" multiple="true" size="12" 
					tap:query="my.qMonths" label="#xmlformat(my.ls.months)#" />
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
		
		<cfif structkeyexists(my,"months")>
			<cfset my.calendar = getLib().calendar.info(locale)>
			<cfset my.shortmonths = listToArray(my.months)>
			<cfset my.fullmonths = arrayNew(1)>
			<cfloop index="x" from="1" to="#arraylen(my.shortmonths)#">
				<cfset my.fullmonths[x] = "<xsl:value-of select=""'#xmlformat(my.calendar.full.month[my.shortmonths[x]])#'"" />">
				<cfset my.shortmonths[x] = "<xsl:value-of select=""'#xmlformat(my.calendar.short.month[my.shortmonths[x]])#'"" />">
			</cfloop>
			<cfset my.shortmonths = ArrayToList(my.shortmonths,my.ls.comma)>
			<cfset my.fullmonths = ArrayToList(my.fullmonths,my.ls.comma)>
		<cfelse>
			<cfset my.shortmonths = "">
			<cfset my.fullmonths = "">
		</cfif>
		
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:variable name="actiondate">#getContextPropertiesXML("date",ruleContext,"@actiondate",locale)#</xsl:variable>
			<xsl:variable name="listshortmonths">#my.shortmonths#</xsl:variable>
			<xsl:variable name="listfullmonths">#my.fullmonths#</xsl:variable>
			<xsl:variable name="days">#my.ls.describe_days#</xsl:variable>
			<xsl:variable name="months">#my.ls.describe_months#</xsl:variable>
			#my.ls.describe#
		</cfoutput></cfsavecontent>
		
		<cfreturn my.xsl>
	</cffunction>
	
</cfcomponent>

