<cfset getTap().getPage().meta["Content-Language"] = Replace(REREplace(getTap().getLocal().language,"^(\w{2})(_\w{2})?.*$","\1\2"),"_","-")>
<cfoutput><!--- display meta tags for this page --->
	<cfloop item="tag" collection="#getTap().getPage().meta#">
		<meta name="#tag#" http-equiv="#tag#" content="#htmleditformat(getTap().getPage().meta[tag])#" />
	</cfloop>
</cfoutput>
