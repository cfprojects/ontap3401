<cfcomponent displayname="ruleCriteria.Or (Criteria Segment Delimiter)" output="false" extends="criteria" 
hint="allows a rule to contain an 'or' condition 
- all criteria before or after the the segment delimiter must be true to apply the rule">
	<cfset setProperty("hasForm",false)>
	
	<cffunction name="test" returntype="string" output="false">
		<cfreturn "or">
	</cffunction>
	
	<cffunction name="appliesToContext" returntype="boolean" output="false">
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getXML" output="false">
		<cfreturn "<criteria type=""#this.getValue('classpath')#"" />">
	</cffunction>
	
	<cffunction name="describe" output="false">
		<cfargument name="ruleid" type="string" required="true" default="">
		<cfargument name="criteria" type="numeric" required="true" default="0">
		<cfargument name="ruleContext" type="any" required="false" default="">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfreturn getResourceBundle(locale).describe>
	</cffunction>
</cfcomponent>
