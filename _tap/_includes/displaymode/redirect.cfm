<cfif getTap().getPage().doctype is "javascript">
	<cf_goto attributecollection="#tap.goto#" />
	<cfset tap.goto.href = "" />
	<cfset caller.tap.goto.href = "" />
<cfelse>
	<cfif isStruct(tap.view.content)>
		<cfset getLib().html.childRemove(tap.view.content,0) />
	<cfelse>
		<cfset tap.view.content = getLib().html.new("div") />
	</cfif>
	<cfset getLib().ls("%tap_linkContinue","continue",false) />
	<cfset getLib().html.childAdd(tap.view.content,getLib().html.linkNew("%tap_linkContinue",tap.goto.href,tap.goto.domain)) />
	<cfset getLib().html.childAdd(tap.view.content,getLib().jsout(getLib().js.location(tap.goto.href,tap.goto.domain))) />
	
	<cfinclude template="html.cfm">
</cfif>
<cfset getTap().abort(debug=false)>
