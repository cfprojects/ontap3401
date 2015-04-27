<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="core">
					<function name="getString" return="string"  xref="">
						<usage>
							represents a given coldfusion variable as a string 
							by returning the variable for simple values and the 
							type of the variable for complex data -- mimics the 
							javascript toString method
						</usage>
						<arguments>
							<arg name="obj" required="true" type="any" default="n/a">the coldfusion variable to convert to a string</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfscript>
		tReq("core/typeof");
	
		function getString(obj) { if (issimplevalue(obj)) { return obj; } else { return this.typeof(obj); } } 
		tStor("getString"); 
	</cfscript>
</cfif>
