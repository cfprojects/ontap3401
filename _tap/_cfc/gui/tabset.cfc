<cfcomponent displayname="GUI.Tabset" output="false" extends="html">	
	<cfset stStyle = structNew()>
	<cfset stStyle.print = arrayNew(1)>
	<cfset stStyle.screen = arrayNew(1)>
	<cfset stStyle.all = arrayNew(1)>
	
	<cffunction name="init" access="public" output="false">
		<cfset initTabsetEvents()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="initTabsetEvents" access="private" output="false">
		<cfset var temp = "" />
		<cfset var xml = "" />
		<cfset var x = 0 />
		
		<cffile action="read" file="#rereplacenocase(getCurrentTemplatePath(),'\.cfc$','.xml')#" variable="temp" />
		<cfset xml = xmlParse(temp).root />
		
		<cfset rev = xml.rev.xmlAttributes>
		<cfset size = xml.size.xmlAttributes>
		<cfset sizealt = xml.size.alt.xmlAttributes>
		<cfset align = structNew()>
		<cfloop item="x" collection="#xml.align#">
			<cfset align[x] = xml.align[x].xmlAttributes>
		</cfloop>
		
		<cfset eventTabSelect = xml.event.tabselect.xmlText>
		<cfset eventTabsetIndex = xml.event.tabsetindex.xmlText>
		<cfset eventTabFetch = xml.event.tabfetch.xmlText>
		<cfset eventTabLoad = xml.event.tabload.xmlText>
		<cfset eventLoadAll = xml.event.tabsetloadall.xmlText>
		<cfset eventGateSend = xml.event.gatesend.xmlText>
		<cfset eventGateRespond = xml.event.gaterespond.xmlText>
		<cfset eventGateError = xml.event.gateError.xmlText>
		<cfset eventGateTimeout = xml.event.gateTimeout.xmlText>	
	</cffunction>
	
	<cffunction name="getLayout" access="private" output="false" returntype="string">
		<cfargument name="tabset" type="struct" required="true">
		<cfreturn htlib.tabsetLayout(tabset,"")>
	</cffunction>
	
	<cffunction name="getAlign" access="private" output="false" returntype="string">
		<cfargument name="tabset" type="struct" required="true">
		<cfargument name="layout" type="string" required="true">
		<cfreturn variables.align[layout][htlib.tabsetAlign(tabset,"")]>
	</cffunction>
	
	<cffunction name="getRowSize" access="private" output="false" returntype="numeric">
		<cfargument name="tabset" type="struct" required="true">
		<cfreturn htlib.tabsetsize(tabset,"")>
	</cffunction>
	
	<cffunction name="isPrintable" access="private" output="false" returntype="boolean">
		<cfargument name="tabset" type="struct" required="true">
		<cfreturn htlib.tabsetPrint(tabset,"")>
	</cffunction>
	
	<cffunction name="isScrollable" access="private" output="false" returntype="boolean">
		<cfargument name="tabset" type="struct" required="true">
		<cfreturn htlib.tabsetScroll(tabset,"")>
	</cffunction>
	
	<cffunction name="requestIsScriptable" access="private" output="false" returntype="boolean">
		<cfreturn getTap().getPage().script>
	</cffunction>
	
	<cffunction name="newRow" access="private" output="false" returntype="struct">
		<cfargument name="id" type="string" required="true">
		<cfargument name="class" type="string" required="true">
		<cfargument name="row" type="numeric" required="true">
		<cfset var html = htlib.new("div",class,id & "_row_" & row)>
		<cfif row eq 1>
			<cfset htlib.event(html,"open",'<div class="tabsetfirstrow">',0,"server")>
		<cfelse>
			<cfset htlib.event(html,"open",'<div class="tabsetrelative">',0,"server")>
		</cfif>
		<cfset htlib.event(html,"close","</div>",0,"server")>
		<cfreturn html>
	</cffunction>
	
	<cffunction name="setRows" access="private" output="false">
		<cfargument name="tabset" type="struct" required="true">
		<cfset var id = htlib.id(tabset)>
		<cfset var layout = getLayout(tabset)>
		<cfset var class = tabset.tabset.class & "_tabset" & layout & "row">
		<cfset var measure = size[layout]>
		<cfset var my = structNew()>
		<cfset var rows = ArrayNew(1)>
		<cfset var numrows = htlib.children(tabset)>
		<cfset var child = "">
		<cfset var x = 0>
		<cfset var y = 0>
		<cfset var i = 0>
		<cfset my.width = val(tabset.tabset.width)>
		<cfset my.height = val(tabset.tabset.height)>
		<cfset my.rowsize = getRowSize(tabset)>
		
		<cfloop index="i" from="1" to="#numrows#">
			<cfset child = htlib.childGet(tabset,i)>
			<cfif structKeyExists(child,"tab")>
				<cfset x = val(child.tab.position)>
				<cfset y = val(child.tab.row)>
				<cfif y lt 1 or y gt arraylen(rows)>
					<cfset y = arraylen(rows) + 1>
					<cfset arrayAppend(rows,newRow(id,class,y))>
				</cfif>
				<cfset htlib.childAdd(rows[y],child,child.tab.position)>
				<cfset my.children = htlib.children(rows[y])>
				<cfif child.tab.position lt 1 or child.tab.position gt my.children>
					<cfset child.tab.position = my.children>
				</cfif><cfset child.tab.row = y>
			</cfif>
		</cfloop>
		
		<cfset numrows = arraylen(rows)>
		<cfloop index="i" from="#numrows#" to="1" step="-1">
			<cfset htlib.attribute(rows[i],"z",1+numrows-i)>
			<cfset setRowPlaceholders(tabset,rows[i])>
		</cfloop>
		
		<cfset tabset.children = rows>
	</cffunction>
	
	<cffunction name="getTabURL" access="private" output="false" returntype="string">
		<cfargument name="tabset" type="struct" required="true">
		<cfargument name="tab" type="struct" required="true">
		<cfargument name="link" type="struct" required="true">
		<cfset var href = htlib.attributeGet(link,"href","")>
		<cfif not len(href) and len(trim(tabset.tabset.href))>
			<cfset href = getLib().getURL(tabset.tabset.href,tabset.tabset.domain)>
		</cfif>
		<cfif len(href)>
			<cfset href = getLib().getURL("&" & tabset.tabset.name & "=" & htlib.id(tab),href)>
		</cfif>
		<cfreturn href>
	</cffunction>
	
	<cffunction name="getGateway" access="private" output="false">
		<cfargument name="tabset" type="struct" required="true">
		<cfset var gate = 0>
		<cfset var id = "">
		<cfif len(tabset.tabset.gateway)>
			<cfset gate = htlib.ref(tabset.tabset.gateway)>
		<cfelse>
			<cfset id = htlib.id(tabset) & "_gateway">
			<cf_html return="gate" parent="#tabset#">
				<cfoutput>
					<tap:gateway id="#id#" href="#tabset.tabset.href#" domain="#tabset.tabset.domain#" xmlns:tap="xml.tapogee.com">
						<tap:event name="gatesend"><![CDATA[ #variables.eventGateSend# ]]></tap:event>
						<tap:event name="gaterespond"><![CDATA[ #variables.eventGateRespond# ]]></tap:event>
						<tap:event name="gateerror"><![CDATA[ #variables.eventGateError# ]]></tap:event>
						<tap:event name="gatetimeout"><![CDATA[ #variables.eventGateTimeout# ]]></tap:event>
					</tap:gateway>
				</cfoutput>
			</cf_html>
			<cfset htlib.event(tabset,"tabfetch",variables.eventTabFetch,0,"server")>
			<cfset htlib.event(tabset,"tabselect","eval(element.id + '_tabfetch(tab.id)');",0,"server")>
			<cfset htlib.event(tabset,"tabload",variables.eventTabLoad,0,"server")>
			<cfset htlib.event(tabset,"tabsetloadall",variables.eventLoadAll,0,"server")>
			<cfset tabset.tabset.gateway = id>
		</cfif>
		<cfreturn gate>
	</cffunction>
	
	<cffunction name="setGateway" access="private" output="false">
		<cfargument name="tabset" type="struct" required="true">
		<cfargument name="tab" type="struct" required="true">
		<cfargument name="link" type="struct" required="true">
		<cfset var href = getTabURL(tabset,tab,link)>
		<cfset var script = requestIsScriptable() />
		<cfset var usegate = script and yesnoformat(tabset.tabset.usegate) />
		<cfset usegate = iif(usegate,'htlib.tabGateway(tab,"")',false)>
		
		<cfif len(href)><cfset htlib.attribute(link,"href",href)></cfif>
		
		<cfif not isBoolean(usegate)>
			<cfset usegate = iif(not tab.tab.hascontent and len(href),true,false)>
		</cfif>
		
		<cfif usegate>
			<cfset getGateway(tabset)>
			<cfset htlib.attribute(link,"tap_gate",1)>
			<cfset htlib.event(link,"onclick","return false;",0,"client")>
		<cfelseif tab.tab.hascontent>
			<cfset htlib.event(link,"onclick","return false;",0,"client")>
		</cfif>
	</cffunction>
	
	<cffunction name="TabHeader" access="private" output="false" returntype="struct">
		<cfargument name="tabset" type="struct" required="true">
		<cfargument name="tab" type="struct" required="true">
		<cfargument name="class" type="string" required="true">
		<cfset var tabsetid = htlib.id(tabset)>
		<cfset var tabid = htlib.id(tab)>
		<cfset var settab = "#tabsetid#_tabselect('#tabid#');">
		<cfset var header = htlib.new("h4",class & "_tabheader",htlib.id(tab) & "_header")>
		<cfset var link = htlib.childGet(tab,1)>
		<cfset var layout = getLayout(tabset)>
		<cfset var event = "">
		<cfset var x = 0>
		<cfset var e = 0>
		
		<cfset settab = "if (#tabsetid#_tabsetindex() != '#tabid#') { #settab# }">
		
		<cfset htlib.style(header,layout,"0px")>
		<cfset htlib.style(link,"border-" & rev[layout],"0px")>
		<cfset htlib.style(header,sizeAlt[layout],tabset.tabset.width & "px")>
		<cfloop index="e" list="onclick,onmouseover,onmouseout,onmouseup,onmousedown">
			<cfset event = htlib.eventGet(tab,e)>
			<cfif arrayLen(event)>
				<cfloop index="x" from="1" to="#ArrayLen(event)#">
					<cfset htlib.event(link,e,event[x],0,"client")>
				</cfloop><cfset htlib.eventRemove(tab,e)>
			</cfif>
		</cfloop>
		
		<cfset event = htlib.eventGet(tab,"onload")>
		<cfif arraylen(event)>
			<cfset ArrayPrepend(event,"element = document.getElementById(element.id + '_content');")> 
			<cfset htlib.customEvent(tab,"load",ArrayToList(event,chr(13) & chr(10)))>
			<cfset htlib.eventRemove(tab,"onload")>
		</cfif>
		
		<cfset setGateway(tabset,tab,link)>
		<cfset htlib.tabIndex(link)>
		<cfset htlib.event(link,"onclick",settab,1)>
		<cfset htlib.event(link,"onfocus",settab,1)>
		<cfset htlib.attribute(link,"class","tablabel")>
		<cfset htlib.childAdd(header,link)>
		<cfset htlib.childSet(tab,1,header)>
		<cfreturn header>
	</cffunction>
	
	<cffunction name="setRowPlaceholders" access="private" output="false">
		<cfargument name="tabset" type="struct" required="true">
		<cfargument name="row" type="struct" required="true">
		<cfset var class = htlib.attributeGet(tabset,"class")>
		<cfset var layout = htlib.tabsetLayout(tabset,"")>
		<cfset var numtabs = htlib.children(row)>
		<cfset var header = ArrayNew(1)>
		<cfset var ph = ArrayNew(1)>
		<cfset var ev = "">
		<cfset var link = "">
		<cfset var tab = "">
		<cfset var child = "">
		<cfset var i = 0>
		<cfset var x = 0>
		
		<cfif numtabs gt 1>
			<cfloop index="i" from="1" to="#numtabs#">
				<cfset arrayAppend(ph,htlib.show(htlib.clone(htlib.childGet(htlib.childGet(row,i),1))))>
			</cfloop>
		</cfif>
		
		<cfloop index="i" from="1" to="#numtabs#">
			<cfset tab = htlib.childGet(row,i)>
			<cfset x = 1+(numtabs-i)>
			<cfset htlib.attribute(tab,"z",x)>
			<cfset htlib.style(tab,"z-index",x)>
			<cfset header = TabHeader(tabset,tab,class)>
			<cfset ev = "open">
			<cfloop index="x" from="1" to="#numtabs#">
				<cfif x eq i>
					<cfset ev = "close">
				<cfelse>
					<cfset htlib.event(header,ev,ph[x],0,"server")>
				</cfif>
			</cfloop>
		</cfloop>
	</cffunction>
	
	<cffunction name="setContentDivs" access="private" output="false">
		<cfargument name="tabset" type="struct" required="true">
		<cfset var class = tabset.tabset.class>
		<cfset var layout = getLayout(tabset)>
		<cfset var defaulttab = tabset.tabset.defaulttab>
		<cfset var id = htlib.id(tabset)>
		<cfset var tabid = "">
		<cfset var link = "">
		<cfset var content = "">
		<cfset var child = "">
		<cfset var i = 0>
		
		<cfloop index="i" from="1" to="#htlib.children(tabset)#">
			<cfset child = htlib.childGet(tabset,i)>
			<cfset tabid = htlib.id(child)>
			
			<cfif isSimpleValue(defaulttab) and htlib.id(child) is defaulttab>
				<cfset defaulttab = child>
				<cfset htlib.event(child,"open",'<div class="tabselected">',1,"server")>
			<cfelse>
				<cfset htlib.event(child,"open",'<div class="tabsetrelative">',1,"server")>
			</cfif>
			<cfset htlib.event(child,"close","</div>",0,"server")>
			
			<cfset link = htlib.childGet(child,1)>
			<cfset htlib.attribute(child,"class",class & "_tabsettab")>
			<cfset content = htlib.new("div",class & "_tabcontent",tabid & "_content")>
			<cfset htlib.tabFocus(content,"if (#id#_tabsetindex() != '#tabid#') { #id#_tabselect('#tabid#',false); }")>
			<cfset htlib.addChildContainers(child,content,false)>
			<cfset htlib.childAdd(child,htlib.childGet(content,1),1)>
			<cfset htlib.childRemove(content,1)>
			<cfset child.tab.hascontent = true>
			<cfif not htlib.children(content)>
				<cfset child.tab.hascontent = false>
				<cfset htlib.childAdd(content,"")>
			</cfif>
		</cfloop>
		
		<cfreturn defaulttab>
	</cffunction>
	
	<cffunction name="setSelectedTab" access="private" output="false">
		<cfargument name="tabset" type="struct" required="true">
		<cfargument name="defaulttab" type="any" required="true">
		<cfset var swap = structNew()>
		<cfset var row = 0>
		
		<cfif not isStruct(defaulttab)>
			<cfset defaulttab = htlib.childGet(htlib.childGet(tabset,1),1)>
			<cfset htlib.eventRemove(defaulttab,"open",1,"server")>
			<cfset htlib.event(defaulttab,"open",'<div class="tabselected">',1,"server")>
		</cfif>
		
		<cfif defaulttab.tab.row gt 1>
			<cfset swap.firstrow = htlib.childGet(tabset,1)>
			<cfset swap.tabrow = htlib.childGet(tabset,defaulttab.tab.row)>
			<cfset swap.z = htlib.attributeGet(swap.tabrow,"z")>
			<cfset htlib.attribute(swap.tabrow,"z",htlib.attributeGet(swap.firstrow,"z"))>
			<cfset htlib.attribute(swap.firstrow,"z",swap.z)>
		</cfif>
		
		<cfif defaulttab.tab.position gt 1>
			<cfset swap.tabrow = htlib.childGet(tabset,defaulttab.tab.row)>
			<cfset swap.firsttab = htlib.childGet(swap.tabrow,1)>
			<cfset swap.z = htlib.attributeGet(swap.firsttab,"z")>
			<cfset htlib.attribute(swap.firsttab,"z",htlib.attributeGet(defaulttab,"z"))>
			<cfset htlib.attribute(defaulttab,"z",swap.z)>
			<cfset htlib.style(swap.firsttab,"z-index",htlib.attributeGet(swap.firsttab,"z"))>
			<cfset htlib.style(defaulttab,"z-index",htlib.attributeGet(defaulttab,"z"))>
		</cfif>
		
		<cfset htlib.attribute(tabset,"selectedtab",htlib.id(defaulttab))>
	</cffunction>
	
	<cffunction name="addStyle" access="private" output="false">
		<cfargument name="tabset" type="struct" required="true">
		<cfargument name="media" type="string" required="true">
		<cfargument name="style" type="string" required="true">
		<cfset ArrayAppend(tabset.tabset.style[arguments.media],
			chr(35) & getLib().html.id(tabset) & " " & arguments.style)>
	</cffunction>
	
	<cffunction name="CascadeRows" access="private" output="false">
		<cfargument name="tabset" type="struct" required="true">
		<cfset var layout = getLayout(tabset)>
		<cfset var align = getAlign(tabset,layout)>
		<cfset var rowsize = getRowSize(tabset)>
		<cfset var class = tabset.tabset.class>
		<cfset var measure = size[layout]>
		<cfset var numrows = htlib.children(tabset)>
		<cfset var altmeasure = sizealt[layout] & ": " & tabset.tabset[sizealt[layout]] & "px;">
		<cfset var print = isPrintable(tabset)>
		<cfset var style = iif(print,de("screen"),de("all"))>
		<cfset var offset = rowsize * numrows>
		<cfset var size = tabset.tabset[measure] - (offset+numrows)>
		<cfset var temp = "">
		<cfset var row = 0>
		<cfset var i = 0>
		<cfset var z = 0>
		
		<cfset addStyle(tabset,style,".#class#_tabset#layout#row { #measure#: #size#px; #altmeasure# }")>
		<cfset addStyle(tabset,style,".#class#_tabheader { #altmeasure# #align#: 0px; }")>
		<cfset addStyle(tabset,style,".#class#_tabheader a, .#class#_tabheader a:hover { margin-#rev[layout]#: 2px; margin-#layout#: -#rowsize#px; }")>
		
		<cfif measure is "height">
			<cfset addStyle(tabset,style,".#class#_tabheader a, .#class#_tabheader a:hover { vertical-align: #rev[layout]#; float: #align#; }")>
		<cfelse>
			<cfset addStyle(tabset,style,".#class#_tabheader { float: none; vertical-align: #align#; }")>
		</cfif>
		
		<cfset temp = "#measure#: #size-5#px; #altmeasure#: #tabset.tabset[sizealt[layout]]-5#px;">
		<cfif isScrollable(tabset)>
			<cfset addStyle(tabset,style,".#class#_tabcontent { overflow: auto; #temp# }")>
		<cfelse>
			<cfset addStyle(tabset,"all",".#class#_tabcontent { overflow: hidden; #temp# }")>
		</cfif>
		
		<cfset rowsize = rowsize + 1>
		<cfloop index="i" from="1" to="#numrows#">
			<cfset row = htlib.childGet(tabset,i)>
			<cfset z = htlib.attributeGet(row,"z")>
			<cfset htlib.style(row,"z-index",z)>
			<cfset htlib.style(row,layout,rowsize * z & "px")>
		</cfloop>
	</cffunction>
	
	<cffunction name="prepareStyle" access="private" output="false">
		<cfargument name="tabs" type="struct" required="true">
		<cfset var media = 0>
		<cfset var temp = "">
		<cfloop index="media" list="all,screen,print">
			<cfif ArrayLen(tabs.tabset.style[media])>
				<cfset temp = htlib.cssNew(replace(media,"all",""))>
				<cfset temp.children = tabs.tabset.style[media]>
				<cfset htlib.event(tabs,"pre",temp,0,"server")>
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="prepareEvents" access="private" output="false">
		<cfargument name="tabs" type="struct" required="true" />
		<cfset var class = htlib.attributeGet(tabs,"class") />
		<cfset var my = structNew() />
		<cfset var event = "" />
		<cfset var x = 0 />
		
		<cfset event = htlib.eventGet(tabs,"onchange")>
		<cfloop index="x" from="1" to="#ArrayLen(event)#">
			<cfset htlib.event(tabs,"tabselect",event[x],0,"server")>
		</cfloop>
		<cfset htlib.eventRemove(tabs,"onchange")>
		
		<cfset event = htlib.eventGet(tabs,"onload")>
		<cfloop index="x" from="1" to="#ArrayLen(event)#">
			<cfset htlib.event(tabs,"tabload",event[x],0,"server")>
		</cfloop>
		<cfset htlib.eventRemove(tabs,"onload")>
		
		<cfset htlib.event(tabs,"tabselect",variables.eventTabSelect,1,"server")>
		<cfset htlib.event(tabs,"tabselect","element.setAttribute('lock',0); return true;",0,"server")>
		<cfset htlib.event(tabs,"tabsetindex",variables.eventTabsetIndex,1,"server")>
		<cfset htlib.event(tabs,"tabsetindex","return selectedTab;",0,"server")>
		
		<cfloop item="event" collection="#tabs.events.server#">
			<cfif left(event,3) is "tab"><cfset htlib.customevent(tabs,event)></cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="preDisplay" access="public" output="false" returntype="string">
		<cfargument name="tabs" type="struct" required="true">
		<cfset var class = htlib.attributeGet(tabs,"class","")>
		<cfset var my = structNew()>
		<cfset var x = 0>
		
		<cfset tabs.tabset.width = val(tabs.tabset.width)>
		<cfset tabs.tabset.height = val(tabs.tabset.height)>
		<cfset my.print = isPrintable(tabs)>
		
		<cfset tabs.tabset.class = iif(len(class),"class",de("tabset"))>
		<cfset class = tabs.tabset.class>
		<cfset my.defaulttab = setContentDivs(tabs)>
		<cfset tabs.tabset.style = duplicate(variables.stStyle)>
		
		<cfset htlib.style(tabs,"width",tabs.tabset.width & "px")>
		<cfset htlib.style(tabs,"height",tabs.tabset.height & "px")>
		
		<cfset setRows(tabs)>
		<cfset setSelectedTab(tabs,my.defaulttab)>
		<cfset CascadeRows(tabs)>
		<cfset prepareEvents(tabs)>
		<cfset prepareStyle(tabs)>

		<cfset htlib.attribute(tabs,"rowattach",rev[getLayout(tabs)])>
		<cfset htlib.attribute(tabs,"rowsize",getRowSize(tabs))>
		<cfset htlib.attribute(tabs,"rowcount",htlib.children(tabs))>
		<cfset htlib.attribute(tabs,"lock",0)>
		
		<cfif len(tabs.tabset.gateway)>
			<cfset htlib.childAdd(tabs,htlib.ref(tabs.tabset.gateway))>
		</cfif>
		
		<cfset htlib.attribute(tabs,"class",tabs.tabset.class & "_tabset" & iif(my.print,de("printall"),de("container")))>
	</cffunction>
	
</cfcomponent>
