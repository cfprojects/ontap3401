<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">

	<cf_doc>
		<spec>
			<library name="core">
				<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" xref="core/cache.cfm">
					<usage>
						caches blocks of ColdFusion output in the application scope 
						to speed delivery of page content which changes less frequently than it is viewed
						-- uses either a cachedafter date or a cachedwithin duration (with datepart) to 
						determine if the application cache should be used for a given request 
						-- if neither cachedafter or cachedwithin are specified, 
						cache is deleted from the application scope 
					</usage>
					<example>&lt;cf_content 
						cachename=&quot;_layout.mainmenu.#variables.tap.process#&quot;
						cachedafter=&quot;1/1/1970&quot;&gt;...menu here...&lt;/cf_content&gt;</example>
					<attributes>
						<attribute name="cachename" required="false" type="string" default="n/a">
							a string to uniquely identify the content being saved 
							-- dots in the string will create nested structures 
							-- if the cachename is a zero-length string the content is not cached
						</attribute>
						<attribute name="cachedafter" required="false" type="date" default="#getTap().appstart.time#">a date after which the content should be cached</attribute>
						<attribute name="cachedwithin" required="false" type="numeric" default="n/a">a number of increments of the datepart value to store the cache</attribute>
						<attribute name="datepart" required="false" type="string" default="n">s = seconds, n = minutes, h = hours, d = days</attribute>
						<attribute name="locale" required="false" type="string" default="#getTap().getLocal().language#">indicates the language/locale to which the cached content belongs</attribute>
						<attribute name="brand" required="false" type="string" default="#getTap().getPath().brand#">indicates the brand to which the cached content belongs</attribute>
						<cfinclude template="docs/returnattributes.cfm">
					</attributes>
				</tag>
			</library>
		</spec>
	</cf_doc>
<cfelse>
	<cfparam name="attributes.cachename" type="string" default="">
	
	<!--- if a cachename is not provided don't modify the content --->
	<cfif len(trim(attributes.cachename))>
		<cfswitch expression="#thistag.executionmode#">
			<cfcase value="start">
				<cfinclude template="/cfc/mixin/tap.cfm" />
				<cfparam name="attributes.cachedwithin" type="string" default="">
				<cfparam name="attributes.datepart" type="string" default="n">
				<cfparam name="attributes.cachedafter" type="string" default="#iif(isNumeric(attributes.cachedwithin),de(''),'getTap().appstart.time')#">
				<cfparam name="attributes.locale" type="string" default="">
				<cfparam name="attributes.brand" type="string" default="#getTap().getPath().brand#">
				<cfparam name="attributes.return" type="string" default="">
				
				<cfif not len(trim(attributes.locale))>
					<cfset attributes.locale = getTap().getLocal().language>
				</cfif>
				
				<cfset variables.cachename = REREplaceNoCase(attributes.cachename,
					"^((cluster|server|application|session)\.)?(.*)$",
					"\1tap_content.\3.#attributes.brand#.#attributes.locale#")>
				
				<cfset agent = getIoC().getBean("cachemanager") />
				<cfset cache = agent.fetch(variables.cachename,attributes.cachedafter) />
				
				<cfif not cache.status>
					<cfif len(trim(attributes.return))>
						<cfinclude template="#getFS().return(cache.content)#">
					<cfelse>
						<cfoutput>#cache.content#</cfoutput>
					</cfif>
					<cfexit method="exittag">
				</cfif>
			</cfcase>
			
			<cfcase value="end">
				<cfset agent = getIoC().getBean("cachemanager") />
				<cfset cache = agent.store(variables.cachename,trim(thistag.generatedcontent),attributes.cachedwithin,attributes.datepart) />
				<cfif len(trim(attributes.return))>
					<cfinclude template="#getFS().return(thistag.generatedcontent)#">
					<cfset thistag.generatedcontent = "">
				</cfif>
			</cfcase>
		</cfswitch>
	</cfif>
</cfif>

