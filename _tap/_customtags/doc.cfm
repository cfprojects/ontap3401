<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">

	<cf_doc>
		<spec>
			<library name="core">
				<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" return="string" xref="">
					<usage>displays documentation for framework tags and libraries</usage>
					<attributes>
						<attribute name="xml" required="false" type="boolean" default="false">
							indicates if the tag should return HTML or the original XML SPEC packet
						</attribute>
					</attributes>
				</tag>
			</library>
		</spec>
	</cf_doc>

<cfelse>
	<cfset structAppend(attributes,caller.attributes,false) />
	<cfif not thistag.hasendtag>
		<cfthrow type="onTap.framework.tag.documentation" message="the cf_doc tag requires an end-tag" />
	<cfelseif thistag.executionmode is "end" and not attributes.xml>
		<cfinclude template="/cfc/mixin/tap.cfm" />
		<cfset thistag.generatedcontent = getLib().tdoc(thistag.generatedcontent) />
	<cfelseif thistag.executionmode is "start">
		<cfset temp = "" />
		<cfloop condition="not len(trim(temp))">
			<cfsavecontent variable="temp">x</cfsavecontent>
			<cfsetting enablecfoutputonly="false" />
		</cfloop>
	</cfif>
</cfif>
