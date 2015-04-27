<cfcomponent displayname="SimpleLinkedSingle" 
hint="creates a linked-list object -- several of these objects can be chained together to create a sortable memory-resident structure which is passed by reference">
	<cfset variables.isListItem = 0>
	<cfset variables.listClass = "simplelinkedsingle">
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="item" required="false" default="">
		
		<cfset variables.isListItem = 1>
		<cfset setItem(arguments.item)>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="isItem" access="public" output="false" returntype="boolean" 
	hint="indicates if the current list element is a populated item or the sentinel object which holds reference to the head of the list">
		<cfreturn yesnoformat(variables.isListItem)>
	</cffunction>
	
	<cffunction name="setItem" access="public" output="false" hint="sets the item for the current list element">
		<cfargument name="item" required="false" default="">
		
		<cfif isItem() and isObject(arguments.item)>
			<cfset variables.item = item>
		<cfelse>
			<cfset structdelete(variables,"item")>
		</cfif>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getItem" access="public" output="false" hint="returns the item for the current list element  - may return this if the component is a subclass of linkedlist.cfc">
		<cfif structkeyexists(variables,"item")>
			<cfreturn variables.item>
		<cfelse>
			<cfreturn this>
		</cfif>
	</cffunction>
	
	<cffunction name="hasNext" access="public" output="false" returntype="boolean">
		<cfreturn structkeyexists(variables,"next") and isObject(variables.next)>
	</cffunction>
	
	<cffunction name="getListItem" access="private" output="false" hint="used internally to ensure that an inserted item is a linkedlist.cfc object">
		<cfargument name="item" required="true">
		<cfif not structkeyexists(arguments.item,"hasNext") or not isCustomFunction(arguments.item.hasnext)>
			<cfset arguments.item = CreateObject("component",variables.listclass).init(arguments.item) />
		</cfif>
		<cfreturn arguments.item />
	</cffunction>
	
	<cffunction name="setNext" access="public" output="false" 
	hint="used internally to set the pointer to the next item in the list -- do not use this method">
		<cfargument name="item" required="true">
		<cfif isObject(arguments.item)>
			<cfset variables.next = arguments.item>
		<cfelse>
			<cfset structdelete(variables,"next")>
		</cfif>
		<cfreturn this.getNext()>
	</cffunction>
	
	<cffunction name="insertAfter" access="public" output="false">
		<cfargument name="item" required="true">
		<cfif not isObject(arguments.item)><cfreturn this></cfif>
		<cfset arguments.item = getListItem(arguments.item)>
		<cfset arguments.item.setNext(this.getNext())>
		<cfset this.setNext(arguments.item)>
		<cfreturn this.getNext()>
	</cffunction>
	
	<cffunction name="removeAfter" access="public" output="false">
		<cfif this.hasNext()><cfset this.setNext(this.getNext().getNext())></cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getNext" access="public" output="false">
		<cfif this.hasNext()>
			<cfreturn variables.next>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>
	
	<cffunction name="getTail" access="public" output="false" hint="returns the last element in the list">
		<cfif this.hasNext()>
			<cfreturn variables.next.getTail()>
		<cfelse>
			<cfreturn this>
		</cfif>
	</cffunction>
	
	<cffunction name="getNextCount" access="public" output="false" hint="returns the number of elements in the list from the current element to the tail element">
		<cfif this.hasNext()>
			<cfreturn variables.isListItem + variables.next.getNextCount()>
		<cfelse><cfreturn variables.isListItem></cfif>
	</cffunction>
	
	<cffunction name="length" access="public" output="false" hint="returns the total number of units in the list">
		<cfreturn getNextCount()>
	</cffunction>
	
	<cffunction name="raiseMissingMethodException" access="private" output="false">
		<cfargument name="MissingMethodName" type="string" required="true" hint="The name of the missing method." />
		<cfthrow type="onTap.cfc.MissingMethod" message="onTap: Say What? Missing Method - I don't understand the method name #MissingMethodName#()" />
	</cffunction>
	
	<cffunction name="onMissingMethod" access="public" returntype="any" output="false" 
	hint="Allows methods of the embedded item to be called directly from the linked-list container.">
		<cfargument name="MissingMethodName" type="string" required="true" hint="The name of the missing method." />
		<cfargument name="MissingMethodArguments" type="any" required="true" 
			hint="The arguments that were passed to the missing method. This might be a named argument set or a numerically indexed set." />
		<cfset var arg = 0 />
		<cfset var x = 0 />
		<cfset var result = this />
		
		<cfif isArray(MissingMethodArguments) or structKeyExists(MissingMethodArguments,"1")>
			<cfloop index="x" from="1" to="#arraylen(MissingMethodArguments)#">
				<cfset arg = listappend(arg,"MissingMethodArguments[#x#]") />
			</cfloop>
			
			<cfset result = evaluate("getItem().#MissingMethodName#(#arg#)") />
		<cfelse>
			<cfinvoke component="#getItem#" method="#MissingMethodName#" argumentcollection="#MissingMethodArguments#" />
		</cfif>
		
		<cfif isDefined("result")><cfreturn result /></cfif>
	</cffunction>
</cfcomponent>