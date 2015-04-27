<cfcomponent displayname="RuleManager" output="false" extends="ontap" 
hint="provides an extensible facade for allowing end-users to manage complex business rules via an XML storage medium">
	<cfproperty name="rules" type="xml" required="false" hint="an xml document containing a single rule-set - defaults to an empty rule-set">
	<cfproperty name="cache" type="struct" required="false" hint="enhances performance by eliminating the need to continually search the xml ruleset document for specific rule nodes">
	<cfproperty name="ruleContext" type="component" required="false" hint="a component for which the loaded rule-set should be applied">
	<cfproperty name="debug" type="boolean" required="false" default="false" hint="when false certain exceptions are suppressed (failed criteria evaluate false) - defaults to getTap().development">
	<cfproperty name="packages" type="array" required="false" hint="a collection of directories containing rulecriteria components applicable to the indicated ruleContext">
	<cfproperty name="xml" type="string" required="false" hint="a text representation of the loaded rule-set">
	<cfproperty name="ruleCount" type="numeric" required="false" hint="the total number of rules in the loaded rule-set">
	<cfproperty name="ruleQuery" type="query" required="false" hint="a query containing descriptive data for all rules in the rule-set">
	<cfproperty name="criteriaList" type="string" required="false" hint="a list of currently loaded rule criteria types which may or may not be applicable to the rule context">
	<cfproperty name="ruleAttributes" type="string" required="false" default="ruleid,rulename,ruledescription" hint="a list of the attributes applied to each rule">
	<cfproperty name="ruleLock" type="string" required="false" hint="a unique lock-name to apply to rule updates to prevent race-conditions with simultaneous updates">
	
	<cfset variables.describe = structnew()>
	<cfset setProperty("ruleLock",getLib().uName("tap_",35,true))>
	<cfset setProperty("cache",structnew())>
	<cfset setProperty("rules",getDefaultRulesetXML())>
	<cfset setProperty("debug",false)>
	
	<cffunction name="init" access="public" output="false" 
	hint="initializes the rule manager with a set of rules">
		<cfargument name="rules" type="any" required="false" default="#getDefaultRulesetXML()#" 
			hint="a serialized xml packet containing the rules to manage">
		<cfargument name="ruleContext" type="any" required="false" default="#this.getValue('ruleContext')#"
			hint="allows a RuleManager object to maintain a default context from which other methods draw context-sensitive information">
		<cfargument name="debug" type="any" required="false" default="#this.getValue('debug')#">
		<cfargument name="packages" type="array" required="false" default="#listtoarray('rulecriteria')#" 
			hint="an array of component package directories containing CFC's for the rule criteria types appropriate for the rules xml packet">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset var my = structnew()>
		<cfset var x = 0>
		
		<cfset this.setValue("debug",debug)>
		<cfset this.setValue("rules",rules)>
		<cfset this.setValue("ruleContext",ruleContext)>
		<cfset this.setValue("locale",locale)>
		
		<cfset variables.describe = structnew()>
		
		<cfloop index="x" from="1" to="#arraylen(packages)#">
			<cfset loadCriteriaPackage(packages[x])>
		</cfloop>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="set_rules" access="private" output="false" 
	hint="sets the rule xml property for the RuleManager object - ensures the xml is parsed">
		<cfargument name="propertyValue" required="true">
		<cfset var xml = propertyValue>
		<cftry>
			<cfif issimplevalue(xml)><cfset xml = xmlparse(xml)></cfif>
			<cfset variables.describe = structnew()>
			<cfcatch>
				<cfif this.getValue("debug")><cfrethrow><cfelse>
				<cfset xml = getDefaultRulesetXML()></cfif>
			</cfcatch>
		</cftry>
		<cfset setProperty("rules",xml)>
		<cfset this.setValue("cache",structnew())>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getDefaultRulesetXML" access="private" output="false">
		<cfreturn xmlParse("<ruleset />")>
	</cffunction>
	
	<cffunction name="set_debug" access="private" output="false" 
	hint="turns debugging on or off for the RuleManager object">
		<cfargument name="propertyValue" required="true">
		<cfargument name="overwrite" type="boolean" required="false" default="true">
		<cfset var debug = propertyValue>
		<cfif not isboolean(debug)><cfset debug = getTap().development></cfif>
		<cfreturn setProperty("debug",debug,overwrite)>
	</cffunction>
	
	<cffunction name="get_debug" returntype="boolean" access="private" output="false">
		<cfset var debug = getProperty("debug")>
		<cfif not isBoolean(debug)><cfreturn false>
		<cfelse><cfreturn debug></cfif>
	</cffunction>
	
	<cffunction name="get_skin" returntype="string" access="private" output="false">
		<cfset var skin = getProperty("skin")>
		<cfif not len(trim(skin))><cfreturn "rulemanager">
		<cfelse><cfreturn skin></cfif>
	</cffunction>
	
	<cffunction name="get_ruleAttributes" returntype="string" access="private" output="false">
		<cfset var attribs = getProperty("ruleAttributes")>
		<cfif not len(trim(attribs))><cfreturn "ruleid,rulename,ruledescription">
		<cfelse><cfreturn attribs></cfif>
	</cffunction>
	
	<cffunction name="get_xml" returntype="string" access="private" output="false"
	hint="returns the serialized version of the current xml rule packet for storage">
		<cfreturn toString(this.getValue("rules"))>
	</cffunction>
	
	<cffunction name="get_ruleCount" returntype="numeric" access="private" output="false"
	hint="returns the number of rules in the loaded rule-set">
		<cfreturn ArrayLen(search("/*/rule"))>
	</cffunction>
	
	<cffunction name="search" returntype="array" access="public" output="false" 
	hint="provides a short-curt for performing x-path searches against the loaded rule-set">
		<cfargument name="xpath" type="string" required="true">
		<cfreturn XMLSearch(this.getValue("rules"),xpath)>
	</cffunction>
	
	<cffunction name="saveTransformation" access="private" returntype="string" output="false"
	hint="transforms and reloads the currently instantiated rule-set package">
		<cfargument name="xsl" type="string" required="true">
		<cfargument name="debug" type="boolean" required="false" default="#this.getValue('debug')#">
		
		<cftry>
			<cflock name="#getValue('rulelock')#" type="exclusive" timeout="10">
				<cfset this.setValue("rules",this.transform(xsl,true))>
			</cflock>
			<cfcatch><cfif debug><cfrethrow></cfif></cfcatch>
		</cftry>
		
		<cfreturn this.getValue("xml")>
	</cffunction>
	
	<cffunction name="transform" access="public" returntype="string" output="false" 
	hint="returns the xml text of an xsl transformation against the loaded rule-set">
		<cfargument name="xsl" type="string" required="true">
		<cfargument name="debug" type="boolean" required="false" default="#this.getValue('debug')#">
		
		<cftry>
			<cfreturn XMLTransform(this.getValue("rules"),xsl)>
			<cfcatch><cfif debug><cfrethrow><cfelse><cfreturn ""></cfif></cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="criteriaCount" returntype="numeric" access="public" output="false" 
	hint="returns the number of rules in the loaded rule-set">
		<cfargument name="ruleid" type="string" required="true">
		<cfreturn ArrayLen(search("/*/rule[@ruleid='#xmlformat(lcase(trim(ruleid)))#']/criteria"))>
	</cffunction>
	
	<cffunction name="get_ruleQuery" returntype="query" access="public" output="false"
	hint="returns a query containing attributes for the rules in the loaded rule-set">
		<cfset var columnlist = this.getValue("ruleAttributes")>
		<cfset var qry = QueryNew(columnlist)>
		<cfset var aRule = search("/*/rule")>
		<cfset var x = 0><cfset var c = 0>
		
		<cfif ArrayLen(aRule)><cfset QueryAddRow(qry,ArrayLen(aRule))></cfif>
		
		<cfloop index="x" from="1" to="#arraylen(aRule)#">
			<cfloop index="c" list="#columnlist#">
				<cfset qry[c][x] = aRule[x].xmlattributes[c]>
			</cfloop>
		</cfloop>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="loadCriteria" access="public" output="false" 
	hint="loads an individual criteria cfc into the rulemanager">
		<cfargument name="classpath" type="string" required="true">
		<cfset var criteria = this.getValue("criteriaList")>
		<cfif not ListFindNoCase(criteria,classpath)>
			<cfset criteria = ListAppend(criteria,classpath)>
			<cfset this.setValue("criteriaList",criteria)>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="unloadCriteria" access="public" output="false" 
	hint="loads an individual criteria cfc into the rulemanager">
		<cfargument name="classpath" type="string" required="true">
		<cfset var criteria = this.getValue("criteriaList")>
		<cfset var x = ListFindNoCase(criteria,classpath)>
		<cfif x>
			<cfset criteria = ListDeleteAt(criteria,x)>
			<cfset this.setValue("criteriaList",criteria)>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getPackagedCriteria" returntype="array" access="private" output="false" 
	hint="returns a comma-delimited list of the CFC's in a criteria package">
		<cfargument name="package" type="string" required="false" default="">
		<cfset var aClass = ListToArray(getFS().templateList(replace(package,".","/","ALL"),"CFC","^.*\.cfc$"))>
		<cfset var x = 0><cfloop index="x" from="1" to="#arraylen(aClass)#">
		<cfset aClass[x] = package & "." & REReplaceNoCase(aClass[x],"\.cfc$","")></cfloop>
		<cfreturn aClass>
	</cffunction>
	
	<cffunction name="loadCriteriaPackage" access="public" output="false"
	hint="adds all criteria in a specified package to the loaded criteria list">
		<cfargument name="package" type="string" required="true">
		<cfset var criteria = getPackagedCriteria(package)>
		<cfset var x = 0>
		
		<cfloop index="x" from="1" to="#arraylen(criteria)#">
		<cfset loadCriteria(criteria[x])></cfloop>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="unloadCriteriaPackage" access="public" output="false" 
	hint="removes all criteria in a specified package from the loaded criteria list">
		<cfargument name="package" type="string" required="true">
		<cfset var criteria = getPackagedCriteria(package)>
		<cfset var x = 0>
		
		<cfloop index="x" from="1" to="#arraylen(criteria)#">
		<cfset unloadCriteria(criteria[x])></cfloop>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getRuleNode" access="public" output="false" 
	hint="returns the xml node containing all information for a specified rule">
		<cfargument name="ruleid" type="string" required="false" default="">
		<cfset var rule = "">
		<cfset var cache = this.getValue("cache")>
		
		<cfif structKeyExists(cache,arguments.ruleid)>
			<cfset rule = cache[arguments.ruleid]>
		<cfelse>
			<cfset rule = search("/*/rule[@ruleid='#xmlformat(lcase(trim(arguments.ruleid)))#']")>
			<cfif arraylen(rule)>
				<cfset rule = rule[1]>
				<cfset cache[arguments.ruleid] = rule>
			<cfelse>
				<cfset rule = XMLElemNew(this.getValue("rules"),"rule")>
			</cfif>
		</cfif>
		
		<cfreturn rule>
	</cffunction>
	
	<cffunction name="getCriteriaNode" access="public" output="false" 
	hint="returns the xml node containing all information for a specified rule criteria">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="index" type="numeric" required="true">
		<cfset var node = iif(index,"getRuleNode(ruleid).xmlChildren","arrayNew(1)")>
		
		<cfif index and arraylen(node) gte index>
			<cfset node = node[index]>
		<cfelse>
			<cfset node = XMLElemNew(this.getValue("rules"),"criteria")>
			<cfset node.xmlattributes["type"] = "">
		</cfif>
		
		<cfreturn node>
	</cffunction>
	
	<cffunction name="getCriteriaObject" access="private" output="false" 
	hint="returns a locally cached criteria object which can be used to manage criteria of a specified type">
		<cfargument name="classpath" type="string" required="true">
		<cfset var rc = "">
		
		<cfparam name="variables.criteria" type="struct" default="#structnew()#">
		<cfset rc = arg(variables.criteria,classpath,"")>
		
		<cfif issimplevalue(rc)>
			<cfset rc = CreateObject("component",classpath).init(this)>
			<cfset rc.setValue("classPath",classpath)>
			<cfset rc.setValue("skin",this.getValue("skin"))>
			<cfset variables.criteria[classpath] = rc>
		</cfif>
		
		<cfreturn rc>
	</cffunction>
	
	<cffunction name="getCriteriaTypes" returntype="query" access="public" output="false" 
	hint="returns the criteria types available for the current rule set from the initialized criteria list">
		<cfargument name="applicable" type="boolean" required="false" default="true" 
			hint="allows individual criteria types to determine if they are applicable and should be included, given the current context">
		<cfargument name="debug" type="boolean" required="false" default="#this.getValue('debug')#">
		<cfargument name="ruleContext" type="any" required="false" default="#this.getValue('ruleContext')#">
		<cfargument name="locale" type="string" required="false" default="#this.getValue('locale')#">
		
		<cfset var qry = QueryNew("inputvalue,inputlabel,isApplicable")>
		<cfset var classPath = ListToArray(this.getValue("criteriaList"))>
		<cfset var name = "">
		<cfset var rc = 0>
		<cfset var x = 0>
		
		<cfloop index="x" from="1" to="#arraylen(classPath)#">
			<cftry>
				<cfset rc = getCriteriaObject(classPath[x])>
				<cfset name = rc.getTypeName(locale)>
				
				<cfif len(trim(name))>
					<cfset QueryAddrow(qry)>
					<cfset qry.inputlabel[qry.recordcount] = name>
					<cfset qry.inputvalue[qry.recordcount] = classPath[x]>
					<cfset qry.isApplicable[qry.recordcount] = iif(rc.appliesToContext(ruleContext),1,0)>
				</cfif>
				<cfcatch><cfif debug><cfrethrow></cfif></cfcatch>
			</cftry>
		</cfloop>
		
		<cfif applicable>
			<cfquery name="qry" dbtype="query" debug="false">
				select * from qry where isApplicable = 1  
			</cfquery>
		</cfif>
		
		<cfreturn getLib().lsSortQuery(qry,"inputlabel")>
	</cffunction>
	
	<cffunction name="testCriteria" returntype="string" access="private" output="false" 
	hint="fetches the appropriate criteria object and returns the viability of a single criteria">
		<cfargument name="criteriaNode" required="true">
		<cfargument name="ruleContext" required="true">
		<cfargument name="debug" type="boolean" default="#this.getValue('debug')#">
		<cftry><cfreturn getCriteriaObject(criteriaNode.xmlattributes.type).test(criteriaNode,ruleContext)>
		<cfcatch><cfif debug><cfrethrow><cfelse><cfreturn false></cfif></cfcatch></cftry>
	</cffunction>
	
	<cffunction name="ruleApplies" returntype="boolean" access="public" output="false"
	hint="evaluates a specified rule to determine its applicability by testing each criteria in order">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="ruleContext" type="any" required="false" default="#this.getValue('ruleContext')#">
		
		<cfset var my = structnew()>
		<cfset var x = 0>
		<cfset var y = 1>
		<cfset var rule = getRuleNode(ruleid)>
		<cfset var currentValue = true>
		
		<!--- assume the rule does not apply if no criteria are specified --->
		<cfif not ArrayLen(rule.xmlChildren)><cfreturn false></cfif>
		
		<cfscript>
			for (x = 1; x lte arraylen(rule.xmlchildren); x = x + 1) { // loop over all criteria in the rule 
				my.testResult = testCriteria(rule.xmlChildren[x],ruleContext); // test the current criteria for applicability 
				if (isBoolean(my.testresult) and not my.testResult) { currentValue = false; } // if the current criteria is inapplicable, set the value for the current criteria-segment to false 
				if (my.testResult is "or") { // if the test reslt is not boolean the current value represents the final result of the current criteria segment - if true 
					if (currentValue) { return true; } else { currentValue = true; } // if the criteria segment is true the rule applies -- otherwise try the next segment 
				} 
			} 
		</cfscript>
		
		<cfreturn currentValue>
	</cffunction>
	
	<cffunction name="debugCriteria" returntype="string" access="public" output="false" 
	hint="tests the validity of an individual criteria">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="numeric" required="true">
		<cfargument name="ruleContext" type="any" required="false" default="#this.getValue('ruleContext')#">
		<cfset var returnvalue = testCriteria(getCriteriaNode(arguments.ruleid,arguments.criteria),arguments.ruleContext,true)>
		<cfif isboolean(returnvalue)><cfset returnvalue = iif(returnvalue,true,false)></cfif>
		<cfreturn returnvalue>
	</cffunction>
	
	<cffunction name="debugRule" returntype="array" access="public" output="false"
	hint="returns an array of debugged criteria">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="ruleContext" type="any" required="false" default="#this.getValue('ruleContext')#">
		
		<cfset var rule = getRuleNode(ruleid)>
		<cfset var debug = ArrayNew(1)>
		<cfset var x = 0>
		
		<cfloop index="x" from="1" to="#arraylen(rule.xmlchildren)#">
			<cftry>
				<cfset debug[x] = structNew()>
				<cfset debug[x].error = structnew()>
				<cfset debug[x].type = rule.xmlChildren[x].xmlAttributes.type>
				<cfset debug[x].testresult = false>
				<cfset debug[x].rulenode = rule.xmlChildren[x]>
				<cfset debug[x].testresult = testCriteria(rule.xmlChildren[x],arguments.ruleContext,true)>
				<cfif isboolean(debug[x].testresult)><cfset debug[x].testresult = iif(debug[x].testresult,true,false)></cfif>
				<cfcatch><cfset structAppend(debug[x].error,cfcatch,true)></cfcatch>
			</cftry>
		</cfloop>
		
		<cfreturn debug>
	</cffunction>
	
	<cffunction name="ruleLength" returntype="numeric" access="public" output="false"  
	hint="returns the number of criteria in a specified rule for debugging purposes">
		<cfargument name="ruleid" type="string" required="true">
		<cfreturn arrayLen(getRuleNode(ruleid).xmlChildren)>
	</cffunction>
	
	<cffunction name="getRuleForm" returntype="struct" access="public" output="false" 
	hint="returns an html form element which can be used to update a rule in the current rule-set">
		<cfargument name="netaction" type="string" required="false" default="">
		<cfargument name="action" type="string" required="false" default="?">
		<cfargument name="domain" type="string" required="false" default="C">
		<cfargument name="formdata" type="struct" required="false" default="#duplicate(form)#">
		<cfargument name="ruleid" type="string" required="false" default="#arg(formdata,'ruleid','')#">
		<cfargument name="showruleid" type="boolean" required="false" default="false">
		<cfargument name="skin" type="string" required="false" default="#getValue('skin')#">
		<cfargument name="parent" type="struct" required="false" default="#structNew()#">
		<cfargument name="position" type="numeric" required="false" default="0">
		<cfargument name="formid" type="string" required="false" default="">
		
		<cfset var my = structnew()>
		<cfset var ls = getLib().ls>
		<cfset ls("%tap_rulemanager_ruleid","Rule ID",false)>
		<cfset ls("%tap_rulemanager_rulename","Rule Name",false)>
		<cfset ls("%tap_rulemanager_ruledescription","Description",false)>
		<cfset structappend(arguments.formdata,getRuleNode(ruleid).xmlAttributes,false)>
		<cfset arguments.formdata.ruleid = lcase(trim(arguments.ruleid))>
		
		<cf_html return="my.html" parent="#arguments.parent#" 
		position="#arguments.position#" skin="#arguments.skin#" 
		formdata="#arguments.formdata#"><cfoutput>
			<tap:form name="#arguments.formid#" xmlns:tap="xml.tapogee.com" 
			action="#xmlformat(arguments.action)#" tap:domain="#xmlformat(arguments.domain)#">
				<input type="hidden" name="netaction" value="#xmlformat(arguments.netaction)#" />
				<cfif arguments.showruleid>
					<input name="ruleid" type="text" label="%tap_rulemanager_ruleid" />
				<cfelse>
					<input name="ruleid" type="hidden" />
				</cfif>
				<input name="rulename" type="text" label="%tap_rulemanager_rulename" tap:required="true" />
				<textarea name="ruledescription" label="%tap_rulemanager_ruledescription" />
				<button type="submit">%tap_submit</button>
			</tap:form>
		</cfoutput></cf_html>
		
		<cfreturn my.html>
	</cffunction>
	
	<cffunction name="getNewRuleID" returntype="string" access="private" output="false">
		<cfreturn getLib().uName("rule_",35,true)>
	</cffunction>
	
	<cffunction name="updateRule" access="public" returntype="string" output="false" 
	hint="updates the attributes for a specified rule and returns the ruleid of the updated rule">
		<cfargument name="ruledata" type="struct" required="false" default="#form#">
		<cfargument name="ruleid" type="string" required="false" default="#arg(ruledata,'ruleid','')#">
		<cfset var ruleset = getValue("rules").ruleset>
		<cfset var rule = getRuleNode(ruleid)>
		<cfset var x = 0>
		
		<cfset ruleid = lcase(trim(ruleid))>
		<cfif not len(trim(ruleid))><cfset ruleid = getNewRuleID()></cfif>
		
		<cfloop index="x" list="#lcase(this.getValue('ruleAttributes'))#">
		<cfset setRuleAttribute(rule,x,arg(ruledata,x,""))>
		<cfparam name="rule.xmlattributes.#x#" type="string" default=""></cfloop>
		
		<!--- if the rule isn't already present in the xml ruleset node, add the rule to the list --->
		<cfif not ruleExists(ruleid)><cfset ArrayAppend(ruleset.xmlChildren,rule)></cfif>
		<cfset this.setValue("rules",this.getValue("rules"))>
		
		<cfreturn ruleid>
	</cffunction>
	
	<cffunction name="deleteRule" access="public" returntype="string" output="false" 
	hint="removes a rule from the instantiated rule-set xml packet">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="debug" type="boolean" required="false" default="#this.getValue('debug')#">
		<cfset var my = structNew() />
		
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
				<xsl:output method="xml" />
				
				<xsl:template match="//*">
					<xsl:copy>
						<xsl:copy-of select="@*" />
						<xsl:apply-templates />
					</xsl:copy>
				</xsl:template>
				
				<xsl:template match="/*/rule[@ruleid='#xmlformat(lcase(trim(ruleid)))#']" />
			</xsl:stylesheet>
		</cfoutput></cfsavecontent>
		
		<cfset clearDescription(arguments.ruleid)>
		
		<cfreturn saveTransformation(my.xsl,debug)>
	</cffunction>
	
	<cffunction name="sortRules" access="public" returntype="string" output="false" 
	hint="allows the rules in a ruleset to be sorted according to a specified ruleid order">
		<cfargument name="rulelist" type="string" required="true">
		<cfargument name="debug" type="boolean" required="false" default="#this.getValue('debug')#">
		
		<cfset var my = structnew()>
		<cfset var ruleid = "">
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
				<xsl:output method="xml" />
				
				<xsl:template match="//*">
					<xsl:copy>
						<xsl:copy-of select="@*" />
						<xsl:apply-templates />
					</xsl:copy>
				</xsl:template>
				
				<xsl:template match="/ruleset">
					<xsl:copy>
						<xsl:copy-of select="@*" />
						<cfloop index="ruleid" list="#rulelist#">
							<xsl:copy-of select="./rule[@ruleid='#xmlformat(lcase(trim(ruleid)))#']" />
						</cfloop>
						<xsl:for-each select="./rule">
							<xsl:if test="not contains(',#xmlformat(lcase(rulelist))#,',concat(',',@ruleid,','))">
								<xsl:copy-of select="." />
							</xsl:if>
						</xsl:for-each>
					</xsl:copy>
				</xsl:template>
			</xsl:stylesheet>
		</cfoutput></cfsavecontent>
		
		<cfreturn saveTransformation(my.xsl,debug)>
	</cffunction>
	
	<cffunction name="getCriteriaQuery" returntype="query" access="public" output="false"
	hint="returns a query containing attributes for the rules in the loaded rule-set">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="ruleContext" type="any" required="false" default="#this.getValue('ruleContext')#">
		<cfargument name="locale" type="string" required="false" default="#this.getValue('locale')#">
		<cfset var my = structnew()><cfset var rc = 0>
		<cfset var qry = QueryNew("classpath,typename,hasForm,description")>
		<cfset QueryAddColumn(qry,"criteria",search("/*/rule[@ruleid='#xmlformat(lcase(trim(ruleid)))#']/criteria"))>
		
		<cfloop query="qry">
			<cfset qry.classpath = qry.criteria[currentrow].xmlattributes.type>
			<cfset rc = getCriteriaObject(qry.classpath)>
			<cfset qry.typename = rc.getTypeName(locale)>
			<cfset qry.hasForm = rc.getValue("hasForm")>
			<cfset qry.description = describeCriteria(ruleid,currentrow,ruleContext,locale)>
			<cfset qry.criteria = currentrow>
		</cfloop>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getCriteriaXML" access="public" returntype="string" output="false"
	hint="fetches the appropriate XML syntax for a specific rule criteria from its assigned class">
		<cfargument name="type" required="true">
		<cfargument name="insertdata" type="struct" required="false" default="#form#">
		<cfargument name="ruleContext" type="any" required="false" default="#this.getValue('ruleContext')#">
		<cfreturn trim(getCriteriaObject(type).getXML(insertdata,ruleContext))>
	</cffunction>
	
	<cffunction name="moveCriteria" returntype="string" output="false" access="public" 
	hint="relocates a criteria element within a specified rule">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="numeric" required="true">
		<cfargument name="positioin" type="numeric" required="true">
		
		<cfset var rule = getRuleNode(ruleid)>
		<cfset var rc = rule.xmlChildren[criteria]>
		
		<cfset ArrayDeleteAt(rule.xmlChildren,criteria)>
		<cfif position and position lte ArrayLen(rule.xmlChildren)>
			<cfset ArrayInsertAt(rule.xmlChildren,position,rc)>
		<cfelse><cfset ArrayAppend(rule.xmlChildren,rc)></cfif>
		
		<cfset clearDescription(arguments.ruleid)>
		
		<cfreturn this.getValue("xml")>
	</cffunction>
	
	<cffunction name="exportRule" returntype="string" output="false" access="public" 
	hint="returns a text representation of a rule node which can be imported into another RuleManager object / rule-set packet">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="exportAs" type="string" required="false" default="#arguments.ruleid#">
		<cfset var ruleNode = duplicate(getRuleNode(arguments.ruleid))>
		<cfif not len(trim(arguments.exportAs))>
		<cfset arguments.exportAs = getNewRuleID()></cfif>
		<cfset ruleNode.xmlattributes["ruleid"] = arguments.exportAs>
		<cfreturn trim(rereplacenocase(toString(ruleNode),"<\?xml [^?]*\?>",""))>
	</cffunction>
	
	<cffunction name="ruleExists" returntype="boolean" output="false" access="public"
	hint="indicates if a rule exists in the rule set matching a specified rule id">
		<cfargument name="ruleid" type="string" required="true" hint="a rule to find in the loaded rule set">
		<cfreturn yesnoformat(arraylen(search("/*/rule[@ruleid='#xmlformat(lcase(trim(arguments.ruleid)))#']")))>
	</cffunction>
	
	<cffunction name="importRule" returntype="string" output="false" access="public" 
	hint="retrieves a rule from an alternate RuleManager object and imports the rule into the current rule-set - returns the ruleid of the imported rule">
		<cfargument name="ruleset" required="true" hint="a ruleManager component containing the desired rule to import">
		<cfargument name="ruleid" type="string" required="true" hint="identifies the rule to import from the source ruleset object">
		<cfargument name="importAs" type="string" required="false" default="rename" hint="allows the rule to be renamed when imported - rename or overwrite may be used to indicate that the original rule id should be tried">
		<cfargument name="debug" type="boolean" required="false" default="#this.getValue('debug')#">
		<cfset var my = structnew()>
		<cfset my.exists = this.ruleExists(arguments.ruleid)>
		
		<cfswitch expression="#arguments.importAs#">
			<cfcase value="overwrite">
				<cfif my.exists><cfset this.deleteRule(arguments.ruleid)></cfif>
				<cfset arguments.importAs = arguments.ruleid>
			</cfcase>
			<cfcase value="rename">
				<cfif my.exists><cfset arguments.importAs = ""><cfelse>
				<cfset arguments.importAs = arguments.ruleid></cfif>
			</cfcase>
		</cfswitch>
		
		<cfset my.ruleNode = ruleset.exportRule(arguments.ruleid,arguments.importAs)>
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
				<xsl:output method="xml" />
				
				<xsl:template match="//*">
					<xsl:copy>
						<xsl:copy-of select="@*" />
						<xsl:apply-templates />
					</xsl:copy>
				</xsl:template>
				
				<xsl:template match="/ruleset">
					<xsl:copy>
						<xsl:copy-of select="@*" />
						<xsl:apply-templates />
						#my.rulenode#
					</xsl:copy>
				</xsl:template>
			</xsl:stylesheet>
		</cfoutput></cfsavecontent>
		
		<cfset saveTransformation(my.xsl,arguments.debug)>
		<cfset my.ruleNode = getRuleNode(arguments.importAs)>
		<cfset updateRule(my.ruleNode.xmlAttributes)>
		<cfreturn arguments.importAs>
	</cffunction>
	
	<cffunction name="setRuleCriteria" returntype="string" output="false" access="public" 
	hint="updates an individual criteria within a specified rule">
		<cfargument name="insertdata" type="struct" required="false" default="#form#">
		<cfargument name="ruleContext" type="any" required="false" default="#this.getValue('ruleContext')#">
		<cfargument name="debug" type="boolean" required="false" default="#this.getValue('debug')#">
		
		<cfset var temp = structnew()>
		<cfset var my = structnew()>
		<cfset structappend(my,insertdata,false)>
		<cfparam name="my.ruleid" type="string">
		<cfparam name="my.criteriatype" type="string">
		<cfparam name="my.criteria" type="string" default="">
		<cfset my.criteria = val(my.criteria)>
		<cfparam name="my.position" type="string" default="#my.criteria#">
		<cfset my.ruleid = lcase(trim(my.ruleid))>
		
		<cfif my.criteria and my.position neq my.criteria>
			<cfset moveCriteria(my.ruleid,my.criteria,my.position)>
			<cfif my.position eq 0><cfset my.position = criteriaCount(ruleid)></cfif>
		</cfif>
		
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
				<xsl:output method="xml" />
				
				<xsl:template match="//*">
					<xsl:copy>
						<xsl:copy-of select="@*" />
						<xsl:apply-templates />
					</xsl:copy>
				</xsl:template>
				
				<xsl:variable name="criteria">
					#getCriteriaXML(my.criteriatype,arguments.insertdata,arguments.rulecontext)#
				</xsl:variable>
				
				<xsl:template match="/*/rule[@ruleid='#xmlformat(my.ruleid)#']">
					<xsl:copy>
						<xsl:copy-of select="@*" />
						<cfif my.position eq 0>
							<xsl:apply-templates />
							<xsl:copy-of select="$criteria" />
						<cfelse>
							<xsl:for-each select="criteria">
								<xsl:choose>
									<xsl:when test="position()=#my.position#">
										<xsl:copy-of select="$criteria" />
										<cfif not my.criteria><xsl:copy-of select="." /></cfif>
									</xsl:when>
									<xsl:otherwise><xsl:copy-of select="." /></xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</cfif>
					</xsl:copy>
				</xsl:template>
				
			</xsl:stylesheet>
		</cfoutput></cfsavecontent>
		
		<cfset clearDescription(my.ruleid,my.criteria)>
		
		<cfreturn saveTransformation(my.xsl,debug)>
	</cffunction>
	
	<cffunction name="deleteRuleCriteria" access="public" output="false" 
	hint="updates an individual criteria within a specified rule">
		<cfargument name="ruleid" type="string" required="false" default="#arg(data,'ruleid','')#">
		<cfargument name="criteria" type="numeric" required="false" default="#arg(data,'criteria',0)#" 
			hint="indicates the index of the criteria to remove within the specified rule">
		<cfargument name="debug" type="boolean" default="#this.getValue('debug')#">
		<cfset var xsl = "">
		<cfset var node = getRuleNode(arguments.ruleid)>
		
		<cfif arrayLen(node.xmlChildren) gte arguments.criteria>
			<cfset arrayDeleteAt(node.xmlChildren,arguments.criteria)>
			<cfset clearDescription(arguments.ruleid,arguments.criteria,true)>
			<cfset this.setValue("rules",this.getValue("rules"))>
		</cfif>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="criteriaHasForm" returntype="boolean" access="public" output="false"
	hint="not all criteria types require form values to generate their nodes, such as the 'or' criteria type - this method returns the value of the criteria type object's 'hasForm' property">
		<cfargument name="type" type="string" required="true">
		<cfreturn getCriteriaObject(type).getValue("hasForm")>
	</cffunction>
	
	<cffunction name="setPositionOptions" returntype="void" access="public" output="false" 
	hint="populates an empty select element with option values indicating the available criteria positions for a specified rule">
		<cfargument name="input" type="struct" required="true">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="selected" type="numeric" required="false" default="0">
		<cfargument name="uselastposition" type="boolean" required="false" default="#yesnoformat(not val(selected))#">
		
		<cfset var htlib = getLib().html>
		<cfset var x = criteriaCount(ruleid)>
		<cfset selected = val(selected)>
		<cfif uselastposition><cfset htlib.inputSelectOption(input,x+1,0,0)></cfif>
		<cfloop index="x" from="#x#" to="1" step="-1">
		<cfset htlib.inputSelectOption(input,x,x,1)></cfloop>
		<cfset htlib.inputSet(input,selected)>
	</cffunction>
	
	<cffunction name="getNewCriteriaForm" returntype="struct" access="public" output="false" 
	hint="returns an html library structure representing a form for adding new criteria to an existing rule">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="netaction" type="string" required="false" default="">
		<cfargument name="href" type="string" required="false" default="?">
		<cfargument name="domain" type="string" required="false" default="C">
		<cfargument name="target" type="string" required="false" default="_self">
		<cfargument name="skin" type="string" required="false" default="#getValue('skin')#">
		<cfargument name="parent" type="struct" required="false" default="#structNew()#">
		<cfargument name="position" type="numeric" required="false" default="0">
		<cfargument name="formid" type="string" required="false" default="">
		<cfargument name="RuleContext" required="false" default="#this.getValue('ruleContext')#">
		
		<cfset var my = structnew()>
		<cfset my.type = getCriteriaTypes(required=true,RuleContext=arguments.ruleContext)>
		<cfset getLib().ls("%tap_rulemanager_addnewcriteria","Add Criteria",false)>
		<cfset getLib().ls("%tap_rulemanager_requiretype","Please select a criteria type.",false)>
		
		<cf_html return="my.html" parent="#arguments.parent#" 
		position="#arguments.position#" skin="#arguments.skin#"><cfoutput>
			<form name="#arguments.formid#" xmlns:tap="xml.tapogee.com" target="#arguments.target#" 
			action="#arguments.href#" tap:domain="#arguments.domain#" method="get">
				<input type="hidden" name="netaction" value="#arguments.netaction#" />
				<input type="hidden" name="ruleid" value="#lcase(trim(arguments.ruleid))#" />
				<input type="hidden" name="criteria" value="0" />
				<table border="0" cellpadding="0">
					<tr>
						<td>
							<select name="criteriatype" tap:required="%tap_rulemanager_requiretype" style="width:auto;">
								<option /><cfloop query="my.type">
									<option value="#my.type.inputvalue#">
									#htmleditformat(my.type.inputlabel)#</option>
								</cfloop>
							</select>
						</td>
						<td><select name="position" tap:variable="my.position" style="width:auto;" /></td>
						<td class="tap_formbutton"><button type="submit">%tap_rulemanager_addnewcriteria</button></td>
					</tr>
				</table>
			</form>
		</cfoutput></cf_html>
		
		<cfset setPositionOptions(my.position,arguments.ruleid)>
		
		<cfreturn my.html>
	</cffunction>
	
	<cffunction name="getURL" access="private" output="false" returntype="string">
		<cfargument name="href" type="string" required="true">
		<cfargument name="domain" type="string" required="false" default="R">
		<cfreturn getLib().getURL(href,domain)>
	</cffunction>
	
	<cffunction name="getCriteriaForm" returntype="struct" access="public" output="false" 
	hint="returns an html form to create or update a rule criteria node when provided a criteria type, ruleid and criteria index">
		<cfargument name="netaction" type="string" required="false" default="">
		<cfargument name="action" type="string" required="false" default="">
		<cfargument name="domain" type="string" required="false" default="C">
		<cfargument name="formdata" type="struct" required="false" default="#form#">
		<cfargument name="ruleContext" type="any" required="false" default="#this.getValue('ruleContext')#">
		<cfargument name="ruleid" type="string" required="false" default="#arg(formdata,'ruleid','')#">
		<cfargument name="criteria" type="string" required="false" default="#arg(formdata,'criteria','')#">
		<cfargument name="criteriatype" type="string" required="false" default="#arg(formdata,'criteriatype','')#">
		<cfargument name="locale" type="string" required="false" default="#this.getValue('locale')#">
		<cfargument name="parent" type="struct" required="false" default="#structNew()#">
		<cfargument name="position" type="numeric" required="false" default="0">
		
		<cfset var x = 0>
		<cfset var rc = 0>
		<cfset var html = structnew()>
		<cfset var htlib = getLib().html>
		<cfset var my = structnew()>
		
		<cfset criteria = val(criteria)>
		<cfset ruleid = lcase(trim(ruleid))>
		<cfif criteria><cfset criteriatype = getCriteriaType(ruleid,criteria)></cfif>
		<cfset rc = getCriteriaObject(criteriatype)>
		
		<cfif rc.getValue("hasForm")>
			<cfset getLib().ls("%tap_rulemanager_rulecriteria_position","Position",false)>
			<cfset getLib().ls("%tap_rulemanager_rulecriteria_save","Save Criteria",false)>
			<cfset html = rc.getForm(ruleid,criteria,getLib().simpleObject(formdata),ruleContext,locale)>
			<cfset htlib.attribute(html,"action",getURL(arguments.action,arguments.domain))>
			<cfset htlib.inputHidden("netaction",arguments.netaction,html)>
			<cfparam name="formdata.position" type="numeric" default="#criteria#">
			<cfset my.position = htlib.inputGet(html,"position")><cfif isstruct(my.position)>
			<cfset setPositionOptions(my.position,ruleid,formdata.position,yesnoformat(not criteria))></cfif>
			<cfif not StructIsEmpty(parent)><cfset htlib.childAdd(parent,html,position)></cfif>
		</cfif>
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="getCriteriaType" returntype="string" access="public" output="false" 
	hint="returns the class path of the criteria type cfc associated with a specific criteria node">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="string" required="true">
		<cfreturn getCriteriaNode(ruleid,criteria).xmlattributes.type>
	</cffunction>
	
	<cffunction name="describeCriteriaType" returntype="string" access="public" output="false" 
	hint="returns a text description of a specified rule criteria class">
		<cfargument name="type" type="string" required="true">
		<cfargument name="locale" type="string" required="false" default="#this.getValue('locale')#">
		<cfreturn getCriteriaObject(type).getTypeName(locale)>
	</cffunction>
	
	<cffunction name="getRuleCache" access="private" output="false"
	hint="returns an array of cached criteria descriptions for a specified rule">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="numeric" required="false" default="0">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset variables.describe[arguments.ruleid] = arg(variables.describe,arguments.ruleid,arraynew(1))>
		<cfif arguments.criteria lte 0><cfreturn variables.describe[arguments.ruleid]></cfif>
		<cfset variables.describe[arguments.ruleid][arguments.criteria] = arg(variables.describe[arguments.ruleid],arguments.criteria,structnew())>
		<cfif not len(trim(locale))><cfreturn variables.describe[arguments.ruleid][arguments.criteria]></cfif>
		<cfreturn arg(variables.describe[arguments.ruleid][arguments.criteria],arguments.locale,"")>
	</cffunction>
	
	<cffunction name="setRuleCache" returntype="void" access="private" output="false"
	hint="sets an array of cached criteria descriptions for a specified rule">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="numeric" required="true">
		<cfargument name="locale" type="string" required="true">
		<cfargument name="describe" type="string" required="true">
		<cfset var temp = getRuleCache(arguments.ruleid,arguments.criteria)>
		<cfset temp[locale] = describe>
	</cffunction>
	
	<cffunction name="clearDescription" returntype="void" access="private" output="false" 
	hint="clears cached rule criteria descriptions from the loaded ruleset">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="numeric" required="false" default="0">
		<cfargument name="delete" type="boolean" required="false" default="false">
		
		<cfif arguments.criteria gt 0>
			<cfif arguments.delete>
				<cfif arrayLen(getRuleCache(arguments.ruleid)) gte arguments.criteria>
					<cfset arrayDeleteAt(variables.describe[arguments.ruleid],arguments.criteria)>
				</cfif>
			<cfelse>
				<cfset structClear(getRuleCache(arguments.ruleid,arguments.criteria))>
			</cfif>
		<cfelse><cfset structDelete(variables.describe,arguments.ruleid,true)></cfif>
	</cffunction>
	
	<cffunction name="debug" returntype="struct" access="public" output="false"
	hint="used to debug the cached rule description information stored in the rulemanager object">
		<cfreturn arg(variables,"describe",structnew())>
	</cffunction>
	
	<cffunction name="getDescriptionXSL" returntype="string" access="private" output="false"
	hint="returns an xsl template to generate a localized description for a specified rule criteria node">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="string" required="true">
		<cfargument name="ruleContext" type="any" required="false" default="#this.getValue('ruleContext')#">
		<cfargument name="locale" type="string" required="false" default="#this.getValue('locale')#">

		<cfset var my = structnew()>
		<cfset arguments.ruleid = lcase(trim(arguments.ruleid))>
		<cfset my.rc = getCriteriaObject(getCriteriaType(arguments.ruleid,criteria))>
		
		<cfsavecontent variable="my.xsl"><cfoutput>
			<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
				<xsl:output method="text" />
				
				<xsl:template match="/*/rule[@ruleid='#xmlformat(arguments.ruleid)#']/criteria[#arguments.criteria#]">
					#my.rc.describe(ruleid,criteria,ruleContext,locale)#
				</xsl:template>
				
				<!--- automatically remove any unwanted xml text from other rule and criteria nodes --->
				<xsl:template match="/*/rule[@ruleid!='#xmlformat(arguments.ruleid)#']" />
				<xsl:template match="/*/rule[@ruleid='#xmlformat(arguments.ruleid)#']/criteria[position()!=#arguments.criteria#]" />
			</xsl:stylesheet>
		</cfoutput></cfsavecontent>
		
		<cfreturn my.xsl>
	</cffunction>
	
	<cffunction name="getDefaultLocale" access="private" output="false" returntype="string">
		<cfreturn getTap().getLocal().language>
	</cffunction>
	
	<cffunction name="describeCriteria" returntype="string" access="public" output="false" 
	hint="returns a text description of a specified rule criteria node">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="criteria" type="string" required="true">
		<cfargument name="ruleContext" type="any" required="false" default="#this.getValue('ruleContext')#">
		<cfargument name="locale" type="string" required="false" default="#this.getValue('locale')#">
		
		<cfset var my = structnew()>
		<cfif not len(trim(arguments.locale))><cfset arguments.locale = getDefaultLocale()></cfif>
		<cfset my.description = getRuleCache(arguments.ruleid,arguments.criteria,arguments.locale)>
		
		<cfif not len(trim(my.description))>
			<cfinvoke method="getDescriptionXSL" argumentcollection="#arguments#" returnvariable="my.xsl" />
			<cfset my.description = transform(my.xsl,false)>
			<cfset setRuleCache(arguments.ruleid,arguments.criteria,arguments.locale,my.description)>
		</cfif>
		
		<cfreturn my.description>
	</cffunction>
	
	<cffunction name="describeRule" returntype="struct" access="public" output="false" 
	hint="returns the description provided for a rule or the sum of its criteria descriptions">
		<cfargument name="ruleid" type="string" required="true">
		<cfargument name="ruleContext" type="any" required="false" default="#this.getValue('ruleContext')#">
		<cfargument name="locale" type="string" required="false" default="">
		<cfset var htlib = getLib().html>
		<cfset var my = structnew()>
		<cfset var x = 0>
		<cfset var rscriteria = getCriteriaQuery(arguments.ruleid,ruleContext,locale)>
		<cfset var ruleNode = getRuleNode(arguments.ruleid)>
		<cfset var result = "" />
		
		<cfset my.html = htlib.new("span")>
		<cfset my.segment = htlib.new("span")>
		<cfset htlib.childAdd(my.html,my.segment)>
		
		<cfloop query="rscriteria">
			<cfset result = testCriteria(rulenode.xmlChildren[currentrow],arguments.ruleContext,false)>
			<cfif isboolean(result)>
				<cfset htlib.childAdd(my.segment,htlib.textNew("%tap_and"))>
				<cfset htlib.childAdd(my.segment,htlib.textNew(rscriteria.description))>
			<cfelse>
				<cfset htlib.childAdd(my.html,htlib.textNew(rscriteria.description))>
				<cfset my.segment = htlib.new("span")>
				<cfset htlib.childAdd(my.html,my.segment)>
			</cfif>
		</cfloop>
		
		<cfset my.span = htlib.elementArray(my.html,structnew(),"span")>
		<cfloop index="x" from="2" to="#arraylen(my.span)#">
			<cfset htlib.childRemove(my.span[x],1)>
			<cfif arraylen(my.span) gt 2>
				<cfset htlib.childAdd(my.span[x],"(",1)>
				<cfset htlib.childAdd(my.span[x],")",0)>
			</cfif>
		</cfloop>
		
		<cfreturn my.html>
	</cffunction>
	
	<cffunction name="setRuleAttribute" access="private" output="false">
		<cfargument name="ruleNode" required="true">
		<cfargument name="attribute" type="string" required="true">
		<cfargument name="atvalue" type="string" required="true">
		<cfset var methodname = "setRule_" & arguments.attribute>
		
		<cfif structkeyexists(variables,methodname) and iscustomfunction(variables[methodname])>
			<cfinvoke method="#methodname#" argumentcollection="#arguments#">
		<cfelse>
			<cfset ruleNode.xmlAttributes[arguments.attribute] = arguments.atValue>
		</cfif>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getRuleQuery" access="public" output="false" returntype="query">
		<cfreturn getValue("RuleQuery")>
	</cffunction>
	
	<cffunction name="getRuleContext" access="public" output="false">
		<cfreturn getValue("RuleContext")>
	</cffunction>
	
	<cffunction name="getRuleAttributes" access="public" output="false" returntype="struct">
		<cfargument name="ruleid" type="string" required="true">
		<cfreturn getRuleNode(ruleid).xmlAttributes>
	</cffunction>
</cfcomponent>
