<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="core">
					<function name="call" return="any"  xref="">
						<usage>
							Calls a specified coldfusion function with a specified array of arguments
							-- used primarily to create wrapper functions -- returns the returned value from the called function
						</usage>
						<arguments>
							<arg name="fname" required="true" type="string" default="n/a">the name of the function to call</arg>
							<arg name="args" required="true" type="array" default="n/a">the array of arguments for the called function</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfscript>
		function call(fname,args) { 
			var x = 1; var arglist = ""; var alen = arraylen(args); 
			for (x = 1; x lte alen; x = x + 1) { arglist = listappend(arglist,"args[#x#]"); } 
			if (this.hasFunction(fname)) { fname = "this." & listlast(fname,"."); } 
			return evaluate("#fname#(#arglist#)"); 
		} tStor("call"); 
	</cfscript>
</cfif>

