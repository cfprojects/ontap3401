<cfcomponent displayname="ruleCriteria.Number" output="false" extends="criteria">
	
	<cfset setProperty("numericType","Number")>
	<cfset setProperty("formatArray",ListToArray("gte,lte,eq,gt,lt"))>
	
	<cffunction name="configure" access="private" output="false">
		<cfset this.setValue("requiredContextProperties",this.getValue("numericType"))>
	</cffunction>
	
	<cffunction name="test" returntype="boolean" access="public" output="false">
		<cfargument name="criteria" required="true">
		<cfargument name="ruleContext" required="true">
		
		<cfset var my = structnew()>
		<cfset structappend(my,criteria.xmlattributes,true)>
		<cfset my.actionnumber = ruleContext.getValue(my.actionnumber)>
		<!--- if the action number is not available or not a number default the criteria to false --->
		<cfif not isnumeric(my.actionnumber)><cfreturn false></cfif>
		
		<cfparam name="my.compnumber" type="string" default="">
		<cfif len(my.compnumber)>
			<cfset my.compnumber = ruleContext.getValue(my.compnumber)>
			<!--- if the comparison number is not available or not a number default the criteria to false --->
			<cfif not isnumeric(my.compnumber)><cfreturn false></cfif>
		</cfif>
		
		<cfparam name="my.literalnumber" type="numeric" default="#my.compnumber#">
		<cfparam name="my.percentage" type="numeric" default="1">
		<cfparam name="my.adjustment" type="numeric" default="0">
		<cfset my.literalnumber = (my.literalnumber * my.percentage) + my.adjustment>
		
		<cfset my.result = evaluate("#my.actionnumber# #my.comparison# #my.literalnumber#")>
		<cfreturn yesnoformat(my.result)>
	</cffunction>
	
	<cffunction name="getXML" returntype="string" access="public" output="false">
		<cfargument name="data" type="struct" required="true">
		<cfset var xml = "">
		<cfset var property = "">
		
		<cfparam name="data.percentage" type="string" default="">
		<cfparam name="data.adjustment" type="string" default="">
		<cfparam name="data.compnumber" type="string" default="">
		<cfparam name="data.literalnumber" type="string" default="">
		<cfset data.percentage = getLib().lsNumberParseAny(data.percentage)>
		<cfif not isnumeric(data.percentage)><cfset data.percentage = 100></cfif>
		<cfset data.percentage = data.percentage / 100>
		
		<cfsavecontent variable="xml"><cfoutput>
			<criteria type="#this.getValue('classPath')#" 
				actionnumber="#xmlformat(data.actionnumber)#" comparison="#xmlformat(data.comparison)#" 
				percentage="#xmlformat(data.percentage)#" <cfif len(data.adjustment)>
				adjustment="#getLib().lsNumberParseAny(data.adjustment)#" </cfif><cfif len(trim(data.compnumber))>
				compnumber="#xmlformat(data.compnumber)#" <cfelseif len(trim(data.literalnumber))>
				literalnumber="#getLib().lsNumberParseAny(data.literalnumber)#"</cfif> />
		</cfoutput></cfsavecontent>
		
		<cfreturn xml>
	</cffunction>
	
	<cffunction name="getFormatQuery" returntype="query" access="private" output="false">
		<cfargument name="locale" type="string" required="true">
		<cfset var FormatQuery = QueryNew("inputlabel")>
		<cfset var ls = getResourceBundle(locale)>
		<cfset QueryAddColumn(FormatQuery,"inputvalue",this.getValue("formatArray"))>
		<cfloop query="FormatQuery"><cfset FormatQuery.inputLabel = ls["format_" & FormatQuery.inputValue]></cfloop>
		<cfreturn FormatQuery>
	</cffunction>
	
	<cffunction name="getForm" returntype="struct" access="public" output="false">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="numeric" required="true">
		<cfargument name="formdata" type="struct" required="true">
		<cfargument name="ruleContext" type="any" required="true">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset var my = structnew()><cfset var x = 0>
		<cfset var rcNode = variables.ruleManager.getCriteriaNode(ruleid,criteria)>
		<cfset var PropertyQuery = getContextProperties(this.getValue("numericType"),ruleContext,locale)>
		<cfset var FormatQuery = getFormatQuery(locale)>
		<cfset my.ls = getResourceBundle(locale)>
		<cfparam name="formdata.percentage" type="string" default="#iif(structkeyexists(rcNode.xmlattributes,'percentage'),'100*val(rcNode.xmlattributes.percentage)',100)#">
		<cfset structappend(formdata,rcNode.xmlattributes,false)>
		
		<cf_html return="my.html" 
		skin="#this.getValue('skin')#" formdata="#formdata#"><cfoutput>
			<tap:form xmlns:tap="xml.tapogee.com" class="rulecriteria">
				<select name="actionnumber" tap:query="PropertyQuery" 
					tap:default="#xmlformat(ruleContext.getValue(this.getValue('numericType')&'RuleDefaultProperty'))#" 
					tap:required="true" label="#xmlformat(my.ls.actionnumber)#">
				<cfif propertyQuery.recordcount gt 1><option /></cfif></select>
				
				<select name="comparison" tap:query="FormatQuery" />

				<input type="text" name="literalnumber" label="#xmlformat(my.ls.literalnumber)#" tap:validate="numeric" tap:variable="my.inputliteral" />
				
				<tap:formgroup label="#xmlformat(my.ls.adjustmentgroup)#">
					<input type="text" name="percentage" size="8" tap:validate="numeric" label="#xmlformat(my.ls.percentage)#" />
					<input type="text" name="adjustment" size="8" tap:validate="numeric" label="#xmlformat(my.ls.adjustment)#" />
				</tap:formgroup>
				
				<select name="compnumber" tap:query="PropertyQuery" label="#xmlformat(my.ls.compnumber)#" tap:variable="my.inputproperty"><option /></select>
			</tap:form>
		</cfoutput></cf_html>
		
		<cfset my.required = getLib().getArray(my.inputliteral,my.inputproperty)>
		<cfset getLib().html.formRequireExclusive(my.html,my.required)>
		
		<cfreturn my.html>
	</cffunction>
	
	<cffunction name="getNumericLocale" returntype="string" access="private" output="false">
		<cfargument name="ruleContext" required="true">
		<cfargument name="defaultLocale" type="string" required="true">
		<cfset var temp = ruleContext.getValue(this.getValue("numericType") & "RuleLocale")>
		<cfif len(trim(temp))><cfset defaultLocale = temp></cfif>
		<cfreturn defaultLocale>
	</cffunction>
	
	<cffunction name="describe" returntype="string" access="public" output="false">
		<cfargument name="ruleid" type="string" required="true" default="">
		<cfargument name="criteria" type="numeric" required="true" default="0">
		<cfargument name="ruleContext" type="any" required="false" default="">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset var my = structnew()>
		<cfset var x = 0><cfset var idx = 0>
		<cfset var rc = variables.ruleManager.getCriteriaNode(ruleid,criteria)>
		<cfset var rsFormat = getFormatQuery(locale)>
		<cfset var nFormat = this.getValue("numberFormat")>
		<cfset var nLocale = getNumericLocale(ruleContext,locale)>
		<cfset structappend(my,rc.xmlattributes,true)>
		<cfset my.ls = getResourceBundle(locale)>
		
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:variable name="actionnumber">
				#getContextPropertiesXML(this.getValue("numericType"),ruleContext,"@actionnumber",locale)#
			</xsl:variable>
			
			<xsl:variable name="format">
				<xsl:choose><cfloop query="rsFormat">
					<xsl:when test="@comparison='#xmlformat(rsFormat.inputvalue)#'">
					#xmlformat(rsFormat.inputLabel)#</xsl:when></cfloop>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="percentage">
				<cfif structkeyexists(my,"percentage") and my.percentage neq 1>
					<xsl:variable name="percentamount">
						#getLib().lsNumber(my.percentage,"per",locale)#
					</xsl:variable>
					#my.ls.percentof# 
				</cfif>
			</xsl:variable>
			
			<xsl:variable name="compnumber">
				<cfif structkeyexists(rc.xmlattributes,"literalnumber")>
					#xmlformat(getLib().lsNumber(rc.xmlattributes.literalnumber,nFormat,nLocale))#
				<cfelse>#getContextPropertiesXML(this.getValue("numericType"),ruleContext,"@compnumber",locale)#</cfif>
			</xsl:variable>
			
			<xsl:variable name="adjustment">
				<cfif structkeyexists(my,"adjustment") and my.adjustment neq 0>
					<xsl:variable name="adjustmentamount">
						#getLib().lsNumber(abs(my.adjustment),nFormat,nLocale)#
					</xsl:variable>
					#my.ls.adjustformat#
				</cfif>
			</xsl:variable>
			
			#my.ls.describe#
		</cfoutput></cfsavecontent>
		
		<cfreturn my.xsl>
	</cffunction>
	
</cfcomponent>

