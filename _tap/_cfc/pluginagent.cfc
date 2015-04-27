<cfcomponent displayname="PluginStore" output="false" extends="ontap" hint="provides the ability to search and install plugins from remote servers">
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="serverList" type="any" required="true" />
		<cfset variables.serverList = arguments.serverList />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getServers" access="public" output="false">
		<cfset var stores = serverList.read() />
		
		<cfif not isXmlDoc(stores)>
			<cfset stores = XmlParse("<stores><server serverid=""tapogee"" uri=""http://on.tapogee.com/pluginstore.cfc?wsdl"" /></stores>") />
		</cfif>
		
		<cfreturn stores />
	</cffunction>
	
	<cffunction name="parsePluginsFromServiceCall" access="private" output="false">
		<cfargument name="serviceURI" type="string" required="true" />
		<cfargument name="result" type="any" required="true" />
		<cfset var xsl = "" />
		
		<cftry>
			<cfif isSimpleValue(result)><cfset result = XmlParse(result) /></cfif>
			<cfif isDefined("result.response.fault")><cfreturn "" /></cfif>
			
			<cfsavecontent variable="xsl">
				<cfoutput>
					<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
						<xsl:output method="xml" indent="no" omit-xml-declaration="yes" />
						<xsl:template match="/">
							<xsl:for-each select="response/result/plugin">
								<xsl:copy>
									<xsl:copy-of select="@*" />
									<xsl:attribute name="serviceuri"><![CDATA[#arguments.serviceURI#]]></xsl:attribute>
									<xsl:copy-of select="./*" />
								</xsl:copy>
							</xsl:for-each>
						</xsl:template>
					</xsl:stylesheet>
				</cfoutput>
			</cfsavecontent>
			
			<cfreturn XmlTransform(result,xsl) />
			
			<cfcatch><cfreturn "" /></cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getAllFromStore" access="private" output="false" returntype="string">
		<cfargument name="serviceURI" type="string" required="true" />
		<cfset var result = "" />
		<cfset var ws = "" />
		<cftry>
			<cfset result = parsePluginsFromServiceCall(serviceURI,CreateObject("webservice",serviceURI).getAll()) />
			<cfcatch>
				<cfset result = "" />
			</cfcatch>
		</cftry>
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getAll" access="public" output="false" returntype="string">
		<cfset var store = getServers().stores.xmlChildren />
		<cfset var result = "" />
		<cfset var x = 0 />
		
		<cfsavecontent variable="result">
			<pluginlist>
				<cfloop index="x" from="1" to="#ArrayLen(store)#">
					<cfset writeoutput(getAllFromStore(store[x].xmlAttributes.uri)) />
				</cfloop>
			</pluginlist>
		</cfsavecontent>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="SearchStore" access="private" output="false" returntype="string">
		<cfargument name="serviceURI" type="string" required="true" />
		<cfargument name="phrase" type="string" required="true" />
		<cfset var result = "" />
		<cfset var ws = "" />
		
		<cftry>
			<cfset result = parsePluginsFromServiceCall(serviceURI,CreateObject("webservice",serviceURI).search(phrase)) />
			<cfcatch><cfset result = "" /></cfcatch>
		</cftry>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="Search" access="public" output="false" returntype="string">
		<cfargument name="phrase" type="string" required="true" />
		<cfset var store = getServers().stores.xmlChildren />
		<cfset var result = "" />
		<cfset var x = 0 />
		
		<cfsavecontent variable="result">
			<pluginlist>
				<cfloop index="x" from="1" to="#ArrayLen(store)#">
					<cfset writeoutput(SearchStore(store[x].xmlAttributes.uri,phrase)) />
				</cfloop>
			</pluginlist>
		</cfsavecontent>
		
		<cfreturn trim(result) />
	</cffunction>
	
	<cffunction name="findPlugin" access="public" output="false" returntype="array" hint="returns an array of servers which have the requested plugin">
		<cfargument name="pluginid" type="string" required="true" />
		<cfset var result = search(pluginid) />
		<cfset var x = 0 />
		
		<cftry>
			<cfset result = XmlSearch(result,"//plugin[@pluginid='#xmlformat(lcase(pluginid))#']") />
			<cfloop index="x" from="1" to="#ArrayLen(result)#">
				<cfset result[x] = result[x].xmlAttributes.serviceuri />
			</cfloop>
			
			<cfcatch>
				<cfset result = arrayNew(1) />
			</cfcatch>
		</cftry>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getPlugin" access="public" output="false">
		<cfargument name="serviceURI" type="string" required="true" />
		<cfargument name="pluginid" type="string" required="true" />
		<cfset var result = CreateObject("webservice",arguments.serviceURI).getPlugin(pluginid) />
		<cfset result = xmlParse(result).response.result />
		<cfset result = savePluginArchive(pluginid,toBinary(result.data.XmlText)) />
		<cfreturn importPlugin(pluginid,result) />
	</cffunction>
	
	<cffunction name="savePluginArchive" access="private" output="false">
		<cfargument name="pluginid" type="string" required="true" />
		<cfargument name="archive" type="binary" required="true" />
		<cffile action="write" file="#expandpath('/plugins/' & pluginid & '.zip')#" output="#arguments.archive#" />
		<cfreturn CreateObject("component","cfc.file").init(pluginid & ".zip",expandpath("/plugins"),"zip") />
	</cffunction>
	
	<cffunction name="getPluginManager" access="private" output="false">
		<cfreturn getIoC().getContainer("plugins") />
	</cffunction>
	
	<cffunction name="importPlugin" access="private" output="false">
		<cfargument name="pluginid" type="string" required="true" />
		<cfargument name="archive" type="any" required="true" />
		<cfset var mgr = getPluginManager() />
		<cfset mgr.importPluginArchive(archive) />
		<cfreturn mgr.getPluginObject(pluginid) />
	</cffunction>
	
	<cffunction name="save" access="private" output="false">
		<cfargument name="xml" required="true" />
		<cfreturn serverList.save(arguments.xml) />
	</cffunction>
	
	<cffunction name="transform" access="private" output="false">
		<cfargument name="xsl" type="string" required="true" />
		<cfreturn XmlTransform(getAll(),xsl) />
	</cffunction>
	
	<cffunction name="removeStore" access="public" output="false">
		<cfargument name="serverid" type="string" required="true" />
		<cfset var xsl = "" />
		<cfset phrase = lcase(trim(phrase)) />
		
		<cfsavecontent variable="xsl">
			<cfoutput>
				<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
					<xsl:output method="xml" indent="no" omit-xml-declaration="yes" />
					<xsl:template match="/">
						<xsl:copy>
							<xsl:copy-of select="@*" />
							<xsl:copy-of select="./*[serverid!='#htmleditformat(lcase(trim(serverid)))#')" />
						</xsl:copy>
					</xsl:template>
				</xsl:stylesheet>
			</cfoutput>
		</cfsavecontent>
		
		<cflock type="exclusive" name="ontap.pluginservers" timeout="5">
			<cfset save(transform(xsl)) />
		</cflock>
	</cffunction>
	
	<cffunction name="addStore" access="public" output="false">
		<cfargument name="serviceURI" type="string" required="true" />
		<cfset var my = structNew() />
		<cfset var x = 0 />
		
		<cfset arguments.serviceURI = trim(lcase(serviceURI)) />
		<cfset removeStore(serviceURI) />
		
		<cflock type="exclusive" name="ontap.pluginservers" timeout="5">
			<cfset my.xml = getServers() />
			<cfset my.node = XmlElemNew(my.xml,"server") />
			<cfset my.node.xmlAttributes["uri"] = arguments.serviceURI />
			<cfset arrayAppend(my.xml.stores.xmlChildren,my.node) />
			<cfset save(my.xml) />
		</cflock>
	</cffunction>
	
</cfcomponent>

