<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">

	<cf_doc>
			<spec>
				<library name="core">
					<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" return="any" xref="html.cfm">
						<usage>
							disables the enablecfoutputonly setting created using the cfsetting tag 
							- this allows other tags such as the cf_html tag to disable the cfoutputonly 
							setting for the duration of their sub-tags 
						</usage>
						<example>
							&lt;cfif thistag.executionmode is &quot;start&quot;&gt;
								&lt;cf_outputonly enable=&quot;false&quot; return=&quot;outonly&quot;&gt;
							&lt;cfelse&gt;
								&lt;cf_outputonly enable=&quot;true&quot; repeat=&quot;#outonly#&quot;&gt;
							&lt;/cfif&gt;
						</example>
						<attributes>
							<attribute name="enable" required="false" type="boolean" default="true">when true code following the tag will only generate output within cfoutput tags</attribute>
							<attribute name="repeat" required="false" type="numeric" default="0">indicates the number of times the cfsetting tag should be repeated - ignored if enable is false</attribute>
							<cfinclude template="docs/returnattributes.cfm">
						</attributes>
					</tag>
				</library>
			</spec>
		</cf_doc>

<cfelse>
	<cfsilent>
		<cfparam name="attributes.enable" type="boolean" default="true" />
		<cfparam name="attributes.repeat" type="numeric" default="0" />
		<cfparam name="attributes.return" type="string" default="" />
		
		<cfinclude template="/cfc/mixin/tap.cfm" />
		
		<cfif attributes.enable>
			<cfif attributes.repeat>
				<cfloop index="i" from="1" to="#attributes.repeat#">
					<cfsetting enablecfoutputonly="true">
				</cfloop>
			</cfif>
		<cfelse>
			<cfset repeat = 0 />
			<cfset enable = true />
			
			<cfloop condition="enable">
				<cfsavecontent variable="enable">false</cfsavecontent>
				<cfif not len(enable)>
					<cfset enable = true />
					<cfset repeat = repeat + 1 />
					<cfsetting enablecfoutputonly="false">
				</cfif>
			</cfloop>
			
			<cfif len(trim(attributes.return))>
				<cfinclude template="#getFS().return(repeat)#">
			</cfif>
		</cfif>
		
		<cfexit method="exittag" />
	</cfsilent>
</cfif>
