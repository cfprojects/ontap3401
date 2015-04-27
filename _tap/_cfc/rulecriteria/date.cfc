<cfcomponent displayname="ruleCriteria.Date" output="false" extends="criteria">
	
	<cfset setProperty("requiredContextProperties","Date")>
	<cfset setProperty("partArray",listtoarray("d,w,m"))>
	
	<cffunction name="test" returntype="boolean" access="public" output="false">
		<cfargument name="criteria" required="true">
		<cfargument name="ruleContext" required="true">
		
		<cfset var my = structnew()>
		
		<cfset my.actiondate = ruleContext.getValue(criteria.xmlAttributes.actiondate)>
		<cfset my.compdate = arg(criteria.xmlattributes,"compdate","")>
		<cfset my.literaldate = arg(criteria.xmlattributes,"literaldate","")>
		<cfif len(my.compdate)><cfset my.compdate = ruleContext.getValue(my.compdate)>
		<cfelse><cfset my.compdate = my.literaldate></cfif>
		
		<!--- if either date is not defined (not entered into database, etc.) the date comparison should default to false --->
		<cfif not isdate(my.actiondate) or not isdate(my.compdate)><cfreturn false></cfif>
		
		<!--- allow dates to be adjusted ad-hoc --->
		<cfset my.units = arg(criteria.xmlAttributes,"datepart","")>
		<cfset my.adjustment = val(arg(criteria.xmlAttributes,"adjustment",""))>
		
		<cfif len(my.units) and my.adjustment neq 0>
			<cfset my.compdate = dateadd(my.units,my.adjustment,my.compdate)>
		</cfif>
		
		<cfif criteria.xmlattributes.before>
			<cfset my.temp = my.compdate>
			<cfset my.compdate = my.actiondate>
			<cfset my.actiondate = my.temp>
		</cfif>
		
		<!--- return true if the action date is on or after the comparison date --->
		<cfreturn yesnoformat(datediff("d",dateformat(my.compdate),dateformat(my.actiondate)) gte 0)>
	</cffunction>
	
	<cffunction name="getXML" returntype="string" access="public" output="false">
		<cfargument name="data" type="struct" required="true">
		<cfset var xml = "">
		<cfset var property = "">
		
		<cfparam name="data.before" type="boolean" default="false">
		<cfparam name="data.compdate" type="string" default="">
		<cfparam name="data.literaldate" type="string" default="">
		<cfparam name="data.adjustment" type="string" default="">
		<cfparam name="data.datepart" type="string" default="">
		
		<cfsavecontent variable="xml"><cfoutput>
			<criteria type="#this.getValue('classPath')#" 
				actiondate="#xmlformat(data.actiondate)#" 
				<cfif data.adjustment neq 0 and len(trim(data.datepart))>
				adjustment="#val(getLib().lsNumberParse(data.adjustment,'int'))#" 
				datepart="#data.datepart#"</cfif> before="#iif(data.before,true,false)#" 
				<cfif len(trim(data.compdate))>compdate="#xmlformat(data.compdate)#"<cfelse>
				literaldate="#xmlformat(dateformat(getLib().lsDateParseAny(data.literaldate)))#"</cfif> />
		</cfoutput></cfsavecontent>
		
		<cfreturn xml>
	</cffunction>
	
	<cffunction name="getDateParts" returntype="query" access="public" output="false">
		<cfargument name="locale" type="string" required="false" default="">
		<cfset var dp = querynew("inputlabel")>
		<cfset var ls = getResourceBundle(locale)>
		<cfset queryAddColumn(dp,"inputvalue",getValue("partArray"))><cfloop query="dp">
		<cfset dp.inputlabel[currentrow] = ls["datepart_" & dp.inputvalue[currentrow]]></cfloop>
		<cfreturn dp>
	</cffunction>
	
	<cffunction name="getForm" returntype="struct" access="public" output="false">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="numeric" required="true">
		<cfargument name="formdata" type="struct" required="true">
		<cfargument name="ruleContext" type="any" required="true">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset var my = structnew()><cfset var x = 0>
		<cfset var rcNode = variables.ruleManager.getCriteriaNode(ruleid,criteria)>
		<cfset var dateParts = getDateParts(locale)>
		<cfset var dateQuery = getContextProperties("Date",ruleContext,locale)>
		<cfset var baQuery = QueryNew("inputlabel")>
		<cfset my.ls = getResourceBundle(locale)>
		<cfset structappend(formdata,rcNode.xmlattributes,false)>
		<cfset QueryAddColumn(baQuery,"inputvalue",listtoarray("true,false"))>
		<cfset baQuery.inputLabel[1] = my.ls.before>
		<cfset baQuery.inputLabel[2] = my.ls.after>
		
		<cf_html return="my.html" skin="#this.getValue('skin')#" formdata="#formdata#"><cfoutput>
			<tap:form xmlns:tap="xml.tapogee.com" class="rulecriteria">
				<select name="actiondate" tap:query="dateQuery" 
					tap:default="#xmlformat(ruleContext.getValue('DateRuleDefaultProperty'))#" 
					tap:required="true" label="#xmlformat(my.ls.actiondate)#">
				<cfif dateQuery.recordcount gt 1><option /></cfif></select>
				
				<tap:formgroup label="#xmlformat(my.ls.adjustment)#">
					<input type="text" size="3" name="adjustment" tap:default="0" />
					<select name="datepart" tap:query="DateParts" style="width:auto;" />
					<select name="before" tap:query="baQuery" style="width:auto" tap:default="false" />
				</tap:formgroup>
				
				<tap:validate type="requireExclusive">
					<select name="compdate" tap:query="dateQuery" 
						label="#xmlformat(my.ls.compdate)#"><option /></select>
					<input type="text" name="literaldate" tap:validate="date" 
						label="#xmlformat(my.ls.literaldate)#" />
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
		<cfparam name="my.datepart" type="string" default="">
		<cfparam name="my.adjustment" type="string" default="0">
		<cfset my.ls = getResourceBundle(locale)>
		
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:variable name="before">#xmlformat(my.ls.before)#</xsl:variable>
			<xsl:variable name="after">#xmlformat(my.ls.after)#</xsl:variable>
			<xsl:variable name="beforeorafter">
				<xsl:choose>
					<xsl:when test="@before='true'"><xsl:value-of select="$before" /></xsl:when>
					<xsl:otherwise><xsl:value-of select="$after" /></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="actiondate">#getContextPropertiesXML("date",ruleContext,"@actiondate",locale)#</xsl:variable>
			<xsl:variable name="compdate">
				<cfif structkeyexists(rc.xmlattributes,"literaldate") and isdate(rc.xmlattributes.literaldate)>
				#xmlformat(getLib().showDate(rc.xmlattributes.literaldate))#
				<cfelse>#getContextPropertiesXML("date",ruleContext,"@compdate",locale)#</cfif>
			</xsl:variable>
			
			<xsl:variable name="isminimum">#xmlformat(my.ls.isMinimum)#</xsl:variable>
			<xsl:variable name="datepart">
				<cfif len(my.datepart)>#xmlformat(my.ls["datepart_" & my.datepart])#</cfif>
			</xsl:variable>
			<xsl:variable name="adjustment">
				<xsl:if test="string-length(@datepart) != 0 and number(@adjustment) != 0">
					#my.ls.describe_adjustment#
				</xsl:if>
			</xsl:variable>
			
			#my.ls.describe#
		</cfoutput></cfsavecontent>
		
		<cfreturn my.xsl>
	</cffunction>
</cfcomponent>
