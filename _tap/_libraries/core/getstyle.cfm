<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="core">
					<function name="getStyle" return="string"  xref="">
						<usage>returns a complete style sheet link tag</usage>
						<example>&lt;img src=&quot;#this.getStyle('default')#&quot;&gt;</example>
						<arguments>
							<arg name="href" required="true" type="string" default="n/a">relative path to the target template from the specified directory -- may exclude the .css extension</arg>
							<arg name="baseurl" required="false" type="string" default="S">the root path from which the href argument is relative</arg>
							<arg name="media" required="false" type="string" default="screen">indicates the medium for which the style sheet should be applied</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfscript>
		function getstyle(href) { 
			var baseurl = this.arg(arguments,2,"style"); 
			var media = this.arg(arguments,3,"screen"); 
			href = REREplaceNoCase(href,"^(\.css)$",".css"); 
			return "<link rel=""stylesheet"" type=""text/css"" href=""#this.getURL(href,baseurl,0)#"" media=""#media#"" />"; 
		} tStor("getstyle"); 
	</cfscript>
</cfif>

