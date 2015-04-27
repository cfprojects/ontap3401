<cfcomponent displayname="PluginStore" output="false" extends="ontap" hint="manages a plugin store for remote discovery">
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="pluginList" type="any" required="true" />
		<cfset variables.pluginList = arguments.PluginList />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getAll" access="public" output="false">
		<cfset var plugins = read() />
		<cfif not isXML(plugins)>
			<cfset plugins = XmlParse("<store />") />
		</cfif>
		<cfreturn plugins />
	</cffunction>
	
	<cffunction name="read" access="private" output="false">
		<cfreturn pluginList.read() />
	</cffunction>
	
	<cffunction name="save" access="private" output="false">
		<cfargument name="xml" required="true" />
		<cfreturn pluginList.save(arguments.xml) />
	</cffunction>
	
	<cffunction name="transform" access="private" output="false">
		<cfargument name="xsl" type="string" required="true" />
		<cfreturn XmlTransform(getAll(),xsl) />
	</cffunction>
	
	<cffunction name="search" access="public" output="false">
		<cfargument name="phrase" type="string" required="true" />
		<cfset var xsl = "" />
		<cfset phrase = lcase(trim(phrase)) />
		
		<cfsavecontent variable="xsl">
			<cfoutput>
				<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
					<xsl:output method="xml" indent="no" omit-xml-declaration="yes" />
					
					<xsl:variable name="lcase" select="'abcdefghijklmnopqrstuvwxyz'" />
					<xsl:variable name="ucase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
					<xsl:variable name="tap" select="'xml.tapogee.com'" />
					<xsl:variable name="phrase" select="'#htmleditformat(phrase)#'" />
					
					<xsl:template match="/store">
						<xsl:copy>
							<xsl:copy-of select="./*[contains(translate(@name,$ucase,$lcase),$phrase) 
							or contains(translate(@pluginid,$ucase,$lcase),$phrase) 
							or contains(translate(@description,$ucase,$lcase),$phrase) 
							or contains(translate(@providerName,$ucase,$lcase),$phrase) 
							or contains(translate(@providerURL,$ucase,$lcase),$phrase)]" />
						</xsl:copy>
					</xsl:template>
				</xsl:stylesheet>
			</cfoutput>
		</cfsavecontent>
		
		<cflock type="readonly" name="ontap.pluginstore" timeout="5">
			<cfreturn xmlparse(transform(xsl)) />
		</cflock>
	</cffunction>
	
	<cffunction name="removePlugin" access="public" output="false">
		<cfargument name="pluginid" type="string" required="true" />
		<cfset var xsl = "" />
		<cfset phrase = lcase(trim(phrase)) />
		
		<cfsavecontent variable="xsl">
			<cfoutput>
				<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
					<xsl:output method="xml" indent="no" omit-xml-declaration="yes" />
					<xsl:template match="/">
						<xsl:copy>
							<xsl:copy-of select="@*" />
							<xsl:copy-of select="./*[pluginid!='#htmleditformat(lcase(trim(pluginid)))#')" />
						</xsl:copy>
					</xsl:template>
				</xsl:stylesheet>
			</cfoutput>
		</cfsavecontent>
		
		<cflock type="exclusive" name="ontap.pluginstore" timeout="5">
			<cfset save(transform(xsl)) />
		</cflock>
	</cffunction>
	
	<cffunction name="addPlugin" access="public" output="false">
		<cfargument name="pluginid" type="string" required="true" />
		<cfargument name="name" type="string" required="true" />
		<cfargument name="version" type="string" required="true" />
		<cfargument name="description" type="string" required="true" />
		<cfargument name="providerName" type="string" required="true" />
		<cfargument name="releaseDate" type="date" required="false" default="#now()#" />
		<cfargument name="edition" type="string" required="false" default="" />
		<cfargument name="revision" type="string" required="false" default="" />
		<cfargument name="buildnumber" type="string" required="false" default="" />
		<cfargument name="providerURL" type="string" required="false" default="" />
		<cfargument name="providerEmail" type="string" required="false" default="" />
		<cfset var loc = structNew() />
		<cfset var x = 0 />
		
		<cfset arguments.pluginid = trim(lcase(arguments.pluginid)) />
		<cfset arguments.releaseDate = dateformat(arguments.releasedate,"yyyy-mm-dd") />
		<cfset removePlugin(arguments.pluginid) />
		
		<cflock type="exclusive" name="ontap.pluginstore" timeout="5">
			<cfset loc.xml = getAll() />
			<cfset loc.node = XmlElemNew(loc.xml,"plugin") />
			
			<cfloop item="x" collection="#arguments#">
				<cfset loc.node.xmlAttributes[lcase(x)] = arguments[x] />
			</cfloop>
			
			<cfset arrayAppend(loc.xml.store.xmlChildren,loc.node) />
			
			<cfset save(loc.xml) />
		</cflock>
		
	</cffunction>
	
</cfcomponent>

