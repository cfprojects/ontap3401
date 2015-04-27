<cfcomponent displayname="plugin" extends="ontap" hint="an abstract class from which plugin objects should be extended">
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="pluginManager" type="any" required="true" />
		<cfset variables.pluginManager = arguments.pluginManager />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" output="false" returntype="void" hint="this is where your plugin should be configured post-init if necessary">
	</cffunction>
	
	<cffunction name="setInstallationStatus" access="public" output="false" hint="announces that a given plugin has finished installing or uninstalling">
		<cfargument name="installed" type="boolean" required="true" />
		<cfset var mgr = getPluginManager() />
		
		<cfif installed>
			<cfset mgr.announceInstall(this) />
		<cfelse>
			<cfset mgr.announceUninstall(this) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="isInstalled" access="public" output="false" returntype="boolean">
		<cfreturn checkDependency(getValue("source"),getValue("version"),getValue("buildnumber"),getValue("releasedate")) />
	</cffunction>
	
	<cffunction name="checkDependency" access="public" output="false" returntype="boolean">
		<cfargument name="plugin" type="string" required="true" />
		<cfargument name="version" type="string" required="false" default="0" />
		<cfargument name="buildnumber" type="string" required="false" default="0" />
		<cfargument name="releasedate" type="string" required="false" default="" />
		<cfreturn getPluginManager().isInstalled(plugin,version,buildnumber,releasedate) />
	</cffunction>
	
	<cffunction name="getWizardIndex" access="public" output="false" returntype="struct">
		<cfargument name="html" type="struct" required="true">
		<cfreturn html>
	</cffunction>
	
	<cffunction name="getPluginManager" access="public" output="false">
		<cfreturn variables.pluginManager />
	</cffunction>
</cfcomponent>
