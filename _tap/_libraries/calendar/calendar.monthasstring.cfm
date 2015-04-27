<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="calendar">
					<function name="calendar.monthAsString" return="number"  xref="">
						<usage>uses java localization to return the localized name of a month from a specified date or month number</usage>
						<arguments>
							<arg name="date" type="date|number" required="false" default="#lib.lsTimeToZone()#">a month number or date for which the month should be retreived</arg>
							<arg name="full" type="boolean" required="false" default="true">indicates if the month name should be abbreviated</arg>
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
		function calendarmonthAsString() { 
			return getIoC().getBean("calendarmanager").nameOfMonth(
				lib.arg(arguments,1,""),
				lib.arg(arguments,2,true),
				lib.arg(arguments,3,"")); 
		} tStor("calendarmonthAsString","calendar.monthAsString"); 
	</cfscript>
</cfif>
