<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="core">
					<function name="fixBaseTagList" return="list"  xref="" deprecated="2012-04-24">
						<usage>returns the value of getBaseTagList() consistent with ColdFusion 5 (cfmodule tags are returnd as cf_tagname instead of ../../tagname) 
							- deprecated because it stopped working on ColdFusion 9 within the context of the library CFC and in the core framework had only been used in CF_MAIL 
						</usage>
						<example>var listtags = this.fixbasetaglist();</example>
						<versioninfo>
							<history>
								<change date="2003-09-27">Created</change>
							</history>
						</versioninfo>
						<arguments></arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfscript>
		function fixbasetaglist() { 
			return rereplacenocase(listchangedelims(getbasetaglist(),"/","\/"),"(CF_)[^,]*/([^,$]+)(,|$)","\1\2\3","ALL"); 
		} tStor("fixbasetaglist"); 
	</cfscript>
</cfif>
