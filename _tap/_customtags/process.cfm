<cfparam name="variables.tap" type="struct" default="#structnew()#">
<cfparam name="variables.tap.islocal" type="boolean" default="true">

<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif attributes.tapdocs and variables.tap.islocal>
	<cfparam name="attributes.xml" type="boolean" default="false">
	
	<cf_doc>
		<spec>
			<library name="core">
				<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" return="none" xref="core/process">
					<usage>
						This custom tag processes the html head, layout header, content and layout body stages of a request.
						From a base template this tag is called using cfinclude and executes the html head stage. 
						From other templates this tag is called using cfmodule and bypasses the html head stage
						and suppresses display of the html body tags.
					</usage>
					<attributes>
						<attribute name="netaction" required="false" type="string" default="">part or all of a process path i.e. as a url index.cfm?netaction=products or as a custom tag &lt;cfmodule netaction=&quot;index/products&quot;&gt;</attribute>
						<attribute name="netcallback" required="false" type="boolean" default="false">when true execution of the process is delayed and queued for processing in the onrequestend stage of the request</attribute>
					</attributes>
				</tag>
			</library>
		</spec>
	</cf_doc>

<cfelse>
	
	<cfif tap.isLocal>
		<cfinclude template="/cfc/mixin/tap.cfm" />
		<cfset tap.goto = structNew() />
		<cfset tap.goto.href = "" />
		<cfset tap.goto.domain = "T" />
	<cfelse>
		<cfset tap.goto = getTap().getCF().onrequestend.goto />
	</cfif>
	<cfparam name="tap.view" default="#structNew()#" />
	<cfparam name="tap.view.content" default="" />
	<cfparam name="tap.view.mode" default="master" />
	<cfset tap.view.download = structNew() />
	<cfset tap.view.download.file = "" />
	<cfset tap.view.mail = structNew() />
	<cfset tap.view.mail.subject = "" />
	<cfset tap.view.mail.to = "" />
	<cfset tap.view.doc = structNew() />
	<cfset tap.view.doc.format = "" />
	
	<cfparam name="attributes.netaction" type="string" />
	<cfparam name="attributes.netcallback" type="boolean" default="false" />
	
	<cfif variables.tap.islocal and attributes.netcallback>
		<!--- if this process is requested as a callback delay processing for the onrequestend stage --->
		<cfset structdelete(attributes,"netcallback") />
		<cfset arrayappend(getTap().getCF().onrequestend.process,attributes) />
	<cfelse>
		<cfif variables.tap.islocal>
			<!--- create local mappings based on the netaction variable and --->
			<cfset attributes.netaction = getTap().getProcess().tPath(attributes.netaction) />
			<cfset tap.nest = getTap().getProcess().getArray(attributes.netaction) />
			<cfset tap.process = variables.tap.nest[arraylen(variables.tap.nest)] />
		<cfelse>
			<!--- copy local mappings from request scope --->
			<cfset variables.tap.nest = getTap().getPath().nest />
			<cfset variables.tap.process = getTap().process />
			
			<!--- declare the document type --->
			<cfif findnocase("html",getTap().getPage().doctype)>
				<cfoutput>
					#getTap().getPage().doctype#
					<html #getLib().structToAttributes(getTap().getPage().html)#>
					<head>
					
					<!--- set processing stage --->
					<cfset getTap().getPage().layout = "htmlhead">
					
					<!--- display the html head markup for the current area and process --->
					<cfloop index="cfmod" list="#arraytolist(getFS().templateArray('process/head','C'))#">
					<cfinclude template="#cfmod#"></cfloop>
					</head>
					
					<!--- display html body tag --->
					<cfset getTap().getPage().layout = "body">
					<body #getLib().structToAttributes(getTap().getPage().body)#>
				</cfoutput>
			</cfif>
		</cfif>
		
		<!--- execute the core process and generate any associated html including layouts --->
		<cfloop index="cfmod" list="#arraytolist(getFS().templateArray('process/body','C'))#">
		<cfinclude template="#cfmod#"></cfloop>
		
		<!--- close markup for the requested page --->
		<cfif not variables.tap.islocal and findnocase("html",getTap().getPage().doctype)>
			<cfoutput></body></html></cfoutput>
		</cfif>
	</cfif>

</cfif>

<cfexit method="exittag">
