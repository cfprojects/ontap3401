<cfcomponent displayname="ruleCriteria.Locale" output="false" extends="criteria">
	
	<cfset setProperty("requiredContextProperties","Locale")>
	<cfset setProperty("formatArray",listtoarray("is,within,contains,!is,!within,!contains"))>
	
	<cffunction name="test" returntype="boolean" access="public" output="false">
		<cfargument name="criteria" required="true">
		<cfargument name="ruleContext" required="true">
		
		<cfset var my = structnew()>
		
		<cfset my.contextLocale = getLocaleList(criteria,"property")>
		<cfset my.ruleLocale = getLocaleList(criteria,"locale")>
		<cfset my.comparison = criteria.xmlattributes.comparison>
		<cfset my.result = false>
		
		<cfloop index="my.property" list="#my.contextLocale#">
			<cfloop index="my.cLocale" list="#ruleContext.getValue(my.property)#">
				<cfloop index="my.rLocale" list="#my.ruleLocale#">
					<cfswitch expression="#replace(my.comparison,'!','')#">
						<cfcase value="within"><cfset my.result = yesnoformat(findNoCase(my.rLocale,my.cLocale) eq 1)></cfcase>
						<cfcase value="contains"><cfset my.result = yesnoformat(findNoCase(my.cLocale,my.rLocale) eq 1)></cfcase>
						<cfdefaultcase><cfset my.result = yesnoformat(not comparenocase(my.cLocale,my.rLocale))></cfdefaultcase>
					</cfswitch>
					<cfif my.result><cfbreak></cfif>
				</cfloop>
				<cfif my.result><cfbreak></cfif>
			</cfloop>
			<cfif my.result><cfbreak></cfif>
		</cfloop>
		
		<cfif findnocase("!",my.comparison) eq 1>
			<cfset my.result = yesnoformat(not my.result)>
		</cfif>
		
		<cfreturn my.result>
	</cffunction>
	
	<cffunction name="getXML" returntype="string" access="public" output="false">
		<cfargument name="data" type="struct" required="true">
		<cfset var xml = "">
		<cfset var property = "">
		<cfset var locale = "">
		
		<cfsavecontent variable="xml"><cfoutput>
			<criteria type="#this.getValue('classPath')#" comparison="#xmlformat(data.comparison)#">
				<cfloop index="locale" list="#data.contextlocale#">
				<property name="#xmlformat(locale)#" /></cfloop>
				<cfloop index="locale" list="#data.rulelocale#">
				<locale name="#locale#" /></cfloop>
			</criteria>
		</cfoutput></cfsavecontent>
		
		<cfreturn xml>
	</cffunction>
	
	<cffunction name="getLocaleList" returntype="string" access="private" output="false"
	hint="converts the locale sub-nodes of a criteria node to a comma delimited list of locales">
		<cfargument name="node" required="true">
		<cfargument name="localetype" required="true">
		<cfset var x = 0><cfset var aLocale = XMLSearch(node,"#localetype#")>
		<cfloop index="x" from="1" to="#arrayLen(aLocale)#">
		<cfset aLocale[x] = aLocale[x].xmlAttributes.name></cfloop>
		<cfreturn ArrayToList(aLocale)>
	</cffunction>
	
	<cffunction name="getFormatQuery" returntype="query" access="private" output="false">
		<cfargument name="locale" type="string" required="true">
		<cfset var FormatQuery = QueryNew("inputlabel")>
		<cfset var ls = getResourceBundle(locale)>
		<cfset QueryAddColumn(FormatQuery,"inputvalue",this.getValue("formatArray"))><cfloop query="FormatQuery">
		<cfset FormatQuery.inputLabel = ls["format_" & FormatQuery.inputValue]></cfloop>
		<cfreturn FormatQuery>
	</cffunction>
	
	<cffunction name="getLocaleQuery" returntype="query" access="private" output="false">
		<cfargument name="ruleContext" required="true">
		<cfreturn getLib().locale.query(ruleContext.getValue("LocaleRulesUseLocalesIn"))>
	</cffunction>
	
	<cffunction name="getForm" returntype="struct" access="public" output="false">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="numeric" required="true">
		<cfargument name="formdata" type="struct" required="true">
		<cfargument name="ruleContext" type="any" required="true">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset var my = structnew()><cfset var x = 0>
		<cfset var rc = variables.ruleManager.getCriteriaNode(ruleid,criteria)>
		<cfset var ContextLocaleQuery = getContextProperties("Locale",ruleContext,locale)>
		<cfset var RuleLocaleQuery = getLocaleQuery(arguments.ruleContext)>
		<cfset var FormatQuery = getFormatQuery(locale)>
		<cfset my.ls = getResourceBundle(locale)>
		<cfset StructAppend(formdata,rc.xmlattributes,false)>
		
		<cfif ArrayLen(rc.xmlChildren)>
			<cfparam name="formdata.contextLocale" type="string" default="#getLocaleList(rc,'property')#">
			<cfparam name="formdata.ruleLocale" type="string" default="#getLocaleList(rc,'locale')#">
		</cfif>
		
		<cfquery name="RuleLocaleQuery" dbtype="query" debug="false">
			select locale as inputvalue, 
			localename as inputlabel 
			from RuleLocaleQuery 
		</cfquery>
		
		<cf_html return="my.html" 
		skin="#this.getValue('skin')#" formdata="#formdata#"><cfoutput>
			<tap:form xmlns:tap="xml.tapogee.com" class="rulecriteria">
				<select name="contextlocale" tap:query="ContextLocaleQuery" 
					tap:default="#ruleContext.getValue('LocaleRuleDefaultProperty')#" 
					<cfif ContextLocaleQuery.recordcount gt 1>
					multiple="true" size="#min(5,ContextLocaleQuery.recordcount)#"</cfif> 
					tap:required="true" label="#xmlformat(my.ls.contextLocale)#" />
				
				<select name="comparison" tap:query="FormatQuery" />
				
				<input type="swapbox" name="rulelocale" tap:query="RuleLocaleQuery" 
					size="#min(5,RuleLocaleQuery.recordcount)#" tap:sortable="false" 
					tap:available="#xmlformat(my.ls.availablelocales)#" 
					tap:selected="#xmlformat(my.ls.selectedlocales)#"
					tap:required="true" label="#xmlformat(my.ls.ruleLocale)#" />
			</tap:form>
		</cfoutput></cf_html>
		
		<cfreturn my.html>
	</cffunction>
	
	<cffunction name="newLine" access="private" output="false" returntype="string">
		<cfreturn getTap().newline()>
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
		<cfset var aLocale = ListToArray(getLocaleList(rc,"locale"))>
		<cfset my.ls = getResourceBundle(locale)>
		<cfloop index="x" from="1" to="#arrayLen(aLocale)#">
			<cfset aLocale[x] = "<xsl:value-of select=""'#xmlformat(getLib().locale.info(aLocale[x]).localeName)#'"" />">
		</cfloop><cfset my.ruleLocales = ArrayToList(aLocale,my.ls.comma & newline())>
		
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:variable name="contextlocale">
				<xsl:for-each select="property">
					<xsl:if test="position()>1">#my.ls.comma#</xsl:if>
					#getContextPropertiesXML("locale",ruleContext,"@name",locale)#
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="format">
				<xsl:choose><cfloop query="rsFormat">
					<xsl:when test="@comparison='#xmlformat(rsFormat.inputvalue)#'">
					#xmlformat(rsFormat.inputLabel)#</xsl:when></cfloop>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="rulelocales">#my.ruleLocales#</xsl:variable>
			
			#my.ls.describe#
		</cfoutput></cfsavecontent>
		
		<cfreturn my.xsl>
	</cffunction>
	
</cfcomponent>

