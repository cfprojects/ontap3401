<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="calendar">
					<function name="calendar.dayOfWeekAsString" return="number"  xref="">
						<usage>uses java localization to return the localized name of a week day from a specified date or day number (1=sunday)</usage>
						<arguments>
							<arg name="date" type="date|number" required="false" default="#lib.lsTimeToZone()#">a day number or date for which the week-day should be retreived</arg>
							<arg name="full" type="boolean" required="false" default="true">indicates if the day name should be abbreviated</arg>
							<arg name="locale" type="string" required="false" default="#getTap().getLocal().language#">
								the locale to which the time should be localized</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfset tReq("core/lsTimeToZone,format/lsDate,calendar/calendar.info")>
	
	<cfscript>
		function calendardayOfWeekAsString() { 
			return getIoC().getBean("calendarmanager").NameOfDay(
				lib.arg(arguments,1,""),
				lib.arg(arguments,2,true),
				lib.arg(arguments,3,"")); 
		} tStor("calendardayOfWeekAsString","calendar.dayOfWeekAsString"); 
	</cfscript>
</cfif>
