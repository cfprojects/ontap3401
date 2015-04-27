<cfparam name="variables.returnrequired" type="boolean" default="false">
<cfparam name="variables.returndefault" type="string" default="n/a">

<cfoutput>
	<attribute name="scope" required="false" type="string|struct" default="caller">
		the scope in which data should be returned 
		- may be a string representation of the scope name 
		or a structure within which variables may be created 
	</attribute>
	<attribute name="return" required="#variables.returnrequired#" 
		type="string" default="#variables.returndefault#">
		a name to identify the variable returned within the specified scope 
		-- data is not returned if this string is of zero length 
	</attribute>
</cfoutput>

