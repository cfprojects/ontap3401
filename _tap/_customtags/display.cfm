<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">
	
	<cf_doc>
			<spec>
				<library name="mx">
					<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" return="n/a" xref="">
						<usage>
							displays html content stored in a variable 
							- either the html or text attribute are required 
						</usage>
						<example>&lt;cf_html return=&quot;content&quot;&gt;&lt;div&gt;Hello World!&lt;/div&gt;&lt;/cf_html&gt;
						&lt;cf_display html=&quot;#content#&quot;&gt;</example>
						<attributes>
							<attribute name="html" required="false" type="struct" default="n/a">html content to display</attribute>
							<attribute name="text" required="false" type="struct" default="n/a">same as the html attribute - use text to indicate that a text representation of the html should be displayed - useful for email</attribute>
							<attribute name="gateway" required="false" type="struct" default="n/a">indicates that html content should be returned via a gateway element</attribute>
						</attributes>
					</tag>
				</library>
			</spec>
		</cf_doc>
<cfelse>
	<cfinclude template="/cfc/mixin/tap.cfm" />
	
	<cfparam name="attributes.gateway" type="string" default="#getLib().arg(url,'csgate','')#">
	<cfif structKeyExists(attributes,"html") and structKeyExists(attributes,"text")>
		<cfthrow type="ontap.html.display.ambiguous" message="You can only provide the html or text attribute to the cf_display tag">
	</cfif>
	
	<cfoutput>
		<cfif structKeyExists(attributes,"html")>
			<cfif len(trim(attributes.gateway))>
				#getLib().html.gatewayrespond(attributes.html,attributes.gateway)# 
			<cfelse>
				#getLib().html.show(attributes.html)#				
			</cfif>
		<cfelseif structKeyExists(attributes,"text")>
			#getLib().html.showText(attributes.text)#
		</cfif>
	</cfoutput>
	<cfexit method="exittag" />
</cfif>

