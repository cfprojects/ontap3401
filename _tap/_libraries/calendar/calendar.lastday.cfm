<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="calendar">
					<function name="calendar.lastDay" return="date" xref="">
						<usage>counts the number of arbitrary days of week from a start date to find the end of a span of time measured in arbitrary days i.e. business-days</usage>
						<arguments>
							<arg name="NumDays" type="numeric" required="true" default="n/a">the number of days to count</arg>
							<arg name="StartDate" type="date" required="false" default="#lib.lsTimeToZone()#">the beginning of the timespan</arg>
							<arg name="Exclude" type="string" required="false" default="1,7">
								indicates which days should be excluded from the count - defaults to saturday and sunday
							</arg>
							<arg name="IncludeStartDate" type="boolean" required="false" default="true">
								indicates if the first day of the timespan should be included in the count if relevant
							</arg>
							<arg name="locale" type="string" required="false" default="#getTap().getLocal().language#">
								the locale from which calendar information should be retrieved
							</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfscript>
		function lastDay(NumDays) { var startdate = ""; 
			var Exclude = "1,7"; var IncludeStartDate = true; 
			var DaysPerWeek = 0; var days = 0; var locale = ""; 
			var WeekDay = ArrayNew(1); var x = 0; var CalendarDays = ""; 
			var calendar = 0; var weeks = 0; var enddate = 0; 
			var sign = NumDays/abs(NumDays); 
			
			switch (arrayLen(arguments)) { 
				case 5: { locale = arguments[5]; } 
				case 4: { IncludeStartDate = arguments[4]; } 
				case 3: { Exclude = arguments[3]; } 
				case 2: { StartDate = arguments[2]; } 
			} 
			
			if (not isDate(StartDate)) { StartDate = lib.lsTimeToZone(); } 
			calendar = getIoC().getBean("calendarmanager").getCalendar(locale); 
			CalendarDays = calendar.DaysInWeek; EndDate = DateFormat(StartDate); 
			
			// create an array to hold days of the week with 1 or 0 indicating if the day is counted 
			arraySet(WeekDay,1,CalendarDays,1); Exclude = listToArray(Exclude); 
			for (x = 1; x lte ArrayLen(Exclude); x = x + 1) { WeekDay[Exclude[x]] = 0; } // set the value of any Excluded day to 0 
			
			DaysPerWeek = ArraySum(WeekDay); // count the number of included days in a full week 
			weeks = sign * int(abs(numdays)/daysperweek); // count the number of whole weeks in the time span 
			EndDate = DateAdd("d",(weeks * CalendarDays)-sign,EndDate); // move the start date to the whole number of weeks 
			NumDays = abs(NumDays) mod DaysPerWeek; // get the number of days remaining to add 
			
			// if excluding the start date, remove the value that might have been added for the starting day 
			if (not includeStartDate) { NumDays = NumDays + WeekDay[calendar.getDayOfWeek(StartDate)]; } 
			
			while (NumDays) { 
				EndDate = DateAdd("d",sign,EndDate); // get the next day 
				// while the next day is not being counted, continue to the next day 
				if (not WeekDay[calendar.getDayOfWeek(EndDate)]) { continue; } 
				NumDays = NumDays - 1; 
			} 
			
			return EndDate; 
		} tStor("lastDay","calendar.lastDay"); 
	</cfscript>
</cfif>
