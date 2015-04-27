<!--- ColdFusion 9 changes the behavior of the onRequestEnd event 
-- prior versions did NOT execute onRequestEnd after a CFABORT or CFLOCATION tag 
-- CF 9 now executes onRequestEnd in both of these cases 
-- this CFEXIT prevents this template from executing twice and causing an "undefined in request" error --->
<cfif structIsEmpty(request)>
	<cfexit method="exittemplate" />
</cfif>

<!--- allow page content to be flushed prior to onrequestend processing 
-- this will allow some slower processes to execute 
-- while a user is passed on to the next page using getLib().location() --->

<cfif not isDefined("variables.gettap")>
	<cfinclude template="/cfc/mixin/tap.cfm" />
</cfif>

<cfif getTap().getPage().layout is "onrequestend"><cfexit method="exittag"></cfif>
<cfset getTap().getPage().layout = "onrequestend">

<!--- prepare the goto variable to redirect pages from generated external javascript or from javascript disabled pages --->
<cfset cf = getTap().getCF() />
<cfset end = cf.onrequestend />
<cfset goto = end.goto>

<cfparam name="goto.timeout" type="numeric" default="#cf.app.timeout_request#">
<cfparam name="goto.window" type="string" default="window">
<cfparam name="goto.protocol" type="string" default="#getTap().getHref().protocol#">
<cfif isstruct(goto.href)><cfset goto.href = getLib().structToUrl(goto.href)></cfif>

<cfif end.flush and (getTap().getPage().script or not len(goto.href))>
	<cftry>
		<cfif len(goto.href) and getTap().getPage().script>
			<cfoutput>#getLib().jsout(getLib().js.location(goto.href,goto.domain,goto.window,goto.timeout,goto.protocol,false))#</cfoutput>
		</cfif>
		<cfflush />
		<cfcatch></cfcatch>
	</cftry>
</cfif>

<!--- execute processes triggered by the requested event --->
<cfif arraylen(end.process)>
	<cfloop condition="arraylen(end.process)">
		<!--- removing the element from the array before calling the process  
		prevents potential infinite loops from processes which call getTap().abort() --->
		<cfset temp = end.process[1]>
		<cfset arraydeleteat(end.process,1)>
		<cf_process attributecollection="#temp#">
	</cfloop>
</cfif>

<!--- include onrequestend content from nested subdirectories --->
<cftry>
	<cfset temp = getTap().getPath().nest>
	<cfcatch><cfset temp = arrayNew(1)></cfcatch>
</cftry>

<cfif ArrayLen(temp)>
	<cfloop index="cfmod" list="#arraytolist(request.fs.processTemplates(temp,getTap().getPage().layout,true))#">
	<cfinclude template="#cfmod#"></cfloop>
</cfif>

<!--- if the current request is a javascript-disabled request and a goto url has been declared, go to the specified url --->
<cfif len(goto.href) and not getTap().getPage().script>
	<cftry>
		<cflocation url="#getLib().getURL(goto.href,goto.domain,goto.timeout,goto.protocol)#" addtoken="false">
		<cfcatch></cfcatch>
	</cftry>
</cfif>

<!--- apply the framework's debugging settings as the last command in the request for consistency --->
<cfsetting showdebugoutput="#end.debug#">
<cfif end.debug>
	<cfset getTap().getPage().layout = "debug">
	<cf_process netaction="debug">
</cfif>

<!--- this seems to help resolve a leaky-memory issue in CF/JRun --->
<cfset structClear(variables) />
<cfset structClear(request) />
<cfabort>
