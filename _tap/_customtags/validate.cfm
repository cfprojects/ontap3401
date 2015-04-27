<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">
	
	<cf_doc>
			<spec>
				<library name="mx">
					<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" return="struct|string" xref="">
						<usage>
							Validates an html form and executes contained coldfusion code only if the form validates 
						</usage>
						<example>&lt;cf_validate form=&quot;#myform#&quot;&gt;&lt;cfset myObject.Update(attributes)&gt;&lt;cf_validate&gt;</example>
						<attributes>
							<attribute name="form" required="true" type="struct" default="n/a">an html form created using the framework html libraries or xhtml tags</attribute>
							<attribute name="scope" required="false" type="struct" default="#attributes#">a structure containing data to compare against the form validators</attribute>
						</attributes>
					</tag>
				</library>
			</spec>
		</cf_doc>
<cfelse>
	<cfparam name="attributes.form" type="struct" />
	<cfparam name="attributes.scope" type="struct" default="#iif(structKeyExists(caller,'attributes'),'caller.attributes','form')#" />
	
	<cfif thistag.executionmode is "start">
		<cfinclude template="/cfc/mixin/tap.cfm" />
		<cfset valid = getLib().html.formValidate(attributes.form,false,"",attributes.scope) />
		
		<cfif isArray(valid)>
			<cfif ArrayLen(valid)>
				<cf_html>
					<cfoutput>
						<div class="tap_errors">
							<cfloop index="x" from="1" to="#ArrayLen(valid)#">
								<div>#htmleditformat(valid[x])#</div>
							</cfloop>
						</div>
					</cfoutput>
				</cf_html>
				<cfset valid = false />
			<cfelse>
				<cfset valid = true />
			</cfif>
		</cfif>
		
		<cfif not valid><cfexit method="exittag" /></cfif>
	</cfif>
</cfif>

