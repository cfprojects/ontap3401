<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="core">
					<function name="cfcExists" return="boolean"  xref="">
						<usage>returns true if a template exists for a specified CFC</usage>
						<example>&lt;cfif this.cfcExists('process','cfc')&gt;...do stuff...&lt;/cfif&gt;</example>
						<arguments>
							<arg name="cfcPath" required="true" type="string" default="n/a">a relative path to the CFC from the root path specified by the rootpath attribute</arg>
							<arg name="rootPath" required="false" type="string" default="CFC">the root path or path alias from which the cfcPath attribute is relative -- defaults to the framework CFC directory</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>	
	<cffunction name="cfcexists" returntype="boolean" output="false" 
	hint="returns true if a template exists for a specified CFC">
		<cfargument name="cfcPath" type="string" required="true">
		
		<cfset var d = getTap().getOS().pathdelimiter>
		<cfset var fullpath = expandpath("/" & listchangedelims(arguments.cfcpath,d,"\/.")) />
		<cfreturn fileexists(rereplace(fullpath,"([\\/]cfc)?$",".cfc"))>
	</cffunction>
	
	<cfset tStor("cfcexists")>
</cfif>

