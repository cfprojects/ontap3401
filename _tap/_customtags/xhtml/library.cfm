<cfparam name="attributes.tapdocs" default="false">
<cfif attributes.tapdocs>
	<cfinclude template="/cfc/mixin/tap.cfm" />
	<cfoutput>#getTap().getRequestLibraries().getDocs("xhtml")#</cfoutput>
</cfif>
