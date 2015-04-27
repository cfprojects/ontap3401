<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">

	<cf_doc>
			<spec>
				<library name="core">
					<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" return="any" xref="core/return">
						<usage>
							used as a cfinclude at the end of other custom tags to standardize 
							return values from custom tags -- can be accessed with #getFS().return()#
						</usage>
						<example>
							&lt;cfinclude template=&quot;/cfc/mixin/tap.cfm&quot; /&gt;
							...
							&lt;cfinclude template=&quot;#getFS().return(mydata)#&quot; /&gt;
						</example>
						<attributes>
							<attribute name="variables.returnvalue" required="true" type="any" default="n/a">
								the data to return to the specified scope and variable name
								-- this template is not a custom tag, it is included in other custom tags with cfinclude, 
								the variable #variables.returnvalue# must be set before including this template 
								in order to return a value from the custom tag 
							</attribute>
							<cfinclude template="docs/returnattributes.cfm">
						</attributes>
					</tag>
				</library>
			</spec>
		</cf_doc>

<cfelse>
	<cfparam name="attributes.scope" type="any" default="CALLER">
	<cfparam name="attributes.return" type="string" default="">
	<cfparam name="variables.returnvalue" type="any" default="">
	
	<cfif len(trim(attributes.return))>
		<cfif not isstruct(attributes.scope)>
			<cfset attributes.scope = evaluate(attributes.scope) />
		</cfif>
		<cfset attributes.scope[attributes.return] = variables.returnvalue>
	</cfif>
	
	<cfset thistag.generatedcontent = "" />
	<cfexit method="exittag" />
</cfif>
