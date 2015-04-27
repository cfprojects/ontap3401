<cfcomponent displayname="ruleCriteria.Timezone" output="false" extends="criteria">
	
	<cfset setProperty("requiredContextProperties","Timezone")>
	
	<cffunction name="test" returntype="boolean" access="public" output="false">
		<cfargument name="criteria" required="true">
		<cfargument name="ruleContext" required="true">
		
		<cfset var my = structnew()>
		<cfset structappend(my,criteria.xmlattributes,true)>
		<cfset my.timezone = getLib().timezone.info(now(),ruleContext.getValue(my.timezone))>
		<cfset my.offset = iif(my.usedst,"my.timezone.offset","my.timezone.offsetraw") / 3600>
		<cfreturn yesnoformat(my.offset gte min(my.offsetmin,my.offsetmax) and my.offset lte max(my.offsetmin,my.offsetmax))>
	</cffunction>
	
	<cffunction name="getXML" returntype="string" access="public" output="false">
		<cfargument name="data" type="struct" required="true">
		<cfset var xml = "">
		<cfset var property = "">
		
		<cfparam name="data.usedst" type="boolean" default="0">
		
		<cfsavecontent variable="xml"><cfoutput>
			<criteria type="#this.getValue('classPath')#" 
				timezone="#xmlformat(data.actionTime)#" usedst="#iif(data.usedst,1,0)#" 
				offsetmin="#getLib().lsNumberParseAny(data.offsetmin)#" 
				offsetmax="#getLib().lsNumberParseAny(data.offsetmax)#" />
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
		<cfset var timezoneQuery = getContextProperties("Timezone",ruleContext,locale)>
		<cfset structappend(formdata,rcNode.xmlattributes,false)>
		<cfset my.ls = getResourceBundle(locale)>
		
		<cf_html return="my.html" 
		skin="#this.getValue('skin')#" formdata="#formdata#"><cfoutput>
			<tap:form xmlns:tap="xml.tapogee.com" class="rulecriteria">
				<select name="actiontime" tap:query="timezoneQuery" 
					tap:default="#xmlformat(ruleContext.getValue('TimezoneRuleDefaultProperty'))#" 
					tap:required="true" label="#xmlformat(my.ls.timezone)#">
					<cfif timezoneQuery.recordcount gt 1><option /></cfif></select>
				
				<tap:validate type="numeric" min="-14" max="12">
					<input type="text" name="offsetmin" label="#xmlformat(my.ls.offsetmin)#" tap:required="true" />
					<input type="text" name="offsetmax" label="#xmlformat(my.ls.offsetmax)#" tap:required="true" />
				</tap:validate>
				<input type="radio" name="usedst" label="#xmlformat(my.ls.usedst)#" tap:boolean="true" tap:default="true" />
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
		
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:variable name="timezone">#getContextPropertiesXML("Timezone",ruleContext,"@timezone",locale)#</xsl:variable>
			#my.ls.describe#
		</cfoutput></cfsavecontent>
		
		<cfreturn my.xsl>
	</cffunction>
	
</cfcomponent>

