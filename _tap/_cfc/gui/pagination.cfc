<cfcomponent displayname="GUI.Pagination" output="false" extends="html">
	
	<cffunction name="init" access="public" output="false">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="display" access="public" output="false" returntype="string">
		<cfargument name="pagelink" type="struct" required="true" />
		<cfset var my = structNew() />
		<cfset var page = pagelink.page />
		<cfset var st = structNew() />
		<cfset var href = htlib.attributeGet(pagelink,"href") />
		<cfset var currentpage = 0 />
		<cfset var script = htlib.eventsShow(pagelink,"client") />
		<cfset var open = trim(htlib.eventsShow(pagelink,"server","open")) />
		<cfset var close = trim(htlib.eventsShow(pagelink,"server","close")) />
		<cfset var prechild = trim(htlib.eventsShow(pagelink,"server","prechild")) />
		<cfset var postchild = trim(htlib.eventsShow(pagelink,"server","postchild")) />
		<cfset var childdelimiter = trim(htlib.eventsShow(pagelink,"server","childdelimiter")) />
		<cfset var classname = "" />
		<cfset var x = 0 />
		
		<cfif not val(page.size)><cfset page.size = page.rows /></cfif>
		<cfset page.startrow = max(1,((page.page - 1) * page.size) + 1) />
		<cfset page.endrow = min(page.rows, page.startrow + page.size - 1) />
		<cfset structAppend(page.xslparameters,readResourceBundle(page.type),true) />
		<cfset page.numpages = iif(page.size eq 0,1,"max(1,ceiling(page.rows/page.size))") />
		
		<cfxml variable="my.xml">
			<cfoutput>
				<pagelist id="#htlib.id(pagelink)#" 
				page="#page.page#" rows="#page.rows#" variable="#page.pagevariable#" 
				startrow="#page.startrow#" endrow="#page.endrow#" pagesize="#page.size#">
					<events><cfloop item="x" collection="#pagelink.events.client#"><#lcase(removechars(x,1,2))# /></cfloop></events>
					
					<rows><![CDATA[ #getNumber(page.rows)# ]]></rows>
					<startrow><![CDATA[ #getNumber(page.startrow)# ]]></startrow>
					<endrow><![CDATA[ #getNumber(page.endrow)# ]]></endrow>
					
					<open>#htmleditformat(open)#</open>
					<close>#htmleditformat(close)#</close>
					<prechild>#htmleditformat(prechild)#</prechild>
					<postchild>#htmleditformat(postchild)#</postchild>
					<childdelimiter>#htmleditformat(childdelimiter)#</childdelimiter>
					
					<cfset classname = "previous page" />
					<cfloop index="x" from="1" to="#page.rows#" step="#max(1,page.size)#">
						<cfset currentpage = currentpage + 1 />
						<cfif currentpage is page.page>
							<cfset classname = "current page" />
						</cfif>
						<page index="#currentpage#" class="#classname#" href="#htmleditformat(href)#">#getNumber(currentpage)#</page>
						<cfif currentpage is page.page>
							<cfset classname = "next page" />
						</cfif>
					</cfloop>
					
					<cfif len(trim(page.options)) and len(trim(page.optionvariable)) and len(trim(page.href))>
						<options href="#htmleditformat(page.href)#" variable="#page.optionvariable#" 
							src="#htmleditformat(getImage('page/#page.type#/#page.src#'))#" 
							hover="#htmleditformat(getImage('page/#page.type#/#page.hover#'))#">
							<cfloop index="x" list="#page.options#">
								<opt value="#x#">#getNumber(x)#</opt>
							</cfloop>
						</options>
					</cfif>
				</pagelist>
			</cfoutput>
		</cfxml>
		
		<cfreturn XmlTransform(my.xml,getStylesheet(page.type),page.xslparameters) />
	</cffunction>
	
	<cffunction name="readResourceBundle" access="private" output="false" returntype="struct">
		<cfargument name="type" type="string" required="true">
		<cfset var rb = CreateObject("component","cfc.file").init("page/#type#/l10n","skin","resourcebundle")>
		<cfreturn rb.read()>
	</cffunction>
	
	<cffunction name="getNumber" access="private" output="false" returntype="string">
		<cfargument name="number" type="string" default="">
		<cfreturn getLib().lsNumber(number)>
	</cffunction>
	
	<cffunction name="getStylesheet" access="private" output="false" returntype="string">
		<cfargument name="type" type="string" required="true">
		<cfreturn getFS().getPath("page/#type#.xsl","skin")>
	</cffunction>
	
	<cffunction name="getImage" access="private" output="false" returntype="string">
		<cfargument name="src" type="string" required="true">
		<cfreturn getLib().getIMG(arguments.src)>
	</cffunction>
</cfcomponent>
