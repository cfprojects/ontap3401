<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="core">
					<function name="arg" return="any"  xref="">
						<usage>returns an optional argument for another tapi function</usage>
						<arguments>
							<arg name="args" required="true" type="array" default="n/a">the array containing arguments, for the tapi function, usually the native arguments array</arg>
							<arg name="item" required="true" type="integer" default="n/a">the index of the optional argument in the arguments array</arg>
							<arg name="def" required="true" type="string" default="n/a">the default value of the specified argument</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
</cfif>
