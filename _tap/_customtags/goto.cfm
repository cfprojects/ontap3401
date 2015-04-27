<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfinclude template="/cfc/mixin/tap.cfm" />

<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">
	
	<cf_doc>
			<spec>
				<library name="mx">
					<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" return="n/a" xref="">
						<usage>uses a combination of javascript and html headers to relocate a specified browser window</usage>
						<example>&lt;cf_goto href=&quot;/login/index.cfm&quot; /&gt;</example>
						<attributes>
							<attribute name="href" required="true" type="string" default="n/a">the url to which the html window should be relocated</attribute>
							<attribute name="domain" required="false" type="string" default="">absolute url or url alias from which the href argument is relative</attribute>
							<attribute name="window" required="false" type="string" default="window">a string reference to the html window or frame to be relocated</attribute>
							<attribute name="timeout" required="false" type="numeric" default="<cfoutput>#getTap().getCF().app.timeout_request#</cfoutput>">a requesttimeout value to append to the url</attribute>
							<attribute name="protocol" required="false" type="string" default="#getTap().getHREF().protocol#">the protocol for the return url</attribute>
							<attribute name="requestend" required="false" type="boolean" default="true|false">
								indicates if the specified location variables should be applied to the framework onrequestend goto feature 
								- defaults to true if the window argument has the default value of &quot;window&quot;
							</attribute>
						</attributes>
					</tag>
				</library>
			</spec>
		</cf_doc>
<cfelse>
	<cfparam name="attributes.href" default="?">
	<cfparam name="attributes.domain" default="*" />
	<cfparam name="attributes.window" default="window" />
	<cfparam name="attributes.timeout" default="#getTap().getCF().app.timeout_request#" />
	<cfparam name="attributes.protocol" default="#getTap().getHREF().protocol#" />
	<cfparam name="attributes.requestend" default="#iif(attributes.window is 'window',true,false)#" />
	
	<cfset js = getLib().js.location(attributes.href,
															attributes.domain,
															attributes.window,
															attributes.timeout,
															attributes.protocol,
															attributes.requestend) />
	<cfif getTap().getPage().doctype is not "javascript">
		<cfset js = getLib().jsOut(js) />
	</cfif>
	<cfset writeoutput(js) />
	
	<cfexit method="exittag" />
</cfif>

