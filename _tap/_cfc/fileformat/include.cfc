<cfcomponent displayname="Include File Format" extends="fileformat">
	<cfset variables.format = "include">
	<cfset variables.currentpath = getDirectoryFromPath(getCurrentTemplatePath())>
	
	<cffunction name="cfmlFormat" access="private" output="false" returntype="string">
		<cfargument name="str" type="string" required="true">
		<cfreturn REReplace(str,"([##""])","\1\1","ALL")>
	</cffunction>
	
	<cffunction name="textToOutput" access="private" output="false" returntype="any">
		<cfargument name="output" type="string" required="true">
		<cfset var filedata = "">
		<cfmodule template="include.cfm" attributecollection="#arguments#">
		<cfreturn filedata>
	</cffunction>
	
	<cffunction name="outputToText" access="private" output="false" returntype="string">
		<cfargument name="output" type="any" required="true">
		<cfset var my = structnew()>
		<cfset var x = 0>
		
		<cfset my.cfml = ArrayNew(1)>
		<cfset my.type = "struct">
		<cfif isArray(output)><cfset my.type = "array"></cfif>
		
		<cfset arrayAppend(my.cfml,"<cfprocessingdirective pageencoding=""#arguments.charset#"">")>
		<cfset arrayAppend(my.cfml,"<cfscript>")>
		<cfswitch expression="#my.type#">
			<cfcase value="struct">
				<cfset arrayappend(my.cfml,"variables.returnvalue = structNew();")>
				<cfloop item="x" collection="#output#">
					<cfif isSimpleValue(output[x])>
						<cfset arrayAppend(my.cfml,'variables.returnvalue["#x#"] = "#cfmlFormat(output[x])#";')>
					</cfif>
				</cfloop>
			</cfcase>
			<cfcase value="array">
				<cfset arrayappend(my.cfml,"variables.returnvalue = arrayNew(1);")>
				<cfloop index="x" from="1" to="#arraylen(output)#">
					<cfif isSimpleValue(output[x])>
						<cfset arrayAppend(my.cfml,'variables.returnvalue[#x#] = "#cfmlFormat(output[x])#";')>
					</cfif>
				</cfloop>
			</cfcase>
		</cfswitch>
		<cfset arrayAppend(my.cfml,"</cfscript>")>
		
		<cfreturn ArrayToList(my.cfml,getTap().newline())>
	</cffunction>
</cfcomponent>