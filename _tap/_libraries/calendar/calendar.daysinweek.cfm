<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="calendar">
					<function name="calendar.daysInWeek" return="number" xref="">
						<usage>returns the number of days in a week for a specified calendar</usage>
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
		function daysInWeek() { 
			var locale = lib.arg(arguments,1,""); 
			return this.info(locale).daysinweek; 
		} tStor("daysInWeek","calendar.daysInWeek"); 
	</cfscript>
</cfif>
