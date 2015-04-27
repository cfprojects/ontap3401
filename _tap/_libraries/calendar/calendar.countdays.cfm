<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="calendar">
					<function name="calendar.countDays" return="number" xref="">
						<usage>counts the number of arbitrary days of week in a specified period of time i.e. business-days</usage>
						<arguments>
							<arg name="StartDate" type="date" required="true" default="n/a">the beginning of the timespan</arg>
							<arg name="EndDate" type="date" required="false" default="n/a">the end of the timespan</arg>
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
		function CountDays(StartDate,EndDate) { 
			var Exclude = "1,7"; var IncludeStartDate = true; 
			var DaysPerWeek = 0; var days = 0; var locale = ""; 
			var WeekDay = ArrayNew(1); var x = 0; var CalendarDays = ""; 
			var MaxDays = DateDiff("d",dateadd("d",-1,StartDate),EndDate); 
			var calendar = 0; 
			
			switch (arrayLen(arguments)) { 
				case 5: { locale = arguments[5]; } 
				case 4: { IncludeStartDate = arguments[4]; } 
				case 3: { Exclude = arguments[3]; } 
			} 
			
			calendar = getIoC().getBean("calendarmanager").getCalendar(locale); 
			CalendarDays = calendar.DaysInWeek; 
			
			// create an array to hold days of the week with 1 or 0 indicating if the day is counted 
			arraySet(WeekDay,1,CalendarDays,1); Exclude = listToArray(Exclude);
			
			for (x = 1; x lte ArrayLen(Exclude); x = x + 1) { WeekDay[Exclude[x]] = 0; } // set the value of any Excluded day to 0 
			DaysPerWeek = ArraySum(WeekDay); // count the number of included days in a full week 
			days = DaysPerWeek * int(MaxDays/CalendarDays); // get the number of included days in all full weeks 
			for (x = 1; x lte MaxDays mod CalendarDays; x = x + 1) { // add any remaining days in the last partial week 
				days = days + WeekDay[calendar.getDayOfWeek(EndDate)]; 
				EndDate = dateadd("d",-1,EndDate); 
			} 
			
			// if excluding the start date, remove the value that might have been added for the starting day 
			if (not includeStartDate) { days = days - WeekDay[calendar.getDayOfWeek(StartDate)]; } 
			
			return days; 
		} tStor("CountDays","calendar.countDays"); 
	</cfscript>
</cfif>
