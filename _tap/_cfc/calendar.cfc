<cfcomponent displayname="Calendar" output="false" hint="represents a calendar in a specific international locale">
	
	<cfinclude template="/cfc/mixin/tap.cfm" />
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="locale" type="string" required="true">
		<cfset var st = structnew()>
		<cfset var symbols = 0>
		<cfset var cal = 0>
		<cfset var df = 0>
		
		<cfscript>
			this.locale = arguments.locale; 
			df = getDateFormat(arguments.locale); 
			symbols = df.getDateFormatSymbols(); 
			cal = df.getCalendar(); 
			
			this.firstdayofweek = cal.getFirstDayOfWeek(); 
			
			this.era = symbols.getEras(); 
			this.ampm = symbols.getAMPMStrings(); 
				
			this.full = structnew(); // apparently some jvm's return an extra element in these arrays 
			// which is null or otherwise not liked by ColdFusion and cannot be deleted using arraydeleteat() 
			this.full.weekday = listtoarray(arraytolist(symbols.getWeekdays(),chr(7)),chr(7)); 
			this.full.month = listtoarray(arraytolist(symbols.getMonths(),chr(7)),chr(7)); 
			
			this.short = structnew(); 
			this.short.weekday = listtoarray(arraytolist(symbols.getShortWeekdays(),chr(7)),chr(7)); 
			this.short.month = listtoarray(arraytolist(symbols.getShortMonths(),chr(7)),chr(7)); 
			setFormulatedValues(); 
		</cfscript>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="jLocale" access="private" output="false">
		<cfargument name="locale" type="string" required="true">
		<cfreturn getTap().getLocal().jLocale(locale)>
	</cffunction>
	
	<cffunction name="getDateFormat" access="public" output="false">
		<cfargument name="locale" type="string" required="true">
		<cfreturn createObject("java","java.text.SimpleDateFormat").init("",jLocale(locale))>
	</cffunction>
	
	<cffunction name="setFormulatedValues" access="public" output="false">
		<cfset this.am = this.ampm[1]>
		<cfset this.pm = this.ampm[2]>
		
		<cfif not structKeyExists(this,"short") and structKeyExists(this,"full")>
			<cfset this.short = this.full>
		<cfelseif not structKeyExists(this,"full") and structKeyExists(this,"short")>
			<cfset this.full = this.short>
		</cfif>
		
		<cfif structKeyExists(this,"full") and structKeyExists(this,"short")>
			<cfset structAppend(this.full,this.short,false)>
			<cfset structAppend(this.short,this.full,false)>
			<cfset this.daysinweek = arraylen(this.full.weekday)>
		</cfif>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getDaysInMonth" access="public" output="false" returntype="numeric">
		<cfargument name="date" type="string" required="true">
		<cfreturn DaysInMonth(date)>
	</cffunction>
	
	<cffunction name="getDayOfWeek" access="public" output="false" returntype="numeric">
		<cfargument name="date" type="string" required="true">
		<cfreturn DayOfWeek(date)>
	</cffunction>
	
	<cffunction name="getAdjustedDayOfWeek" access="public" output="false" returntype="numeric">
		<cfargument name="theday" type="numeric" required="true">
		<cfargument name="locale" type="string" required="false" default="">
		
		<cfif not isNumeric(theday)><cfset theday = getDayOfWeek(theday)></cfif>
		<cfset theday = 1 + theday - this.firstdayofweek>
		<cfif theday lt 1><cfset theday = this.daysinweek + theday></cfif>
		
		<cfreturn theday>
	</cffunction>
</cfcomponent>