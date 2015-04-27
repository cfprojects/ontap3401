<cfset tap.view.mail.subject = getLib().ls(tap.view.mail.subject)>
<cf_mail attributecollection="#tap.view.mail#">
	<cf_mail part="text"><cf_display text="#tap.view.content#" /></cf_mail>
	<cf_mail part="html"><cf_display html="#tap.view.content#" /></cf_mail>
</cf_mail>

<cfif isStruct(tap.goto.href) or len(trim(tap.goto.href))>
	<cfinclude template="redirect.cfm" />
</cfif>
