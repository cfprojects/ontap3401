<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="calendar">
					<function name="calendar.dayOfWeek" return="number"  xref="">
						<usage>
							uses java localization to return the day of the week from a specified date
							- NOTE: the result of this function is only for display - 
							calendar functions which expect a day number assume the week begins on Sunday (1 = Sunday)
						</usage>
						<example>&lt;cfoutput&gt;
						Sunday is day #this.dayOfWeek(1,'de_DE')# in a German calendar
						&lt;/cfoutput&gt;</example>
						<versioninfo>
							<history>
								<change date="2005-03-09">added adjustment for locales in which calendar weeks begin on a day other than sunday</change>
								<change date="2006-07-24">added adjust argument</change>
							</history>
						</versioninfo>
						<arguments>
							<arg name="date" type="date" required="false" default="#lib.lsTimeToZone()#">a date for which the week-day should be retreived</arg>
							<arg name="locale" type="string" required="false" default="#getTap().getLocal().language#">the locale to which the time should be localized</arg>
							<arg name="adjust" type="boolean" required="false" default="true">indicates if the day of week should be adjusted for the local calendar</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfset tReq("format/lsTime,format/lsDate")>
	
	<cfscript>
		function calendardayOfWeek() { 
			var theday = lib.arg(arguments,1,""); 
			var locale = lib.arg(arguments,2,""); 
			var adjust = lib.arg(arguments,3,true); 
			var calendar = getIoC().getBean("calendarmanager").getCalendar(locale); 
			
			if (not len(trim(theday))) { theday = lib.lsTimeToZone(); } 
			if (adjust) { theday = calendar.getAdjustedDayOfWeek(theday); } 
			else { theDay = calendar.getDayOfWeek(theday); } 
			
			return theday; 
		} tStor("calendardayOfWeek","calendar.dayOfWeek"); 
	</cfscript>
</cfif>
