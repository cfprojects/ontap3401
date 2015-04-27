<cfsilent>
	<cfif getCurrentTemplatePath() is getBaseTemplatePath()><cfabort></cfif>
	
	<!--- include the file system library 
	-- this library unfortunately can't be placed in any cfc's 
	due to inconsistent behavior from getCurrentTemplatePath() 
	and a total lack of alternatives in ColdFusion --->
	<cfmodule template="fslib.cfm" />
	
	<!--- create a basic config.cfc if there isn't one already --->
	<cfset tempfile = getdirectoryfrompath(getcurrenttemplatepath()) & "config.cfc">
	<cfif not fileexists(tempfile)>
		<cffile action="copy" destination="#tempfile#" source="#rereplace(tempfile,'config\.cfc$','defaultconfig.cfc')#" />
	</cfif>
	
	<!--- this setting can be overridden by the config.cfc --->
	<cfsetting enablecfoutputonly="true">
	
	<!--- launch the framework --->
	<cfset request.tap = CreateObject("component","config").init() />
	<cfset attributes = request.tap.getAttributes() />
</cfsilent>
