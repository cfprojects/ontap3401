<!--- make the requesttimeout variable work the same for cfmx as for cf5 --->
<cfparam name="attributes.requesttimeout" type="numeric" default="#getTap().getCF().app.timeout_request#">
<cfif attributes.requesttimeout><cfsetting requesttimeout="#attributes.requesttimeout#"></cfif>

