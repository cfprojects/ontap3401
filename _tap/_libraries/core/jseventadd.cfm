<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="dom">
					<function name="jsEventAdd" return="string" xref="" deprecated="2009-10-08">
						<usage>adds javascript code to an event for the current page -- used in the _application or _htmlhead stage of the request</usage>
						<example>&lt;cfset this.js.eventAdd(&quot;onload&quot;,&quot;alert(&apos;Hello World&apos;);&quot;)&gt;</example>
						<arguments>
							<arg name="event" required="true" type="string" default="n/a">the name of the javascript window event handler to which the javascirpt code should be married</arg>
							<arg name="javascript" required="true" type="string" default="n/a">javascript code to execute when the event fires</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfset tReq("core/param") />
	
	<cffunction name="jsEventAdd" access="public" output="false">
		<cfargument name="event" type="string" required="true" />
		<cfargument name="javascript" type="string" required="true" />
		<cfset var page = getTap().getPage().eventAdd(event,javascript) />
	</cffunction>
	
	<cfset tStor("jsEventAdd") />
</cfif>
