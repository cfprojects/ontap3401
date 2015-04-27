<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="calendar">
					<function name="calendar.year" return="number"  xref="">
						<usage>uses java localization to return the year from a specified date</usage>
						<arguments>
							<arg name="date" type="date" required="false" default="#lib.lsTimeToZone()#">a date for which the year should be retreived</arg>
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
		function calendarYear() { 
			return this.datepart("yyyy",
				lib.arg(arguments,1,""),
				lib.arg(arguments,2,"")); 
		} tStor("calendarYear","calendar.year"); 
	</cfscript>
</cfif>
