<!--- include cascading markup header information --->
<cfset headerTemplateArray = getFS().processTemplates(
	variables.tap.nest,getTap().getPage().layout,false,getTap().development,
	replacenocase(getTap().contentfilter,"cfm","(cfm|css|js)"),false)>

<cfif getTap().getPage().borderbox>
	<cfinclude template="/style/boxsizing.cfm" />
</cfif>

<cfloop index="tap_index" from="1" to="#arraylen(headerTemplateArray)#">
	<cfset tap_template = headerTemplateArray[tap_index]>
	<cfif listlast(tap_template,".") is not "cfm">
	<cfset tap_template = rereplacenocase(tap_template,"^[^_[:alnum:]]*","")></cfif>
	<cfswitch expression="#listlast(tap_template,'.')#">
		<cfcase value="cfm"><cfinclude template="#tap_template#"></cfcase>
		<cfcase value="css"><cfprocessingdirective suppresswhitespace="false"><cfoutput>
			#getLib().getStyle(listrest(tap_template,"\/"),"T","")#
		</cfoutput></cfprocessingdirective></cfcase>
		<cfcase value="js">
			<cfif getTap().getPage().script><cfprocessingdirective suppresswhitespace="false"><cfoutput>
				#getLib().jslib(listrest(tap_template,"\/"),"T")#
			</cfoutput></cfprocessingdirective></cfif>
		</cfcase>
	</cfswitch>
</cfloop>
