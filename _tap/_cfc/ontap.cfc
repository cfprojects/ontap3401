<cfcomponent displayname="onTap" hint="this is a basic component for the onTap framework. Many other CFC's in the ontap framework ultimately extend this for common functionality">
	<cfset variables.prop = structnew()>
	
	<cfinclude template="/cfc/mixin/tap.cfm" />
	
	<cffunction name="init" output="false" hint="initializes the CFC with required properties, etc.">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="extend" access="private" output="false" hint="injects mixin methods from another component into this one in a manner similar to inheritance">
		<cfargument name="className" type="string" required="true" />
		<cfset getLib().cfcExtend(this,arguments.className) />
	</cffunction>
	
	<cffunction name="getObject" access="private" output="false" hint="returns an instantiated but uninitialized object">
		<cfargument name="component" type="string" required="true" />
		<cfreturn CreateObject("component",arguments.component) />
	</cffunction>
	
	<cffunction name="getProperty" returntype="any" access="private" output="false"
	hint="gets properties from the current object - all custom get methods should set properties with this method - overwriting this method (in addition to setProperty) allows you to change the location of all properties stored for the component">
		<cfargument name="propertyname" type="string" required="true">
		
		<cfif structkeyexists(variables.prop,propertyname)>
			<cfreturn variables.prop[propertyname]>
		<cfelse><cfreturn ""></cfif>
	</cffunction>
	
	<cffunction name="setProperty" returntype="void" access="private" output="false"
	hint="sets properties in the current object - all custom set methods should set properties with this method - overwriting this method (in addition to getProperty) allows you to change the location of all properties stored for the component">
		<cfargument name="propertyname" type="string" required="true" hint="the name of the property to set">
		<cfargument name="propertyvalue" type="any" required="true" hint="the value to set for the property">
		<cfargument name="overwrite" type="boolean" default="true" hint="if false an existing property value will be preserved">
		<cfset var temp = structnew() />
		<cfset var observer = getObservers() />
		<cfset var x = 0 />
		
		<cfset temp[propertyname] = propertyvalue>
		<cfset structappend(variables.prop,temp,overwrite)>

		<cfif structkeyexists(observer,propertyname)>
			<cfset arguments.instance = this>
			<cfset observer = observer[propertyname]>
			<cfloop index="x" from="1" to="#arraylen(observer)#">
				<cfinvoke component="#observer[x]#" method="observe" 
					argumentcollection="#arguments#">
			</cfloop>
		</cfif>
	</cffunction>
	
	<cffunction name="getValue" returntype="any" access="public" output="false" 
	hint="returns a property or variable from the component -- uses a private method if it exists for any property">
		<cfargument name="propertyname" type="string" required="true" hint="the name of the property value to return">
		<cfset var methodname = "getProperty">
		<cfset var returnvalue = "">
		
		<cfif structkeyexists(variables,"get_" & propertyname) 
		and iscustomfunction(variables["get_" & propertyname])>
		<cfset methodname = "get_" & propertyname></cfif>
		
		<cfinvoke method="#methodname#" argumentcollection="#arguments#" returnvariable="returnvalue">
		
		<cfreturn returnvalue>
	</cffunction>
	
	<cffunction name="setValue" access="public" output="false" 
	hint="sets a property or variable in the component -- uses a private method if it exists for any property">
		<cfargument name="propertyname" type="string" required="true" hint="the name of the property to set">
		<cfargument name="propertyvalue" type="any" required="true" hint="the value to set for the property named">
		<cfargument name="overwrite" type="boolean" default="true" hint="determines if the provided value should overwrite an existing property">
		<cfset var methodname = "setProperty">

		<cfif structkeyexists(variables,"set_" & propertyname) 
		and iscustomfunction(variables["set_" & propertyname])>
		<cfset methodname = "set_" & propertyname></cfif>
		
		<cfinvoke method="#methodname#" argumentcollection="#arguments#">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setProperties" output="false" access="public" 
	hint="sets all properties for a cfc simultaneously using the setValue method to preserve custom setValue functions and observer functionality">
		<cfargument name="properties" required="false" default="" hint="a structure or query containing keys which match the keys of the property structure">
		<cfargument name="overwrite" type="boolean" required="false" default="true" hint="when false the component's existing properties will be preserved">
		<cfargument name="index" type="numeric" required="false" default="1" hint="if the properties argument is a query the index argument can be used to determine what row of the query is used to populate the object">
		<cfset var x = "">
		
		<cfif isObject(properties) 
		and structKeyExists(properties,"getProperties") 
		and isCustomFunction(properties.getproperties)>
			<!--- allows another derivative of ontap.cfc to be used directly as the source 
			- without calling getProperties() explicitly -- makes duck-typing easier --->
			<cfset setProperties(properties.getProperties(), overwrite) />
		<cfelseif isStruct(properties)>
			<!--- this is the default behavior -- all others are routed to this --->
			<cfloop item="x" collection="#properties#">
				<cfset this.setValue(x, properties[x], overwrite)>
			</cfloop>
		<cfelseif isQuery(properties)>
			<!--- sometimes it's useful to loop over a query and populate an object --->
			<cfset var p = structNew() />
			<cfloop index="x" list="#properties.columnlist#">
				<cfset p[x] = properties[x][arguments.index] />
			</cfloop>
			<cfset setProperties(p, overwrite) />
		<cfelseif isSimpleValue(arguments.properties)>
			<!--- allows the argumentcollection to be used as the properties, 
			- in case an implicit struct {} is accidentally omitted in the setProperties() call --->
			<cfif not len(trim(arguments.properties))>
				<cfset structDelete(arguments,"properties")>
			</cfif>
			<cfset structDelete(arguments,"overwrite")>
			<cfset structDelete(arguments,"index")>
			<cfreturn setProperties(arguments)>
		</cfif>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getProperties" output="false" access="public" 
	hint="returns all properties from a cfc in a structure">
		<cfset var returnstruct = structnew()>
		<cfset var x = 0 />
		
		<cfloop index="x" list="#getpropertylist()#">
			<cfset returnstruct[x] = getValue(x)>
		</cfloop>
		
		<cfreturn returnstruct>
	</cffunction>
	
	<cffunction name="getPropertylist" output="false" access="private" 
	hint="returns the names of all properties from a cfc as a list">
		<cfreturn structkeylist(variables.prop)>
	</cffunction>
	
	<cffunction name="getObservers" returntype="struct" output="false" access="private">
		<cfparam name="variables.observers" type="struct" default="#structnew()#">
		<cfreturn variables.observers>
	</cffunction>
	
	<cffunction name="addObserver" output="false" access="public"
	hint="adds an observer to the current CFC to alert another CFC or when a property of the CFC is alterred">
		<cfargument name="property" type="string" required="true" hint="the property to which interest should be registered">
		<cfargument name="observer" type="any" required="true" hint="the object interested in the property - the observer object must have a corresponding observe_[property] method">
		<cfset var stObservers = getObservers()>
		
		<cfif not structkeyexists(stObservers,property)>
		<cfset stObservers[property] = arraynew(1)></cfif>
		<cfset arrayappend(stObservers[property],observer)>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="observe" output="false" 
	hint="handles events returned by watching another components properties">
		<cfargument name="propertyname" type="string" required="true">
		<cfset var methodname = "observe_" & propertyname>
		
		<cfif structkeyexists(variables,methodname) and isCustomFunction(variables[methodname])>
			<cfinvoke method="#methodname#" argumentcollection="#arguments#">
		</cfif>
	</cffunction>
	
	<cffunction name="raiseMissingMethodException" access="private" output="false">
		<cfargument name="MissingMethodName" type="string" required="true" hint="The name of the missing method." />
		<cfthrow type="onTap.cfc.MissingMethod" message="onTap: Say What? Missing Method - I don't understand the method name #MissingMethodName#()" />
	</cffunction>
	
	<cffunction name="identifyAccessorOrMutator" access="private" output="false" returntype="struct">
		<cfargument name="MissingMethodName" type="string" required="true" hint="The name of the missing method." />
		<cfargument name="MissingMethodArguments" type="struct" required="true" />
		<cfscript>
			var st = structNew(); 
			st.property = ""; 
			st.data = ""; 
			st.method = left(MissingMethodName,3); 
			
			switch (st.method) { 
				case "get": { 
					if (not structIsEmpty(MissingMethodArguments)) { st.method = ""; } 
					break; 
				} 
				case "set": { 
					if (ArrayLen(MissingMethodArguments) eq 1) { st.data = MissingMethodArguments[1]; } 
					else { st.method = ""; } 
					break; 
				} 
				default: { st.method = ""; } 
			} 
			
			if (len(trim(st.method))) { st.property = rereplacenocase(MissingMethodName,"^[gs]et_?",""); } 
			if (not len(trim(st.property))) { st.method = ""; } 
			
			return st; 
		</cfscript>
	</cffunction>
	
	<cffunction name="debug" access="public" output="true" returntype="void" hint="used for debugging objects during active development - should not appear in production code">
		<cfargument name="thing" type="any" required="false" default="#variables.prop#" />
		<cfargument name="abort" type="boolean" required="false" default="true" />
		<cfcontent reset="true" />
		
		<cfif isSimpleValue(thing)>
			<cfoutput><pre>#htmleditformat(thing)#</pre></cfoutput>
		<cfelse>
			<cfdump var="#thing#" />
		</cfif>
		
		<cfif arguments.abort><cfabort /></cfif>
	</cffunction>
	
	<cffunction name="onMissingMethod" access="public" returntype="any" output="false" hint="Handles missing method exceptions.">
		<cfargument name="MissingMethodName" type="string" required="true" hint="The name of the missing method." />
		<cfargument name="MissingMethodArguments" type="struct" required="true" 
			hint="The arguments that were passed to the missing method. This might be a named argument set or a numerically indexed set." />
		<cfscript>
			var st = identifyAccessorOrMutator(MissingMethodName,MissingMethodArguments); 
			var result = this; 
			
			switch (st.method) { 
				case "get": { result = getValue(st.property); break; } 
				case "set": { result = setValue(st.property,st.data); break; } 
				default: { raiseMissingMethodException(MissingMethodName); } 
			} 
			
			if (isDefined("result")) { return result; } 
		</cfscript>
	</cffunction>
</cfcomponent>