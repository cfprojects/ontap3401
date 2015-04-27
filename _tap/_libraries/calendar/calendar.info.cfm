<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="calendar">
					<function name="calendar.info" return="struct" xref="">
						<usage>returns calendar information for a specified locale</usage>
						<arguments>
							<arg name="locale" type="string" required="false" default="#getTap().getLocal().language#">
								indicates the locale for which calendar information should be returned 
							</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfscript>
		function calendarInfo() { 
			return getIoC().getBean("calendarmanager").getCalendar(lib.arg(arguments,1,"")); 
		} tStor("calendarinfo","calendar.info"); 
	</cfscript>
</cfif>
