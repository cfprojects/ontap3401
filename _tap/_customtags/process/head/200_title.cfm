<!--- display the markup header title --->
<cfif len(trim(getTap().getPage().head.title))>
	<cfoutput><title>#htmleditformat(getTap().getPage().head.title)#</title></cfoutput>
</cfif>
