<cfcomponent displayname="ruleCriteria.Language" output="false" extends="locale">
	<cfset setProperty("formatArray",listtoarray("within,!within"))>
	
	<cffunction name="getLocaleQuery" returntype="query" access="private" output="false">
		<cfargument name="ruleContext" required="true">
		<cfset var qry = getLib().locale.query(ruleContext.getValue("LanguageRulesUseLanguages"))>
		<cfquery name="qry" dbtype="query" debug="false">
			select * from qry where [locale] = [language] 
		</cfquery><cfreturn qry>
	</cffunction>
</cfcomponent>

