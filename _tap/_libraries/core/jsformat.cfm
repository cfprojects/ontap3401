<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="core">
					<function name="jsFormat" return="string"  xref="">
						<usage>
							resolves an oversight in the ColdFusion native jsstringformat function 
							allowing the string &lt;/script&gt; to be included in javascript literals
						</usage>
						<versioninfo>
							<history>
								<change date="2003-01-01">function created</change>
								<change date="2003-01-15">added semicolon to the list of escaped characters -- used in new function dom/js.normalize</change>
							</history>
						</versioninfo>
						<arguments>
							<arg name="mystring" required="true" type="string" default="n/a">the string to format for use as a javascript literal</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfscript>
		function jsFormat(mystring) { return replacelist(jsstringformat(mystring),"/,;","\/,\;"); } 
		tStor("jsFormat"); 
	</cfscript>
</cfif>
