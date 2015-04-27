<cfcomponent displayname="ruleCriteria.Rule" output="false" extends="criteria">
	
	<cfset variables.currentStack = "">
	
	<cffunction name="test" returntype="boolean" access="public" output="false">
		<cfargument name="criteria" required="true">
		<cfargument name="ruleContext" required="true">
		<cfset var ruleid = criteria.xmlattributes.rule>
		
		<cfif listfindnocase(variables.currentStack,ruleid)>
			<!--- return false if an infinite loop condition is created by circuitous rules --->
			<cfreturn false><!--- the stack was not pushed, so rules in the current stack will be removed after returning false here --->
		<cfelse>
			<!--- add the alternate rule to the current stack before testing the rule to prevent infinite loops --->
			<cfset listPrepend(variables.currentStack,ruleid)>
			<cfreturn yesnoformat(variables.ruleManager.ruleApplies(criteria.xmlattributes.rule) 
				xor not arg(criteria.xmlattributes,"applies",true))>
			<!--- the current rule evaluated, remove it from the stack --->
			<cfset variables.currentStack = listRest(variables.currentStack)>
		</cfif>
	</cffunction>
	
	<cffunction name="appliesToContext" returntype="boolean" access="public" output="false">
		<cfargument name="RuleContext" required="true">
		<cfreturn iif(getRuleQuery(RuleContext).recordcount gt 1,true,false)>
	</cffunction>
	
	<cffunction name="getXML" returntype="string" access="public" output="false">
		<cfargument name="data" type="struct" required="true">
		<cfset var xml = "">
		
		<cfsavecontent variable="xml"><cfoutput>
			<criteria type="#data.criteriatype#" rule="#data.rule#" applies="#iif(arg(data,'applies','true'),true,false)#" />
		</cfoutput></cfsavecontent>
		
		<cfreturn xml>
	</cffunction>
	
	<cffunction name="ContextSuppliesRules" access="private" output="false" returntype="boolean">
		<cfargument name="RuleContext" required="true">
		<cfset var temp = RuleContext.getValue("SuppliesRuleProperties")>
		<cfreturn iif(isBoolean(temp),temp,false)>
	</cffunction>
	
	<cffunction name="getRuleQuery" returntype="query" access="private" output="false">
		<cfargument name="RuleContext" required="true">
		<cfargument name="ruleid" type="string" required="false" default="">
		<cfargument name="locale" type="string" required="false" default="">
		<cfset var ruleQuery = 0>
		<cfset var inputvalue = "inputvalue">
		<cfset var inputlabel = "inputlabel">
		
		<cfif ContextSuppliesRules(RuleContext)>
			<cfset ruleQuery = getContextProperties("Rule",RuleContext,locale)>
		<cfelse>
			<cfset ruleQuery = variables.ruleManager.getValue("RuleQuery")>
			<cfset inputvalue = "ruleid">
			<cfset inputlabel = "rulename">
		</cfif>
		
		<cfquery name="ruleQuery" dbtype="query" debug="false">
			select #inputlabel# as inputlabel, #inputvalue# as inputvalue 
			from ruleQuery where #inputvalue# <> '' 
			<cfif len(trim(ruleid))>
				and lower(#inputvalue#) <> '#lcase(ruleid)#' 
			</cfif>
		</cfquery>
		
		<cfreturn ruleQuery>
	</cffunction>
	
	<cffunction name="getRuleName" access="private" output="false">
		<cfargument name="RuleContext" required="true">
		<cfargument name="RuleID" type="string" required="true">
		<cfargument name="locale" type="string" required="false" default="">
		<cfset var qry = getRuleQuery(RuleContext,"",locale)>
		<cfset var x = ListFindNoCase(ValueList(qry.inputvalue),arguments.ruleid)>
		<cfif x><cfreturn qry.inputlabel[x]><cfelse><cfreturn ""></cfif>
	</cffunction>
	
	<cffunction name="getForm" returntype="struct" access="public" output="false">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="numeric" required="true">
		<cfargument name="formdata" type="struct" required="true">
		<cfargument name="ruleContext" type="any" required="true">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset var ls = "%tap_rulemanager." & this.getValue("classpath")>
		<cfset var my = structnew()><cfset var x = 0>
		<cfset var rcNode = variables.ruleManager.getCriteriaNode(ruleid,criteria)>
		<cfset var ruleQuery = getRuleQuery(RuleContext,ruleid)>
		<cfset my.ls = getResourceBundle(locale)>
		<cfset structappend(formdata,rcNode.xmlattributes,false)>
		
		<cf_html return="my.html" 
		skin="#this.getValue('skin')#" formdata="#formdata#"><cfoutput>
			<tap:form xmlns:tap="xml.tapogee.com" class="rulecriteria">
				<select name="rule" tap:query="ruleQuery" label="#xmlformat(my.ls.rule)#" 
					tap:required="true"><option /></select>
				<input type="radio" name="applies" tap:default="true" 
					tap:boolean="#xmlformat(my.ls.applies)#,#xmlformat(my.ls.doesnotapply)#" />
			</tap:form>
		</cfoutput></cf_html>
		
		<cfreturn my.html>
	</cffunction>
	
	<cffunction name="describe" returntype="string" access="public" output="false">
		<cfargument name="ruleid" type="string" required="true" default="">
		<cfargument name="criteria" type="numeric" required="true" default="0">
		<cfargument name="ruleContext" type="any" required="false" default="">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset var xsl = "">
		<cfset var my = structnew()>
		<cfset var rc = variables.ruleManager.getCriteriaNode(ruleid,criteria)>
		<cfset my.ls = getResourceBundle(locale)>
		
		<cfsavecontent variable="xsl"><cfoutput>
			<xsl:variable name="exec" select="@rule" />
			<xsl:variable name="rulename">#xmlformat(getRuleName(RuleContext,rc.xmlAttributes.rule,locale))#</xsl:variable>
			<xsl:variable name="rule">#xmlformat(my.ls.rule)#</xsl:variable>
			<xsl:variable name="applies">
				<xsl:choose>
					<xsl:when test="@applies and @applies='false'">#xmlformat(my.ls.describe_doesnotapply)#</xsl:when>
					<xsl:otherwise>#xmlformat(my.ls.describe_applies)#</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			#my.ls.describe#
		</cfoutput></cfsavecontent>
		
		<cfreturn xsl>
	</cffunction>
	
</cfcomponent>

