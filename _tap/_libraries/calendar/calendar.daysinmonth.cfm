<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="calendar">
					<function name="calendar.daysInMonth" return="number"  xref="">
						<usage>
							returns the number of days in the month associated with a specified date in a localized calendar
						</usage>
						<arguments>
							<arg name="date" type="date" required="false" default="#lib.lsTimeToZone()#">
								a date for which the month should be retreived
							</arg>
							<arg name="locale" type="string" required="false" default="#getTap().getLocal().language#">
								the locale to which the date should be localized
							</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfscript>
		function calendardaysinmonth() { 
			var date = lib.arg(arguments,1,""); 
			var locale = lib.arg(arguments,2,""); 
			return getIoC().getBean("calendarmanager").getCalendar(locale).getDaysInMonth(date); 
		} tStor("calendardaysinmonth","calendar.daysinmonth"); 
	</cfscript>
</cfif>
