<cfcomponent displayname="SimpleLinkedDouble" extends="simplelinkedsingle" 
hint="creates a simple implementation of a bidirectional linked-list">
	<cfset variables.listClass = "simplelinkeddouble">
	<cfset structDelete(this,"removeAfter")>
	<cfset structDelete(variables,"removeAfter")>
	
	<cffunction name="hasLast" access="public" output="false" returntype="boolean">
		<cfreturn structkeyexists(variables,"last") and isObject(variables.last)>
	</cffunction>
	
	<cffunction name="setLast" access="public" output="false" 
	hint="used internally to set the pointer to the next item in the list -- do not use this method">
		<cfargument name="item" required="true">
		<cfif not isItem()><cfreturn this></cfif>
		<cfif isObject(arguments.item)>
			<cfset variables.last = arguments.item>
		<cfelse>
			<cfset structdelete(variables,"last")>
		</cfif>
		<cfreturn this.getLast()>
	</cffunction>
	
	<cffunction name="insertAfter" access="public" output="false">
		<cfargument name="item" required="true">
		<cfif not isObject(arguments.item)><cfreturn this></cfif>
		<cfset arguments.item = getListItem(arguments.item)>
		<cfif this.hasNext()><cfset this.getNext().setLast(arguments.item)></cfif>
		<cfset arguments.item.setNext(this.getNext())>
		<cfset arguments.item.setLast(this)>
		<cfset this.setNext(arguments.item)>
		<cfreturn this.getNext()>
	</cffunction>
	
	<cffunction name="insertBefore" access="public" output="false">
		<cfargument name="item" required="true">
		<cfif not isObject(arguments.item)><cfreturn this></cfif>
		<cfif not isItem()><cfreturn this.insertAfter(arguments.item)></cfif>
		<cfset arguments.item = getListItem(arguments.item)>
		<cfif this.hasLast()><cfset this.getLast().setNext(arguments.item)></cfif>
		<cfset arguments.item.setLast(this.getLast())>
		<cfset arguments.item.setNext(this)>
		<cfset this.setLast(arguments.item)>
		<cfreturn this.getLast()>
	</cffunction>
	
	<cffunction name="remove" access="public" output="false">
		<cfif isItem()>
			<cfif this.hasNext()><cfset this.getNext().setLast(this.getLast())></cfif>
			<cfif this.hasLast()><cfset this.getLast().setNext(this.getNext())></cfif>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getNext" access="public" output="false">
		<cfargument name="depth" type="numeric" default="1">
		<cfargument name="circular" type="boolean" default="false">
		<cfif depth eq 0><cfreturn this></cfif>
		<cfif this.hasNext()>
			<cfreturn variables.next.getNext(abs(depth)-1,circular)>
		<cfelseif circular and isItem()>
			<cfreturn this.getHead().getNext(abs(depth)-1,circular)>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>
	
	<cffunction name="getLast" access="public" output="false">
		<cfargument name="depth" type="numeric" default="1">
		<cfargument name="circular" type="boolean" default="false">
		<cfif depth eq 0><cfreturn this></cfif>
		<cfif this.hasLast()>
			<cfreturn variables.last.getLast(abs(depth)-1,circular)>
		<cfelseif arguments.circular and (isItem() or this.hasNext())>
			<cfreturn this.getTail().getLast(abs(depth)-1,circular)>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>
	
	<cffunction name="getSentinel" access="public" output="false" hint="returns a reference to the sentinel object responsible for maintaining reference to the remaining list elements (while allowing deletion of the head element)">
		<cfif this.hasLast()>
			<cfreturn variables.last.getSentinel()>
		<cfelse>
			<cfreturn this>
		</cfif>
	</cffunction>
	
	<cffunction name="getHead" access="public" output="false" hint="returns the first element in the list after the sentinel object">
		<cfreturn getSentinel().getNext()>
	</cffunction>
	
	<cffunction name="getLastCount" access="public" output="false" hint="returns the number of elements in the list from the current element to the head element">
		<cfif this.hasLast()>
			<cfreturn variables.isListItem + variables.last.getLastCount()>
		<cfelse><cfreturn variables.isListItem></cfif>
	</cffunction>
	
	<cffunction name="length" access="public" output="false" hint="returns the total number of units in the list">
		<cfreturn getNextCount() + getLastCount() - variables.isListItem>
	</cffunction>
</cfcomponent>