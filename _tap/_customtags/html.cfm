<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">
	
	<cf_doc>
		<spec>
			<library name="mx">
				<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" return="struct|string" xref="">
					<usage>
						Provides an alternate syntax for creating html structures 
						for use with the html library, comparable to creating xml with the cfxml tag 
						- if no return attribute is specified the html is displayed directly to the ColdFusion output buffer 
						- this provides convenient access to html library features such as tabsets 
					</usage>
					<example></example>
					<attributes>
						<cfinclude template="docs/returnattributes.cfm">
						<attribute name="file" required="false" type="string" default="">indicates a file from which xml content should be used -- if the file is empty or not found the tag will default to its generated content</attribute>
						<attribute name="url" required="false" type="string" default="">indicates a url from which xml content should be used -- if an http error occurs or no content is returned the tag will default to its generated content</attribute>
						<attribute name="parent" required="false" type="html" default="n/a">when specified the content generated from the xhtml tag is added to the child array of the provided html element</attribute>
						<attribute name="position" required="false" type="numeric" default="0">indicates the position the generated content is added in the child array of the parent element - defaults to the end of the child array</attribute>
						<attribute name="formdata" required="false" type="struct" default="#caller.attributes#">any form fields in the returned structure are populated with data from this structure</attribute>
						<attribute name="cachename" required="false" type="string" default="">the name of a variable to cache the resulting content</attribute>
						<attribute name="cachedafter" required="false" type="date" default="n/a">a time after which the content should be cached</attribute>
						<attribute name="cachedwithin" required="false" type="integer" default="n/a">a number of increments of time within which to cache the content</attribute>
						<attribute name="datepart" required="false" type="string" default="n">used with the cachedwithin attribute to determine the amount of time cached data remains relevant - defaults to minutes</attribute>
						<attribute name="datasource" required="false" type="string" default="primary">indicates an instantiated datasource object for use in generating automated content</attribute>
						<attribute name="dbtable" required="false" type="string" default="n/a">used with the dbtable attribute to automate certain form features such as input lengths</attribute>
						<attribute name="skin" required="false" type="string" default="ontap">indicates an array of xslt templates in the getTap().getHTML().skin structure from which xhtml content should be transformed</attribute>
						<attribute name="locale" required="false" type="string" default="#getTap().getLocal().language#">indicates the locale for which the content applies -- used to cache content in multiple languages</attribute>
						<attribute name="brand" required="false" type="string" default="#getTap().getPath().brand#">indicates the brand to which the cached content belongs</attribute>
						<attribute name="gateway" required="false" type="string" default="#url.csgate#">indicates the client-server gateway for which the generated html should be returned -- use VOID to indicate that no gateway should be used</attribute>
					</attributes>
				</tag>
			</library>
		</spec>
	</cf_doc>
<cfelse>
	<cftry>
		<cfif thistag.executionmode is "start">
			<cfinclude template="/cfc/mixin/tap.cfm" />
			<cfparam name="attributes.cachename" type="string" default="">
			<cfparam name="attributes.cachedafter" type="string" default="#getTap().appstart.time#">
			<cfparam name="attributes.cachedwithin" type="string" default="">
			<cfparam name="attributes.datepart" type="string" default="n">
			
			<cfsilent>
				<cffunction name="returnHTMLContent">
					<cfif len(trim(getLib().html.id(attributes.parent)))>
						<cfset getLib().html.childAdd(attributes.parent,html,attributes.position)>
					</cfif>
					
					<cfif len(trim(attributes.return))>
						<!--- return content to the calling template --->
						<cfinclude template="#getFS().return(html)#">
					<cfelseif not len(trim(getLib().html.id(attributes.parent)))>
						<!--- we're not returning and we're not attaching to a parent html structure, so that means we're displaying and we can cache after display --->
						<cfset cache = getLib().html.show(html) />
						
						<cfif len(trim(attributes.cachename))>
							<cfset agent = getIoC().getBean("cachemanager") />
							<cfset agent.store(variables.cachename & ".display",cache,attributes.cachedwithin,attributes.datepart) />
						</cfif>
						
						<cfif getTap().getPage().doctype is "javascript">
							<cfparam name="attributes.gateway" type="string" default="#getLib().arg(url,'csgate','')#" />
							
							<cfif len(attributes.gateway) and comparenocase(attributes.gateway,"void")>
								<cfoutput>#getLib().html.gatewayrespond(cache,attributes.gateway)#</cfoutput>
							<cfelse>
								<cfoutput>#cache#</cfoutput>
							</cfif>
						<cfelse>
							<cfoutput>#cache#</cfoutput>
						</cfif>
						<cfexit method="exittag" />
					</cfif>
				</cffunction>
				
				<cfparam name="attributes.scope" type="any" default="#caller#">
				<cfparam name="attributes.formdata" type="any" default="#iif(structkeyexists(attributes.scope,'attributes'),'attributes.scope.attributes','form')#">
				<cfparam name="attributes.return" type="string" default="">
				<cfparam name="attributes.datasource" type="string" default="primary">
				<cfparam name="attributes.dbtable" type="string" default="">
				<cfparam name="attributes.skin" type="string" default="ontap">
				<cfparam name="attributes.locale" type="string" default="#getTap().getLocal().language#">
				<cfparam name="attributes.file" type="string" default="">
				<cfparam name="attributes.url" type="string" default="">
				<cfparam name="attributes.parent" type="struct" default="#structnew()#">
				<cfparam name="attributes.position" type="numeric" default="0">
				<cfparam name="attributes.brand" type="string" default="#getTap().getPath().brand#">
				<cfset htman = getTap().getHTML() />
				<cfset htman.stack.push() />
				<cfset ns = htman.ns />
				<cfset ns.dbtable = attributes.dbtable />
				<cfset ns.datasource = attributes.datasource />
				<cfset ns.formdata = attributes.formdata />
				
				<cfif len(trim(attributes.file)) and len(trim(attributes.url))>
					<cfthrow type="ontap.tag.html.content" message="onTap: Mutually Exclusive Attributes" 
					detail="The XHTML tag accepts a FILE attribute or a URL attribute. Please choose one or the other.">
				</cfif>
				
				<cfset variables.cachename = "" />
				<!--- check for existing and relevant cached content if caching is specified in the attributes --->
				<cfif len(trim(attributes.cachename))>
					<cfset variables.cachename = REREplaceNoCase(attributes.cachename,
						"^((cluster|server|application|session)\.)?(.*)$",
						"\1tap_html.\3.#attributes.brand#.#attributes.locale#") />
					
					<cfset agent = getIoC().getBean("cachemanager") />
					
					<!--- if we're not returning the structure, try to cache after the display --->
					<cfif not len(trim(attributes.return)) and not len(trim(getLib().html.id(attributes.parent)))>
						<cfset cache = agent.fetch(variables.cachename & ".display",attributes.cachedafter) />
						<cfif not cache.status>
							<!--- we got the cache, so we can display it -- roll back the html stack first --->
							<cfset htman.stack.pop() />
							<!--- we're inside a cfsilent at this point, so we throw control to the bottom of the tag --->
							<cfthrow type="cache.content" message="#cache.content#" />
						</cfif>
					</cfif>
					
					<!--- either we don't have display cache or we're returning the structure, so lets get the structure cache --->
					<cfset cache = agent.fetch(variables.cachename,attributes.cachedafter) />
					
					<cfif not cache.status>
						<!--- the cached content is still relevant, return it to the calling tag and exit the template --->
						<cfset html = duplicate(cache.content) />
						
						<!--- set pointers to elements in the htmanager object --->
						<cfset getLib().html.xmlparsecachedelements(html.taphtmlroot) />
						
						<!--- create quickcache variables as pointers to the request elements --->
						<cfset html.quickcache = getLib().arg(html,"quickcache",structnew()) />
						<cfloop item="x" collection="#html.quickcache#">
							<cfset setVariable(x,getTap().getHTML().getElement(html.quickcache[x])) />
						</cfloop>
						
						<cfif isstruct(attributes.formdata)>
							<!--- set any form fields in the returned html --->
							<cfset getLib().html.formElementsSet(html.taphtmlroot,attributes.formdata) />
						</cfif>
						
						<!--- return the content --->
						<cfset html = getLib().html.ref(html.taphtmlroot) />
						<cfset returnHTMLContent() />
						<cfset variables.complete = true />
					</cfif>
				</cfif>
			</cfsilent>
		</cfif>
		
		<cfparam name="variables.complete" type="boolean" default="false">
		<cfif not variables.complete>
			<cfif thistag.executionmode is "end" or not thistag.hasendtag>
				<cfsilent>
					<cfset variables.xml = thistag.generatedcontent>
					
					<cfif len(trim(attributes.file))>
						<cfif FileExists(attributes.file)>
							<cfset fileText = getFS().fileRead("",attributes.file)>
							<cfif len(fileText)><cfset variables.xml = fileText></cfif>
						</cfif>
					<cfelseif len(trim(attributes.url))>
						<cfhttp method="get" url="#attributes.url#" redirect="true"></cfhttp>
						<cfif val(cfhttp.statuscode) eq 200 and len(trim(cfhttp.fileContent))>
							<cfset variables.xml = cfhttp.FileContent>
						</cfif>
					</cfif>
				</cfsilent>
				
				<cfparam name="variables.xml" type="string" default="">
				<cfif len(trim(variables.xml))>
					<cfsilent>
						<cfset variables.tap.html.quickcache = structnew()>
						<cfset variables.tap.html.taphtmlroot = getLib().html.xmlparse(variables.xml,attributes.scope,"",attributes.skin)>
						
						<!--- if caching is specified in the attributes, store the content in the specified variable --->
						<cfif len(trim(attributes.cachename))>
							<cfset agent = getIoC().getBean("cachemanager") />
							<cfset agent.store(variables.cachename,duplicate(variables.tap.html),attributes.cachedwithin,attributes.datepart) />
						</cfif>
					</cfsilent>
					
					<cfset html = variables.tap.html.taphtmlroot>
					<cfset returnHTMLContent()>
				<cfelseif len(trim(attributes.cachename))>
					<!--- remove content from the cache --->
					<cfset getIoC().getBean("cachemanager").expire(variables.cachename & "%")>
				<cfelse>
					<cfthrow type="ontap.tag.html.content" message="onTap: XHTML Content Not Provided" 
					detail="Unable to locate xml content for the XHTML tag. Use the FILE or URL attribute or an end-tag.">
				</cfif>
			</cfif>
		</cfif>
		
		<cfif thistag.executionmode is "end" or not thistag.hasendtag>
			<!--- clean up HTML namespace variables --->
			<cfset htman.stack.pop() />
		</cfif>
		
		<!--- disable cfoutputonly for the duration of the body of this tag 
		-- this prevents you from needing extra <cfoutput> tags around a <cf_html> tag pair --->
		<cfswitch expression="#thistag.executionmode#">
			<cfcase value="start">
				<cfif thistag.hasendtag><cf_outputonly enable="false" return="outonly" /></cfif>
			</cfcase>
			<cfdefaultcase>
				<cfparam name="outonly" default="0" />
				<cfif outonly><cf_outputonly enable="true" repeat="#outonly#" /></cfif>
				<cfset thistag.generatedcontent = "" />
			</cfdefaultcase>
		</cfswitch>
		
		<cfcatch type="cache.content">
			<!--- we got cached content after display and threw it down here to get it out of the cfsilent tags --->
			<cfoutput>#cfcatch.message#</cfoutput>
			
			<!--- we're in the start tag, so we want to make sure the body and end-tag don't execute --->
			<cfexit method="exittag" />
		</cfcatch>
		<cfcatch>
			<!--- 
				if we failed in the middle of some XHTML, we want to clean it up 
				so that the malformed XHTML doesn't interfere with the debug error message 
				then we rethrow to see the error 
			 --->
			<cfset thistag.generatedcontent = "" />
			<cfrethrow />
		</cfcatch>
	</cftry>
</cfif>

