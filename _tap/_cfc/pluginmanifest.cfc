<cfcomponent displayname="PluginRegister" output="false" extends="ontap" 
hint="manages the list of plugins that are currently installed w/ version information">
	<cfset variables.lockname = "tap.pluginmanager.manifest" />
	<cfset variables.storedAttributes = "version,revision,releasedate,buildnumber" />
	
	<cffunction name="init" access="public" output="false">
		<cfset variables.manifest = CreateObject("component","file").init("pluginmanager/manifest.xml.cfm","inc","xml") />
		<cfif not manifest.exists()>
			<cfset variables.manifest.write(getDefaultManifest()) />
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getDefaultManifest" access="private" output="false">
		<cfset var result = "" />
		<cfsavecontent variable="result"><cfoutput>
<manifest>
	<plugin source="ontapframework" />
	<plugin source="pluginmanager" />
</manifest>
		</cfoutput></cfsavecontent>
		<cfreturn trim(result) />
	</cffunction>
	
	<cffunction name="getXML" access="private" output="false">
		<cfset var xml = "">
		<cflock name="#variables.lockname#" type="exclusive" timeout="10">
			<cfif structKeyExists(variables,"xml")>
				<cfreturn variables.xml />
			<cfelse>
				<cfset xml = variables.manifest.read() />
				<cfset variables.xml = xml />
				<cfreturn xml />
			</cfif>
		</cflock>
	</cffunction>
	
	<cffunction name="save" access="private" output="false">
		<cfset variables.manifest.write(variables.xml) />
	</cffunction>
	
	<cffunction name="newPlugin" access="private" output="false">
		<cfreturn XmlElemNew(variables.xml,"plugin") />
	</cffunction>
	
	<cffunction name="install" access="public" output="false">
		<cfargument name="plugin" type="any" required="true" hint="plugin object installed" />
		<cfset var xml = getXML() />
		<cfset var node = newPlugin() />
		<cfset var x = 0 />
		
		<cfloop index="x" list="source,#variables.storedAttributes#">
			<cfset node.xmlAttributes[x] = plugin.getValue(x) />
		</cfloop>
		
		<cfset node.xmlAttributes.source = lcase(node.xmlAttributes.source) />
		
		<cflock name="#variables.lockname#" type="exclusive" timeout="10">
			<cfset removeNode(node.xmlAttributes.source) />
			<cfset ArrayAppend(xml.manifest.xmlChildren,node) />
			<cfset variables.save() />
		</cflock>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="removeNode" access="public" output="false">
		<cfargument name="source" type="string" required="true" hint="canonical path to the removed plugin" />
		<cfset var xml = getXML() />
		<cfset var mfst = xml.manifest />
		<cfset var x = 0 />
		
		<cfloop index="x" from="1" to="#ArrayLen(mfst.xmlChildren)#">
			<cfif mfst.xmlChildren[x].xmlAttributes.source is arguments.source>
				<cfset arrayDeleteAt(mfst.xmlChildren,x) />
				<cfbreak />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="Uninstall" access="public" output="false">
		<cfargument name="source" type="string" required="true" hint="canonical path to the removed plugin" />
		
		<cflock name="#variables.lockname#" type="exclusive" timeout="10">
			<cfset removeNode(arguments.source) />
			<cfset variables.save() />
		</cflock>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="findPlugin" access="private" output="false" returntype="array">
		<cfargument name="source" type="string" required="true" />
		<cfset var xml = getXML() />
		<cfreturn XMLSearch(xml,"/manifest/plugin[@source='#lcase(source)#']") />
	</cffunction>
	
	<cffunction name="getPluginNode" access="private" output="false">
		<cfargument name="source" type="string" required="true" />
		<cfset var search = findPlugin(source) />
		<cfset var plugin = newPlugin() />
		
		<cfif arrayLen(search) eq 1>
			<cfset plugin = search[1] />
		<cfelse>
			<cfset plugin.xmlAttributes["source"] = lcase(arguments.source) />
		</cfif>
		
		<cfreturn plugin />
	</cffunction>
	
	<cffunction name="hasPlugin" access="public" output="false" returntype="boolean">
		<cfargument name="source" type="string" required="true" />
		<cfset var plugin = findPlugin(source) />
		<cfreturn iif(arrayLen(plugin),true,false) />
	</cffunction>
	
	<cffunction name="getPluginData" access="public" output="false" returntype="struct">
		<cfargument name="source" type="string" required="true" />
		<cfset var data = structNew() />
		<cfset structAppend(data,getPluginNode(arguments.source).xmlAttributes) />
		<cfreturn data />
	</cffunction>
	
	<cffunction name="getAll" access="public" output="false" returntype="struct" 
	hint="returns a structure containing version information for all installed plugins">
		<cfset var result = structNew() />
		<cfset var xml = getXML() />
		<cfset var mfst = xml.manifest />
		<cfset var source = "" />
		<cfset var data = "" />
		
		<cflock name="#variables.lockname#" type="exclusive" timeout="10">
			<cfloop index="x" from="1" to="#ArrayLen(mfst.xmlChildren)#">
				<cfset data = structNew() />
				<cfset structAppend(data,mfst.xmlChildren[x].xmlAttributes) />
				<cfset source = data.source />
				<cfset structDelete(data,"source") />
				<cfset result[source] = data />
			</cfloop>
		</cflock>
		
		<cfreturn result />
	</cffunction>
</cfcomponent>
