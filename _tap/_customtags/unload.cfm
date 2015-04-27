<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">

	<cf_doc>
			<spec>
				<library name="core">
					<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" xref="">
						<usage>
							adds arbitrary javascript to the onunload event of an html page 
							- this tag will only work in the _htmlhead stage of the request 
						</usage>
						<example>&lt;cf_unload&gt;alert(&quot;hello world&quot;)&lt;/cf_unload&gt;</example>
						<attributes></attributes>
					</tag>
				</library>
			</spec>
		</cf_doc>
<cfelse>
	<cfswitch expression="#thistag.executionmode#">
		<cfcase value="start">
			<cf_outputonly enable="false" return="outonly" />
		</cfcase>
		
		<cfcase value="end">
			<cfinclude template="/cfc/mixin/tap.cfm" />
			<cfparam name="outonly" default="0" />
			<cfif outonly><cf_outputonly enable="true" repeat="#outonly#" /></cfif>
			<cfset getTap().getPage().eventAdd("onunload",thistag.generatedcontent)>
			<cfset getTap().getPage().eventAdd("onbeforeunload",thistag.generatedcontent)>
			<cfset thistag.generatedcontent = "">
		</cfcase>
	</cfswitch>
</cfif>
