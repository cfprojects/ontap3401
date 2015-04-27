<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">

	<cf_doc>
			<spec>
				<library name="core">
					<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" return="string" xref="">
						<usage>
							outputs a tag with attributes 
							-- usually used to output ColdFusion tags in pregenerated templates 
							-- all attribute names are lower case, which is less than useful for xml tags with mixed-case attributes 
						</usage>
						<attributes>
							<attribute name="tag" required="true" type="string" default="">the element name for the tag in question -- in some cases may include additional code, i.e. cfset</attribute>
							<attribute name="tagname" required="false" type="string" default="">allows a name attribute to be passed to the output tag -- drives template attribute for cfmodule or cfinclude</attribute>
							<attribute name="n" required="false" type="any" default="n/a">any additional attributes are passed to the tag to be output</attribute>
						</attributes>
					</tag>
				</library>
			</spec>
		</cf_doc>

<cfelse>
	<cfsilent>
		<cfset structdelete(attributes,"tapdocs")>
		<!--- this tag is used to output another tag 
		-- this is primarily used for property template cacheing in the class manager 
		-- although it may also be used for custom content types which are intended  
		-- to generate coldfusion code such as display method of the template class --->
		<cfparam name="attributes.tag" type="string">
		<cfset variables.tag = trim(attributes.tag)>
		<cfset variables.tagname = rereplace(variables.tag,"^([^[:space:]]*).*$","\1","ALL")>
		
		<!--- the tagname attribute allows a name or template attribute to be passed 
		-- for cfmodule, cfdirectory or cfquery tags --->
		<cfif structkeyexists(attributes,"tagname")>
			<cfswitch expression="#variables.tag#">
				<cfcase value="cfmodule,cfinclude" delimiters=",">
				<cfset attributes.template = attributes.tagname></cfcase>
				
				<cfdefaultcase><cfset attributes.name = attributes.tagname></cfdefaultcase>
			</cfswitch>
			<cfset structdelete(attributes,"tagname")>
		</cfif>
				
		<cfif left(variables.tagname,2) is not "cf">
			<!--- htmleditformat all the attributes for this non-cf tag --->
			<cfloop item="i" collection="#attributes#">
			<cfset attributes[i] = htmleditformat(attributes[i])></cfloop>
		</cfif>
	</cfsilent>
	
	<!--- display the tag and attributes --->
	<cfswitch expression="#thistag.executionmode#">
		<cfcase value="start"><cfoutput>
			<#variables.tag#<cfloop item="x" collection="#attributes#"
				><cfif issimplevalue(attributes[x]) and not listfindnocase("tag",x)
				> #lcase(x)#="#attributes[x]#"</cfif></cfloop
			><cfif not thistag.hasendtag>/</cfif>></cfoutput>
		</cfcase>
		
		<cfcase value="end"><cfoutput>
			</#variables.tagname#></cfoutput>
		</cfcase>
	</cfswitch>
</cfif>
