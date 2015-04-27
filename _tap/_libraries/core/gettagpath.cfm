<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="core">
					<function name="getTagPath" return="string"  xref="core/tag">
						<usage>
							returns an absolute path to the file executed by a specified custom tag call 
						</usage>
						<example>&quot;cfinclude template=&quot;#getFS().getPathTo(this.getTagPath('mytag'))#&quot;&gt;</example>
						<arguments>
							<arg name="tagname" required="true" type="string" default="n/a">the custom tag file name</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfscript>
		function getTagPath(tagname) { return getTap().getCF().getTagPath(tagname); } 
		tStor("getTagPath"); 
	</cfscript>
</cfif>

