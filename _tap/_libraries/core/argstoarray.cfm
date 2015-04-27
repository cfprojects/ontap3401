<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="core">
					<function name="argsToArray" return="array"  xref="core/call">
						<usage>
							returns an array created from the arguments object
							-- allows the use of array functions on the returned array, 
							which is not allowed on the argument object in recent versions of ColdFusion 
						</usage>
						<example>var args = this.argstoarray(arguments);</example>
						<versioninfo>
							<history>
								<change date="2003-03-10">Created</change>
								<change date="2005-11-27">moved method into the libMan.cfc object</change>
							</history>
						</versioninfo>
						<arguments>
							<arg name="arguments" required="true" type="unknown" default="n/a">the arguments &quot;array&quot; of another function</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
</cfif>
