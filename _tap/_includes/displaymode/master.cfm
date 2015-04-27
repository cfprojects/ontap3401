<cfparam name="tap.view.mode" type="string" default="master" />

<cfif tap.view.mode is "master">
	<cfif tap.isLocal and structKeyExists(attributes,"return")>
		<cfset tap.view.mode = "contentvariable" />
	<cfelseif len(trim(tap.view.mail.to)) and len(trim(tap.view.mail.subject))>
		<cfset tap.view.mode = "email" />
	<cfelseif getTap().getPage().doctype is "javascript">
		<cfset tap.view.mode = "gateway" />
	<cfelseif isStruct(tap.goto.href) or len(trim(tap.goto.href))>
		<cfset tap.view.mode = "redirect" />
	<cfelseif len(trim(tap.view.download.file))>
		<cfset tap.view.mode = "download" />
	<cfelseif isStruct(tap.view.content) or len(trim(tap.view.content))>
		<cfif len(trim(tap.view.doc.format))>
			<cfset tap.view.mode = "doc" />
		<cfelse>
			<cfset tap.view.mode = "html" />
		</cfif>
	<cfelse>
		<cfset tap.view.mode = "filenotfound" />
	</cfif>
</cfif>

<cfinclude template="#tap.view.mode#.cfm" />
