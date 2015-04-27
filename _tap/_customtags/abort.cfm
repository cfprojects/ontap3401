<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfinclude template="/cfc/mixin/tap.cfm" />

<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">
	
	<cf_doc>
			<spec>
				<library name="core">
					<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" return="none" xref="core/abort,dom/js.location">
						<usage>
							aborts the current base template and includes code from the OnRequestEnd template 
							-- optionally relocates the current page or a frame to a new url 
							-- requests can also be aborted with getTap().abort() 
						</usage>
						<example>&lt;cf_abort url=&quot;yadda&quot; /&gt;</example>
						<attributes>
							<attribute name="url" required="false" type="string" default="">a url to relocate to while aborting the page</attribute>
							<attribute name="domain" required="false" type="string" default="R">the root of a url to relocate to as the page aborts</attribute>
							<attribute name="timeout" required="false" type="numeric" default="<cfoutput>#getTap().getCF().app.timeout_request#</cfoutput>">the requesttimeout value to append to the url's query string</attribute>
							<attribute name="protocol" required="false" type="string" default="#getTap().getHREF().protocol#">the protocol to use for a relocation url - defaults to the current protocol</attribute>
							<attribute name="window" required="false" type="string" default="window">the frame to relocate to the url specified by the other attributes</attribute>
							<attribute name="flush" required="false" type="boolean" default="#getTap().getCF().onrequestend.flush#">sets the value of getTap().getCF().onrequestend.flush</attribute>
							<attribute name="debug" required="false" type="boolean" default="#getTap().getCF().onrequestend.debug#">sets the value of getTap().getCF().onrequestend.debug</attribute>
						</attributes>
					</tag>
				</library>
			</spec>
		</cf_doc>

<cfelse>
	<cfparam name="attributes.url" type="any" default="">
	<cfparam name="attributes.domain" type="string" default="R">
	<cfparam name="attributes.timeout" type="numeric" default="#getTap().getCF().app.timeout_request#">
	<cfparam name="attributes.window" type="string" default="window">
	<cfparam name="attributes.protocol" type="string" default="#getTap().getHREF().protocol#">
	<cfparam name="attributes.flush" type="boolean" default="#getTap().getCF().onrequestend.flush#">
	<cfparam name="attributes.debug" type="boolean" default="#getTap().getCF().onrequestend.debug#">
	
	<cfinvoke component="#request.tap#" method="abort" argumentcollection="#attributes#">
</cfif>
