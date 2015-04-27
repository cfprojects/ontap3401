<!--- do not allow these documents to be accessed directly 
-- css and js templates are allowed public access 
-- in the event that they have been assigned to the ColdFusion Server --->
<cfswitch expression="#listlast(getbasetemplatepath(),'.')#">
	<cfcase value="css,js,cfc" delimiters=","></cfcase>
	<cfdefaultcase>
		<cfsetting showdebugoutput="false" />
		<cfabort>
	</cfdefaultcase>
</cfswitch>

