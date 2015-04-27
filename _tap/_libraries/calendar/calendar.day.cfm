<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="calendar">
					<function name="calendar.day" return="number"  xref="">
						<usage>uses java localization to return the day from a specified date</usage>
						<arguments>
							<arg name="date" type="date" required="false" default="#lib.lsTimeToZone()#">a date for which the day should be retreived</arg>
							<arg name="locale" type="string" required="false" default="#getTap().getLocal().language#">
								the locale to which the time should be localized</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfset tReq("calendar/calendar.datePart")>
	
	<cfscript>
		function calendarday() { 
			return this.datepart("d",
				lib.arg(arguments,1,""),
				lib.arg(arguments,2,"")); 
		} tStor("calendarday","calendar.day"); 
	</cfscript>
</cfif>
