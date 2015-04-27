<cfcomponent displayname="LinkedSingle" extends="ontap" 
hint="creates a linked-list object -- several of these objects can be chained together to create a sortable memory-resident structure which is passed by reference">
	<cfset variables.listClass = "linkedsingle">
	<cfset extend("cfc.simplelinkedsingle")>
	<cfset this.init = variables.extends[1].init>
	<cfset variables.init = this.init>
	
	<cffunction name="getValue" access="public" output="false">
		<cfargument name="propertyname" type="string" required="true">
		<cfif structkeyexists(variables,"item") and isObject(item)>
			<cfreturn variables.item.getValue(arguments.propertyname)>
		<cfelse>
			<cfreturn super.getValue(arguments.propertyname)>
		</cfif>
	</cffunction>
	
	<cffunction name="setValue" access="public" output="false">
		<cfargument name="propertyname" type="string" required="true">
		<cfargument name="propertyvalue" type="any" required="true">
		<cfargument name="overwrite" type="boolean" required="false" default="true">
		<cfif structkeyexists(variables,"item") and isObject(item)>
			<cfset variables.item.setValue(arguments.propertyname,arguments.propertyvalue,arguments.overwrite)>
			<cfreturn this>
		<cfelse>
			<cfreturn super.setValue(arguments.propertyname,arguments.propertyvalue,arguments.overwrite)>
		</cfif>
	</cffunction>
	
	<cffunction name="getProperties" access="public" output="false">
		<cfif structkeyexists(variables,"item") and isObject(item)>
			<cfreturn variables.item.getProperties()>
		<cfelse>
			<cfreturn super.getProperties()>
		</cfif>
	</cffunction>
	
	<cffunction name="raiseMissingMethodException" access="private" output="false">
		<cfargument name="MissingMethodName" type="string" required="true" hint="The name of the missing method." />
		<cfthrow type="onTap.cfc.MissingMethod" message="onTap: Say What? Missing Method - I don't understand the method name #MissingMethodName#()" />
	</cffunction>
	
	<cffunction name="onMissingMethod" access="public" returntype="any" output="false" hint="Allows methods of the embedded item to be called directly from the linked-list container.">
		<cfargument name="MissingMethodName" type="string" required="true" hint="The name of the missing method." />
		<cfargument name="MissingMethodArguments" type="any" required="true" 
			hint="The arguments that were passed to the missing method. This might be a named argument set or a numerically indexed set." />
		<cfset var st = identifyAccessorOrMutator(MissingMethodName,MissingMethodArguments) />
		<cfset var result = this />
		<cfset var arg = 0 />
		<cfset var x = 0 />
		
		<cfswitch expression="#st.method#">
			<cfcase value="get"><cfset result = getValue(st.property) /></cfcase>
			<cfcase value="set"><cfset result = setValue(st.property,st.data) /></cfcase>
			<cfdefaultcase>
				<cfif isArray(MissingMethodArguments) or structKeyExists(MissingMethodArguments,"1")>
					<cfloop index="x" from="1" to="#arraylen(MissingMethodArguments)#">
						<cfset arg = listappend(arg,"MissingMethodArguments[#x#]") />
					</cfloop>
					
					<cfset result = evaluate("getItem().#MissingMethodName#(#arg#)") />
				<cfelse>
					<cfinvoke component="#getItem#" method="#MissingMethodName#" 
						argumentcollection="#MissingMethodArguments#" />
				</cfif>
			</cfdefaultcase>
		</cfswitch>
		
		<cfif isDefined("result")><cfreturn result /></cfif>
	</cffunction>	
</cfcomponent>