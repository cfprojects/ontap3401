<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="core">
					<function name="cfcExtend" return="object"  xref="">
						<usage>
							a utility for adding &quot;mixins&quot; to the current component - 
							imitates the behavior of inheritance allowing CFC's to inherit methods from a 
							CFC targeted via a dynamic path, and/or from multiple parent CFC's 
						</usage>
						<example>
							&lt;cfset getLib().cfcExtend(this,"ontap")&gt; 
						</example>
						<versioninfo>
							<history>
								<change date="2005-05-06">fix for overriding functions</change>
							</history>
						</versioninfo>
						<arguments>
							<arg name="subclass" required="true" type="component" default="n/a">the component to receive inherited methods</arg>
							<arg name="extend" required="false" type="string" default="ontap">the component from which methods should be inherited</arg>
							<arg name="root" required="false" type="string" default="CFC">the root path or path alias from which the extend argument is relative</arg>
							<arg name="brand" required="false" type="boolean" default="true">indicates if branding should be applied to the subclass CFC path</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfset tReq("core/arg,core/argstoarray")>

	<cffunction name="cfcextend" output="false" 
	hint="this method is responsible for mimicking the extends property of the cfcomponent tag to allow a cfc to inherit from a dynamic CFC path or from multiple parent CFC's">
		<cfargument name="subclass" required="true">
		<cfargument name="extend" type="string" required="false" default="ontap">
		<cfargument name="root" type="string" required="false" default="CFC">
		<cfargument name="brand" type="boolean" required="false" default="true">
		<cfargument name="action" type="any" required="false" default="">
		<cfset var myargs = request.tapi.argstoarray(arguments)>
		<cfset var source = false>
		<cfset var extends = false>
		<cfset var extends2 = false>
		<cfset var x = 0>
		
		<cfif not issimpleValue(arguments.action)>
			<cfset arguments.action = "extend">
		</cfif>
		
		<cfswitch expression="#arguments.action#">
			<cfcase value="inherit">
				<cfinvoke component="#arguments.subclass#" subclass="#arguments.subclass#" source="#this#" 
					method="cfcextend" action="inherit_from" private="#variables#">
			</cfcase>
			
			<cfcase value="inherit_from">
				<!--- append the source cfc to the list of components the subclass cfc extends for documentation --->
				<cfparam name="variables.extends" type="array" default="#arrayNew(1)#">
				<cfparam name="private.extends" type="array" default="#arrayNew(1)#">
				<cfloop index="x" from="#arrayLen(private.extends)#" to="1" step="-1">
				<cfset arrayPrepend(variables.extends,private.extends[x])></cfloop>
				<cfset arrayPrepend(variables.extends,arguments.source)>
				<cfset structappend(variables,arguments.private,false)>
			</cfcase>
			
			<cfdefaultcase>
				<cfset source = CreateObject("component",arguments.extend) />
				
				<!--- copy this function into the source CFC to allow it to inject functions into the subclass CFC --->
				<cfset source["cfcextend"] = this.cfcextend>
				<cfset subclass["cfcextend"] = this.cfcextend>
				
				<!--- inject functions and copy properties from the source CFC into the subclass --->
				<cfinvoke component="#source#" method="cfcextend" action="inherit" subclass="#subclass#">
				<cfset structappend(subclass,source,false)>
				<cfif structKeyExists(subclass,"setProperties") and isCustomFunction(subclass.setProperties)
				and structKeyExists(source,"getProperties") and isCustomFunction(source.getProperties)>
					<cfset subclass.setProperties(source.getProperties(),false)>
				</cfif>
				
				<!--- we don't need the cfcextend function anymore --->
				<cfset structdelete(source,"cfcextend")>
				<cfset structdelete(subclass,"cfcextend")>
			</cfdefaultcase>
		</cfswitch>
	</cffunction>
	
	<cfset tStor("cfcextend")>
</cfif>
