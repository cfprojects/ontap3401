<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="core">
					<function name="getURL" return="string"  xref="">
						<usage>returns a fully qualified url, usually to a page within the onTap site or application</usage>
						<example>&lt;a href=&quot;#lib.getURL('index.cfm','T')#&quot;&gt;</example>
						<arguments>
							<arg name="path" required="true" type="string|struct" default="n/a">
								the relative path to the target document - 
								this argument is automatically converted to a url-encoded string if a structure is provided</arg>
							<arg name="domain" required="false" type="string" default="">
								indicates the location from which the path argument is relative 
								-- defaults to the current directory or current template 
							</arg>
							<arg name="timeout" required="false" type="numeric" default="<cfoutput>#getTap().getCF().app.timeout_request#</cfoutput>">
								requesttimeout variable to append to the url - a value of zero is not appended</arg>
							<arg name="protocol" required="false" type="string" default="">
								the protocol to use for the requested url, usually http or https - defaults to the protocol of the current request</arg>
							<arg name="anchor" required="false" type="string" default="">
								a fragment anchor-name to apply to the generated url 
							</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfset tReq("core/structToURL")>
	
	<cffunction name="getURL" access="public" output="false" returntype="string">
		<cfargument name="path" type="any" required="true">
		<cfargument name="domain" type="string" required="false">
		<cfargument name="timeout" type="string" required="false">
		<cfargument name="protocol" type="string" required="false">
		<cfargument name="anchor" type="string" required="false">
		
		<cfreturn getTap().getHref().getURL(argumentcollection=arguments)>
	</cffunction>
	
	<cfset tStor("getURL")>
</cfif>

