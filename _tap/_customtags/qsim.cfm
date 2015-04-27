<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">

	<cf_doc>
			<spec>
				<library name="core">
					<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" xref="">
						<usage>creates a query from a set of text rows with individual cells being pipe-delimited</usage>
						<example>&lt;cf_qsim columns=&quot;col1,col2,col3,col4&quot; return=&quot;myquery&quot;&gt;this|is|a|query&lt;/cf_qsim&gt;
						</example>
						<attributes>
							<attribute name="columns" required="true" type="string" default="n/a">a comma delimited list of columns to return in the query</attribute>
							<cfset variables.returnrequired = true>
							<cfinclude template="docs/returnattributes.cfm">
						</attributes>
					</tag>
				</library>
			</spec>
		</cf_doc>

<cfelse>
	<cfif thistag.executionmode is "start">
		<cf_outputonly enable="false" return="outonly" />
	<cfelse>
		<cfparam name="outonly" default="0" />
		<cfif outonly><cf_outputonly enable="true" repeat="#outonly#" /></cfif>
		<cfparam name="attributes.columns" type="string">
		<cfparam name="attributes.return" type="string">
		
		<cfinclude template="/cfc/mixin/tap.cfm" />
		
		<cfset rs = QueryNew(attributes.columns)>
		<cfset row = listtoarray(thistag.generatedcontent,chr(13) & chr(10))>
		<cfset lencols = listlen(attributes.columns)>
		
		<cfloop index="x" from="1" to="#arraylen(row)#">
			<cfif len(trim(row[x]))>
				<cfset queryaddrow(rs,1)>
				<cfloop index="y" from="1" to="#lencols#">
					<cfset col = getToken(attributes.columns,y,",")>
					<cfset cell = rereplacenocase(trim(getToken(row[x],y,"|")),"^null$","")>
					<cfset querysetcell(rs,col,cell,rs.recordcount)>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfset thistag.generatedcontent = "">
		<cfinclude template="#getFS().return(rs)#">
	</cfif>
</cfif>

