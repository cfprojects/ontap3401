<cfcomponent displayname="CalendarManager" output="false" hint="A factory for international calendar objects">
	<cfset variables.calendar = structNew()>
	
	<cfinclude template="/cfc/mixin/tap.cfm" />
	
	<cffunction name="init" access="public" output="false">
		<cfset variables.created = getTickCount()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getModified" access="private" output="false" returntype="date">
		<cfargument name="path" type="string" required="true">
		<cfreturn CreateObject("java","java.io.File").init(path).lastModified()>
	</cffunction>
	
	<cffunction name="isChanged" access="public" output="false" returntype="boolean">
		<cfreturn iif(variables.created lt getModified(getCurrentTemplatePath()),true,false)>
	</cffunction>
	
	<cffunction name="debug" access="public" output="true" returntype="void">
		<cfdump var="#variables.calendar#">
	</cffunction>
	
	<cffunction name="setCalendar" access="public" output="false">
		<cfargument name="locale" type="string" required="true">
		<cfargument name="calendar" type="struct" required="true">
		
		<cfif locale is not "en_US">
			<cfset structAppend(calendar,getCalendar("en_US"),false)>
			<cfset calendar.setFormulatedValues()>
		</cfif>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="jLocale" access="private" output="false">
		<cfargument name="locale" type="string" required="true">
		<cfreturn getTap().getLocal().jLocale(locale)>
	</cffunction>
	
	<cffunction name="getCalendar" access="public" output="false" returntype="struct">
		<cfargument name="locale" type="string" required="true">
		<cfset var calendar = 0>
		
		<cfset locale = jLocale(locale).toString()>
		<cfif structKeyExists(variables.calendar,locale)>
			<cfset calendar = variables.calendar[locale]>
		<cfelse>
			<cfset calendar = CreateObject("component","calendar").init(locale)>
			<cfset setCalendar(locale,calendar.setFormulatedValues())>
		</cfif>
		
		<cfreturn calendar>
	</cffunction>
	
	<cffunction name="getAdjustedDayOfWeek" access="public" output="false" returntype="numeric">
		<cfargument name="theday" type="numeric" required="true">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfset theday = 1 + theday - calendar.firstdayofweek>
		<cfif theday lt 1><cfset theday = calendar.daysinweek + theday></cfif>
		
		<cfreturn theday>
	</cffunction>
	
	<cffunction name="getDate" access="private" output="false" returntype="string">
		<cfargument name="date" type="string" required="false" default="">
		<cfif len(trim(arguments.date))><cfreturn arguments.date></cfif>
		<cfreturn getLib().lsTimeToZone()>
	</cffunction>
	
	<cffunction name="lsDate" access="private" output="false" returntype="string">
		<cfargument name="date" type="date" required="true">
		<cfargument name="locale" type="string" required="true">
		<cfargument name="format" type="string" required="true">
		<cfreturn getLib().lsDate(date,locale,format)>
	</cffunction>
	
	<cffunction name="lsTime" access="private" output="false" returntype="string">
		<cfargument name="time" type="date" required="true">
		<cfargument name="locale" type="string" required="true">
		<cfargument name="format" type="string" required="true">
		<cfargument name="timezone" type="string" required="false" default="">
		<cfreturn getLib().lsTime(time,locale,format,timezone)>
	</cffunction>
	
	<cffunction name="NameOfDay" access="public" output="false" returntype="string">
		<cfargument name="date" type="string" required="false" default="">
		<cfargument name="full" type="boolean" required="false" default="true">
		<cfargument name="locale" type="string" required="false" default="">
		<cfset var calendar = "">
		
		<cfset date = getDate()>
		
		<cfif isNumeric(date)>
			<cfset calendar = getCalendar(locale)>
			<cfif arguments.full><cfset date = calendar.full.weekday[date]>
			<cfelse><cfset date = calendar.short.weekday[date]></cfif>
		<cfelseif isDate(date)>
			<cfset date = lsDate(date,locale,repeatstring("E",iif(arguments.full,4,3)))>
		</cfif>
		
		<cfreturn date>
	</cffunction>
	
	<cffunction name="NameOfMonth" access="public" output="false" returntype="string"> { 
		<cfargument name="date" type="string" required="false" default="">
		<cfargument name="full" type="boolean" required="false" default="true">
		<cfargument name="locale" type="string" required="false" default="">
		<cfargument name="timezone" type="string" required="false" default="">
		<cfset var calendar = "">
		
		<cfset date = getDate()>
		
		<cfif isnumeric(date)>
			<cfset calendar = getCalendar(locale)>
			<cfif arguments.full><cfset date = calendar.full.month[date]>
			<cfelse><cfset date = calendar.short.month[date]></cfif>
		<cfelseif isDate(date)>
			<cfset date = lsDate(date,locale,repeatstring("m",iif(full,4,3)))>
		</cfif>
		
		<cfreturn date>
	</cffunction>
	
	<cffunction name="getDatePart" access="public" output="false" returntype="string">
		<cfargument name="part" type="string" required="true">
		<cfargument name="date" type="string" required="false" default="">
		<cfargument name="locale" type="string" required="false" default="">
		<cfargument name="timezone" type="string" required="false" default="">
		<cfset var filter = 0>
		<cfset var my = structNew()>
		
		<cfscript>
			part = trim(part); 
			date = getDate(date); 
			
			switch(left(part,1)) { 
				case "q": { part = ceiling(lsDate(date,locale,"M")/4); break; } 
				case "y": { 
					if (len(part) is 4) { part = lsDate(date,locale,lcase(part)); break; } // year 
					else { part = lsDate(date,locale,"yyy"); break; } // day of year 
				} 
				case "w": { 
					switch (part) { 
						case "wm": { part = lsDate(date,locale,"W"); break; } // week of month 
						case "ww": { part = lsDate(date,locale,"w"); break; } // week of year 
						case "w": { 
							part = lsDate(date,locale,"E"); 
							if (not isnumeric(part)) { 
								my.calendar = getCalendar(locale); 
								my.weekdays = arraytolist(my.calendar.short.weekday,chr(7)); 
								part = listfindnocase(my.weekdays,part,chr(7)); break; 
							} break; 
						} 
					} break; 
				} 
				case "m": { part = lsDate(date,locale,"M"); break; } // month 
				case "d": { part = lsDate(date,locale,"d"); break; } // day of month 
				case "l": { part = datepart("l",date); break; } // milliseconds -- java returned 000 in every case I tested ?? 
				case "n": { part = "m"; } // minutes 
				case "s": { ; } // seconds 
				case "h": { part = lsTime(date,locale,lcase(left(part,1)),timezone); break; } // hours 
			} 
		</cfscript>
		
		<cfreturn part>
	</cffunction>
</cfcomponent>