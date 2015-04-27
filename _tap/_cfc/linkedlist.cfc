<cfcomponent displayname="LinkedList" extends="linkeddouble" 
hint="creates a linked-list object -- several of these objects can be chained together to create a sortable memory-resident structure which is passed by reference">
	<cfset variables.listClass = "linkedlist">
	
	<cffunction name="getNextSum" access="public" output="false" hint="returns a sum of the values of a particular property after to the current list item">
		<cfargument name="propertyname" type="string" required="true">
		<cfset var amount = val(getValue(arguments.propertyname))>
		<cfif this.hasNext()>
			<cfreturn amount + this.getNext().getNextSum(arguments.propertyname)>
		<cfelse><cfreturn amount></cfif>
	</cffunction>
	
	<cffunction name="getLastSum" access="public" output="false" hint="returns a sum of the values of a particular property prior to the current list item">
		<cfargument name="propertyname" type="string" required="true">
		<cfset var amount = val(this.getValue(arguments.propertyname))>
		<cfif this.hasLast()>
			<cfreturn amount + this.getLast().getLastSum(arguments.propertyname)>
		<cfelse><cfreturn amount></cfif>
	</cffunction>
	
	<cffunction name="getSum" access="public" output="false" hint="returns a sum of all values of a given property for the entire list">
		<cfargument name="propertyname" type="string" required="true">
		<cfset var amount = this.getNextSum(propertyname) + this.getLastSum(propertyname) - val(this.getValue(propertyname))>
		<cfif this.hasLast()>
			<cfreturn amount + this.getLast().getLastSum(arguments.propertyname)>
		<cfelse><cfreturn amount></cfif>
	</cffunction>
	
	<cffunction name="getNextAvg" access="public" output="false" hint="returns the average of a given property across the remaining items to the tail - not very efficient - double-traversal">
		<cfargument name="propertyname" type="string" required="true">
		<cfreturn getNextSum(arguments.propertyname) / getNextCount()>
	</cffunction>
	
	<cffunction name="getLastAvg" access="public" output="false" hint="returns the average of a given property across the prior items to the head - not very efficient - double-traversal">
		<cfargument name="propertyname" type="string" required="true">
		<cfreturn getLastSum(arguments.propertyname) / getLastCount()>
	</cffunction>
	
	<cffunction name="getAvg" access="public" output="false" hint="returns the average of a given property across the entire list - not very efficient - double-traversal">
		<cfargument name="propertyname" type="string" required="true">
		<cfreturn this.getSum(arguments.propertyname) / this.length()>
	</cffunction>
	
	<cffunction name="getNextMin" access="public" output="false" returntype="string" 
	hint="returns the minimum of a given property for list items after the current item">
		<cfargument name="propertyname" type="string" required="true">
		<cfset var current = ""> 
		<cfset var next = getNext()>
		<cfif isItem()><cfset current = this.getValue(arguments.propertyname)></cfif>
		<cfif isObject(next)><cfset next = next.getNextMin(arguments.propertyname)></cfif>
		<cfif isnumeric(current) and isnumeric(next)>
			<cfreturn min(current,next)>
		<cfelseif isnumeric(next)>
			<cfreturn next>
		<cfelse>
			<cfreturn current>
		</cfif>
	</cffunction>
	
	<cffunction name="getLastMin" access="public" output="false" returntype="string" 
	hint="returns the minimum of a given property for list items prior to the current item">
		<cfargument name="propertyname" type="string" required="true">
		<cfset var current = "">
		<cfset var last = getLast()>
		<cfif isItem()><cfset current = this.getValue(arguments.propertyname)></cfif>
		<cfif isObject(last)><cfset last = last.getLastMin(arguments.propertyname)></cfif>
		<cfif isnumeric(current) and isnumeric(last)>
			<cfreturn min(current,last)>
		<cfelseif isnumeric(last)>
			<cfreturn last>
		<cfelse>
			<cfreturn current>
		</cfif>
	</cffunction>
	
	<cffunction name="getMin" access="public" output="false" returntype="string" 
	hint="returns the minimum of a specified property across the entire list">
		<cfargument name="propertyname" type="string" required="true">
		<cfset var next = this.getNextMin(arguments.propertyname)>
		<cfset var last = this.getLastMin(arguments.propertyname)>
		
		<cfif isnumeric(next) and isnumeric(last)>
			<cfreturn min(next,last)>
		<cfelseif isnumeric(next)>
			<cfreturn next>
		<cfelseif isnumeric(last)>
			<cfreturn last>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>
	
	<cffunction name="getNextMax" access="public" output="false" returntype="string" 
	hint="returns the maximum of a given property for list items after the current item">
		<cfargument name="propertyname" type="string" required="true">
		<cfset var current = "">
		<cfset var next = getNext()>
		<cfif isItem()><cfset current = this.getValue(arguments.propertyname)></cfif>
		<cfif isObject(next)><cfset next = next.getNextMax(arguments.propertyname)></cfif>
		<cfif isnumeric(current) and isnumeric(next)>
			<cfreturn max(current,next)>
		<cfelseif isnumeric(next)>
			<cfreturn next>
		<cfelse>
			<cfreturn current>
		</cfif>
	</cffunction>
	
	<cffunction name="getLastMax" access="public" output="false" 
	hint="returns the maximum of a given property for list items prior to the current item">
		<cfargument name="propertyname" type="string" required="true">
		<cfset var current = "">
		<cfset var last = getLast()>
		<cfif isItem()><cfset current = this.getValue(arguments.propertyname)></cfif>
		<cfif isObject(last)><cfset last = last.getLastMax(arguments.propertyname)></cfif>
		<cfif isnumeric(current) and isnumeric(last)>
			<cfreturn max(current,last)>
		<cfelseif isnumeric(last)>
			<cfreturn last>
		<cfelse>
			<cfreturn current>
		</cfif>
	</cffunction>
	
	<cffunction name="getMax" access="public" output="false" returntype="string" 
	hint="returns the maximum of a specified property across the entire list">
		<cfargument name="propertyname" type="string" required="true">
		<cfset var next = this.getNextMax(arguments.propertyname) />
		<cfset var last = this.getLastMax(arguments.propertyname) />
		
		<cfif isnumeric(next) and isnumeric(last)>
			<cfreturn max(next,last)>
		<cfelseif isnumeric(next)>
			<cfreturn next>
		<cfelseif isnumeric(last)>
			<cfreturn last>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>

	<cffunction name="getQuery" access="public" output="false" returntype="query" 
	hint="returns a query containing properties from each list item">
		<cfargument name="columnlist" type="string" required="false" default="">
		<cfargument name="maxrows" type="numeric" required="false" default="-1">
		<cfargument name="circular" type="boolean" required="false" default="false">
		<cfset var i = 0><cfset var qry = QueryNew("")>
		<cfset arguments.maxitems = arguments.maxrows>
		
		<cfif not len(trim(arguments.columnlist))>
			<cfif this.isItem()><cfset arguments.columnlist = this.getProperties()>
			<cfelseif this.hasNext()><cfset arguments.columnlist = this.getNext().getProperties()>
			<cfelse><cfreturn qry></cfif>
			<cfset structdelete(arguments.columnlist,"observers")>
			<cfset arguments.columnlist = structkeylist(arguments.columnlist)>
		</cfif>
		
		<cfset arguments.propertyname = arguments.columnlist>
		<cfinvoke method="getNextArray" argumentcollection="#arguments#" returnvariable="arguments.st">
		
		<cfloop index="i" list="#arguments.columnlist#">
			<cfset QueryAddColumn(qry,i,arguments.st[i])>
		</cfloop>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getNextArray" access="public" output="false" 
	hint="returns an array of list elements, an array of a single property or a structure of arrays matching a list of properties found in each list object">
		<cfargument name="maxitems" type="numeric" required="false" default="-1">
		<cfargument name="propertyname" type="string" required="false" default="">
		<cfargument name="circular" type="boolean" required="false" default="false">
		<cfset var item = this><cfset var total = 0>
		<cfset var a = structNew()><cfset var i = 0>
		<cfset var length = 0>
		<cfif arguments.circular><cfset total = this.length()></cfif>
		<cfif not item.isItem()>
			<cfif item.hasNext()><cfset item = item.getNext()>
			<cfelseif listLen(propertyname) gt 1><cfreturn a>
			<cfelse><cfreturn arrayNew(1)></cfif>
		</cfif>
		
		<cfif len(trim(propertyname))>
			<cfloop index="i" list="#arguments.propertyname#">
			<cfset a[i] = arrayNew(1)></cfloop>
		<cfelse><cfset a = arrayNew(1)></cfif>
		
		<cfloop condition="isObject(item) and maxitems neq 0 and (not arguments.circular or length lt total)">
			<cfif isstruct(a)>
				<cfloop index="i" list="#arguments.propertyname#">
					<cfset arrayAppend(a[i],item.getValue(i))>
				</cfloop>
			<cfelse>
				<cfset arrayAppend(a,item)>
			</cfif>
			
			<cfset maxitems = maxitems -1>
			<cfset length = length + 1>
			<cfset item = item.getNext()>
			<cfif arguments.circular and not isObject(item)>
				<cfset item = this.getHead()>
			</cfif>
		</cfloop>
		
		<cfif isStruct(a) and listlen(arguments.propertyname) eq 1>
		<cfreturn a[arguments.propertyname]><cfelse><cfreturn a></cfif>
	</cffunction>
	
	<cffunction name="search" access="public" output="false" 
	hint="returns the next item in the list with a specified property">
		<cfargument name="propertyname" type="string" required="true">
		<cfargument name="propertyvalue" type="string" required="true">
		<cfset var next = this.getNext()>
		<cfloop condition="isObject(next)">
			<cfif next.getValue(arguments.propertyname) is arguments.propertyvalue><cfreturn next></cfif>
			<cfset next = next.getNext()>
		</cfloop><cfreturn "">
	</cffunction>
	
	<cffunction name="RESearch" access="public" output="false" 
	hint="returns the next item in the list with a specified property matching a regular expression">
		<cfargument name="propertyname" type="string" required="true">
		<cfargument name="expression" type="string" required="true">
		<cfset var next = this.getNext()>
		<cfset var match = "">
		<cfloop condition="isObject(next)">
			<cfif REFind(arguments.expression,next.getValue(arguments.propertyname))><cfreturn next></cfif>
			<cfset next = next.getNext()>
		</cfloop><cfreturn "">
	</cffunction>
	
	<cffunction name="RESearchNoCase" access="public" output="false" 
	hint="returns the next item in the list with a specified property matching a case-insensitive regular expression">
		<cfargument name="propertyname" type="string" required="true">
		<cfargument name="expression" type="string" required="true">
		<cfset var next = this.getNext()>
		<cfset var match = "">
		<cfloop condition="isObject(next)">
			<cfif REFindNoCase(arguments.expression,next.getValue(arguments.propertyname))><cfreturn next></cfif>
			<cfset next = next.getNext()>
		</cfloop><cfreturn "">
	</cffunction>
	
	<cffunction name="searchEx" access="public" output="false" 
	hint="returns the next item in the list with a specified collection of properties">
		<cfset var next = this.getNext()>
		<cfset var x = 0>
		<cfset var match = true>
		<cfloop condition="isObject(next)">
			<cfset match = true>
			<cfloop item="x" collection="#arguments#">
				<cfif next.getValue(x) is not arguments[x]>
					<cfset match = false><cfbreak>
				</cfif>
			</cfloop>
			<cfif match><cfreturn next></cfif>
			<cfset next = next.getNext()>
		</cfloop><cfreturn "">
	</cffunction>
	
	<cffunction name="compare_numeric" access="private" output="false">
		<cfargument name="myproperty" required="true">
		<cfargument name="compareto" required="true">
		<cfif not isnumeric(myproperty) and not isnumeric(compareto)>
			<cfreturn 0>
		<cfelseif not isnumeric(myproperty)>
			<cfreturn -1>
		<cfelseif not isnumeric(compareto)>
			<cfreturn 1>
		<cfelseif myproperty eq compareto>
			<cfreturn 0>
		<cfelse>
			<cfreturn iif(myproperty gt compareto,1,-1)>
		</cfif>
	</cffunction>
	
	<cffunction name="compare_date" access="private" output="false">
		<cfargument name="myproperty" required="true">
		<cfargument name="compareto" required="true">
		<cfif not isdate(myproperty) and not isdate(compareto)>
			<cfreturn 0>
		<cfelseif not isdate(myproperty)>
			<cfreturn -1>
		<cfelseif not isdate(compareto)>
			<cfreturn 1>
		<cfelse>
			<cfreturn dateCompare(myproperty,compareto,"s")>
		</cfif>
	</cffunction>

	<cffunction name="compare_text" access="private" output="false">
		<cfargument name="myproperty" required="true">
		<cfargument name="compareto" required="true">
		<cfargument name="locale" type="string" required="false" default="">
		<cfargument name="strength" type="string" required="false" default="TERTIARY" hint="strength of java collated sorting for text values">
		<cfargument name="decomposition" type="string" required="false" default="FULL" hint="decomposition of java collated sorting for text values">
		
		<cfset var a = arrayNew(1)>
		<cfif not issimplevalue(myproperty) and not issimplevalue(comapreto)>
			<cfreturn 0>
		<cfelseif not issimplevalue(myproperty)>
			<cfreturn -1>
		<cfelseif not issimplevalue(compareto)>
			<cfreturn 1>
		<cfelseif myproperty is compareto>
			<cfreturn 0>
		<cfelse>
			<cfset a[1] = arguments.myproperty>
			<cfset a[2] = arguments.compareto>
			<cfset a = getLib().lsSortArray(a,"asc",arguments.locale,arguments.strength,arguments.decomposition)>
			<cfreturn iif(a[1] is arguments.myproperty,-1,1)>
		</cfif>
	</cffunction>
	
	<cffunction name="sort" access="public" output="false" hint="sorts the list - useful for in-memory sorting of tabular data">
		<cfargument name="propertyname" type="string" required="true" hint="indicates the property on which items in the list are sorted">
		<cfargument name="sorttype" type="string" required="false" default="text" hint="text | numeric | date - indicates the method by which">
		<cfargument name="sortorder" type="string" required="false" default="asc" hint="asc | desc - indicates if the list should be sorted in ascending or descending order">
		<cfargument name="locale" type="string" required="false" default="" hint="the language for which the list should be sorted">
		<cfargument name="strength" type="string" required="false" default="TERTIARY" hint="strength of java collated sorting for text values">
		<cfargument name="decomposition" type="string" required="false" default="FULL" hint="decomposition of java collated sorting for text values">
		<cfset var sortnext = this.getNext()>
		<cfset var sortafter = 1>
		<cfset var item = this>
		<cfset var after = 0>
		
		<cfif isItem()>
			<cfset arguments.myproperty = this.getValue(arguments.propertyname)>
			
			<cfif hasNext()>
				<cfloop condition="item.hasNext()">
					<cfinvoke method="compare_#arguments.sorttype#" argumentcollection="#arguments#" 
					compareto="#item.getNext().getValue(arguments.propertyname)#" returnvariable="sortafter">
					<cfif sortorder is "desc"><cfset sortafter = -sortafter></cfif>
					<cfif sortafter lte 0><cfbreak></cfif>
					<cfset after = 1>
					<cfset item = item.getNext()>
				</cfloop>
				<cfif after>
					<cfset this.remove()>
					<cfset item.insertAfter(this)>
				</cfif>
				
				<cfset after = 0>
				<cfset item = this>
				<cfloop condition="item.hasLast() and item.getLast().isItem()">
					<cfinvoke method="compare_#arguments.sorttype#" argumentcollection="#arguments#" 
					compareto="#item.getLast().getValue(arguments.propertyname)#" returnvariable="sortafter">
					<cfif sortorder is "desc"><cfset sortafter = -sortafter></cfif>
					<cfif sortafter gte 0><cfbreak></cfif>
					<cfset after = 1>
					<cfset item = item.getLast()>
				</cfloop>
				<cfif after>
					<cfset this.remove()>
					<cfset item.insertBefore(this)>
				</cfif>
			</cfif>
		</cfif>
		
		<cfif isObject(sortnext)>
			<cfset sortnext.sort(arguments.propertyname,arguments.sorttype,arguments.sortorder)>
		</cfif>
	</cffunction>
</cfcomponent>