<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="calendar">
					<function name="calendar.datePart" return="number"  xref="">
						<usage>uses java localization to return information about a specified date - arguments are comparable to the ColdFusion datepart function</usage>
						<arguments>
							<arg name="part" type="string" required="true" default="n/a">the portion of a given date to return</arg>
							<arg name="date" type="date" required="false" default="#lib.lsTimeToZone()#">a date for which data should be retreived</arg>
							<arg name="locale" type="string" required="false" default="#getTap().getLocal().language#">
								the locale to which the time should be localized
							</arg>
							<arg name="timezone" type="string" required="false" default="">
								the time zone of the specified time value 
								-- if provided the time will be adjusted from UTC for the specified timezone offset 
								-- defaults to the request default timezone 
							</arg> 
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfset tReq("format/lsDate,format/lsTime")>
	
	<cfscript>
		function calendardatepart(part) { 
			return getIoC().getBean("calendarmanager").getDatePart(part,
				lib.arg(arguments,2,""),
				lib.arg(arguments,3,""),
				lib.arg(arguments,4,"")); 
		} tStor("calendardatepart","calendar.datepart"); 
	</cfscript>
</cfif>
