<cfcomponent displayname="doc" extends="ontap" 
hint="analyses CFCs and returns documentation for them">
	<cffunction name="init" output="false" hint="initializes the CFC with required properties">
		<cfargument name="component" required="true" hint="an instantiated component object from which documentation should be gathered">
		
		<cfset variables.component = arguments.component>
		<cfset variables.metadata = duplicate(getMetaData(variables.component))>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getURL" access="private" output="false" returntype="string">
		<cfargument name="href" type="string" required="true">
		<cfargument name="domain" type="string" required="false" default="R">
		<cfreturn getLib().getURL(href,domain)>
	</cffunction>
		
	<cffunction name="getMetaFunctionsDefaults" access="private" output="false" returntype="void" 
	hint="appends default values to the meta data of a function">
		<cfargument name="myobj" type="struct" required="true" hint="the function metadata to append defaults">
		<cfparam name="myobj.returntype" type="string" default="">
		<cfparam name="myobj.output" type="boolean" default="true">
		<cfparam name="myobj.access" type="string" default="public">
		<cfparam name="myobj.hint" type="string" default="">
		<cfparam name="myobj.example" type="string" default="">
		<cfparam name="myobj.roles" type="string" default="">
	</cffunction>
	
	<cffunction name="getMetaPropertiesDefaults" access="private" output="false" returntype="void" 
	hint="appends default values to the meta data of a cfc property">
		<cfargument name="myobj" type="struct" required="true" hint="the property metadata to append defaults">
		<cfparam name="myobj.required" type="boolean" default="false">
		<cfparam name="myobj.type" type="string" default="Any">
		<cfparam name="myobj.default" default="n/a">
		<cfparam name="myobj.hint" default="">
	</cffunction>
	
	<cffunction name="docGetExtends" access="public" output="false" returntype="array">
		<cfargument name="parentlist" type="string" required="false" default="">
		<cfargument name="obj" required="false">
		<cfset var ext = arrayNew(1)>
		<cfset var parent = 0>
		<cfset var child = 0>
		<cfset var x = 0>
		
		<cfif isDefined("arguments.obj")>
			<cfset obj.docGetExtends = this.docGetExtends>
			<cfreturn obj.docGetExtends(parentlist)>
		<cfelse>
			<cfset parent = getMetaData(this)>
			<cfif listFindNoCase(parentlist,parent.name,";")><cfreturn ext><cfelse>
				<cfset arrayAppend(ext,duplicate(parent))>
				<cfset parentlist = listappend(parentlist,parent.name,";")>
			</cfif>
			
			<cfif structkeyexists(parent,"extends") and listFirst(parent.extends.name,".") is not "WEB-INF">
				<cfset child = this.docGetExtends(parentlist,createObject("component",parent.extends.name))>
				<cfloop index="x" from="1" to="#arrayLen(child)#">
				<cfset arrayAppend(ext,child[x])></cfloop>
			</cfif>
			
			<cfparam name="variables.extends" type="array" default="#arrayNew(1)#">
			<cfloop index="x" from="1" to="#arrayLen(variables.extends)#">
				<cfset arrayAppend(ext,duplicate(getMetaData(variables.extends[x])))>
			</cfloop>
			
			<cfset structDelete(this,"docGetExtends")>
			<cfreturn ext>
		</cfif>
	</cffunction>
	
	<cffunction name="getMetaExtends" access="private" returntype="array" output="false">
		<cfset var mydata = variables.metadata>
		<cfset var ancestor = this.docGetExtends("",component)>
		<cfset var ext = arrayNew(1)>
		<cfset var parent = mydata>
		<cfset var namelist = mydata.name>
		
		<!--- remove any invalid ancestors from the array, including the ColdFusion root component.cfc (it's valid but we don't want to see it here) --->
		<cfloop condition="arrayLen(ancestor)">
			<cfif not listFindNoCase(namelist,ancestor[1].name,";") 
			and listFirst(ancestor[1].name,".") is not "WEB-INF">
				<cfif findNocase("linked",ancestor[1].name)><div>linked = <cfdump var="#ancestor[1].name#"></div></cfif>
				<cfset nameList = listAppend(namelist,ancestor[1].name,";")>
				<cfset ancestor[1].displayname = getDisplayName(ancestor[1])>
				<cfset arrayAppend(ext,ancestor[1])>
			</cfif>
			<cfset arraydeleteat(ancestor,1)>
		</cfloop>
		
		<cfreturn ext>
	</cffunction>
	
	<cffunction name="getDisplayName" access="public" output="false">
		<cfargument name="metadata" type="struct" required="false" default="#variables.metadata#">
		<cfreturn getLib().arg(metadata,"displayname",metadata.name)>
	</cffunction>
	
	<cffunction name="getHint" access="public" output="false" returntype="string">
		<cfparam name="variables.metadata.hint" type="string" default="" />
		<cfreturn variables.metadata.hint />
	</cffunction>
	
	<cffunction name="getMetaLibrary" returntype="string" output="false" access="private">
		<cfargument name="metadata" type="struct" default="#variables.metadata#">
		<cfset var lib = "">
		
		<cfset lib = getdirectoryfrompath(metadata.path)>
		<cfset lib = replacenocase(lib,getFS().getPath("","CFC"),"")>
		<cfif not len(trim(rereplacenocase(lib,"[[:punct:]]","","ALL")))><cfset lib = "core"></cfif>
		
		<cfreturn lib>
	</cffunction>
	
	<cffunction name="getMetaStruct" returntype="struct" output="false" access="private" 
	hint="returns a structure containing all methods (including inherited) from the current component with keys matching method names">
		<cfargument name="metatype" type="string" required="true" hint="function|property = name of array to convert to structure with ancestor information">
		<cfargument name="myobject" type="struct" required="false" default="#variables.metadata#" hint="a CFC metadata structure to search">
		<cfargument name="getAncestors" type="boolean" required="false" default="true" hint="indicates if functions or properties should be retreived from ancestor components">
		<cfset var mymeta = structnew()>
		<cfset var objmeta = false>
		<cfset var extends = variables.getMetaExtends()>
		<cfset var x = 0>
		
		<cfif structkeyexists(myobject,metatype)>
			<cfset objmeta = myobject[metatype]>
			<cfloop index="x" from="1" to="#arraylen(objmeta)#">
				<cfset objmeta[x].cfcfile = myobject.path>
				<cfset objmeta[x].cfcpath = myobject.name>
				<cfset objmeta[x].cfcname = iif(structkeyexists(myobject,"displayname"),"myobject.displayname","listlast(myobject.name,'.')")>
				<cfset objmeta[x].cfclibrary = getMetaLibrary(myobject)>
				<cfinvoke method="getMeta#metatype#Defaults" myobj="#objmeta[x]#">
				<cfset mymeta[objmeta[x].name] = objmeta[x]>
			</cfloop>
		</cfif>
		
		<cfif getAncestors><cfloop index="x" from="1" to="#arraylen(extends)#">
			<cfset structappend(mymeta,getMetaStruct(metatype,extends[x],false),false)>
		</cfloop></cfif>
		
 		<cfreturn mymeta>
	</cffunction>
	
	<cffunction name="display" returntype="string" output="false" access="public" hint="returns documentation for the initialized object as a string of html or SPEC XML">
		<cfargument name="xml" type="boolean" required="false" default="false" 
		hint="toggles the returned string between html and SPEC formatted xml content">
		
		<cfset var mydocs = "">
		<cfset var mydata = variables.metadata>
		<cfset var methods = getMetaStruct("functions",variables.metadata)>
		<cfset var properties = getMetaStruct("properties",variables.metadata)>
		<cfset var mymethod = false>
		<cfset var property = false>
		<cfset var arglist = false>
		<cfset var arg = false>
		<cfset var authorxref = false>
		<cfset var ancestor = variables.getMetaExtends()>
		<cfset var libraries = false>
		<cfset var library = false>
		<cfset var x = false>
		<cfset var y = false>
		<cfset var z = false>
		<cfset var temp = "">
		<cfset var cfcpath = variables.metadata.path>
		<cfset var parent = "" />
		
		<cfset cfcpath = lcase(replacenocase(cfcpath,getFS().getPath("","D"),""))>
		<cfset cfcpath = rereplacenocase(listchangedelims(cfcpath,".","\/."),"\.cfc$","")>
		
		<cfparam name="mydata.hint" type="string" default="">
		<cfparam name="mydata.example" type="string" default="">
		<cfparam name="mydata.author" type="string" default="">
		<cfparam name="mydata.email" type="string" default="">
		<cfparam name="mydata.displayname" type="string" default="">
		
		<cfoutput><cfif xml>
			<cfset libraries = structnew()>
			<cfloop item="x" collection="#methods#">
				<cfset mymethod = methods[x]>
				<cfif mymethod.cfcname is mydata.displayname>
					<cfparam name="libraries.#mymethod.access#" type="struct" default="#structnew()#">
					<cfset libraries[mymethod.access][mymethod.name] = mymethod>
				</cfif>
			</cfloop>
			
			<cfsavecontent variable="mydocs">
				<spec>
					<class name="#htmleditformat(mydata.name)#" 
					<cfif structkeyexists(mydata.extends,"displayname")>
					extends="#htmleditformat(mydata.extends.name)#"</cfif>
					author="#htmleditformat(mydata.author)#" email="#htmleditformat(mydata.email)#">
						<usage>#htmleditformat(mydata.hint)#</usage>
						<cfif len(trim(mydata.example))>
						<example>#htmleditformat(mydata.example)#</example></cfif>
						
						<cfloop item="x" collection="#libraries#">
							<cfset library = libraries[x]>
							<library name="#htmleditformat(x)#">
								<cfloop index="y" list="#listsort(structkeylist(library),'textnocase')#">
									<cfset mymethod = library[y]>
									<cfset arglist = mymethod.parameters>
									<function name="#htmleditformat(mymethod.name)#" 
									return="#htmleditformat(mymethod.returntype)#"
									output="#yesnoformat(mymethod.output)#" 
									roles="#htmleditformat(mymethod.roles)#">
										<usage>#htmleditformat(mymethod.hint)#</usage>
										<cfif len(trim(mymethod.example))>
										<example>#htmleditformat(mymethod.example)#</example></cfif>
										<arguments>
											<cfloop index="z" from="1" to="#arraylen(arglist)#">
												<cfset arg = arglist[z]>
												<cfparam name="arg.type" type="string" default="Any">
												<cfparam name="arg.required" type="boolean" default="false">
												<cfparam name="arg.default" default="n/a">
												<cfparam name="arg.hint" type="string" default="">
												<arg name="#htmleditformat(arg.name)#" 
												required="#yesnoformat(arg.required)#" 
												type="#htmleditformat(lcase(arg.type))#" 
												default="#htmleditformat(arg.default)#">
												#htmleditformat(arg.hint)#</arg>
											</cfloop>
										</arguments>
									</function>
								</cfloop>
							</library>
						</cfloop>
						
						<variables>
							<cfloop index="x" list="#listsort(structkeylist(properties),'textnocase')#">
								<cfset property = properties[x]>
								<cfif property.cfcname is mydata.displayname>
									<var name="#htmleditformat(property.name)#" 
									purpose="#htmleditformat(property.hint)#" 
									required="#yesnoformat(property.required)#" 
									type="#htmleditformat(property.type)#" 
									default="#htmleditformat(property.default)#" />
								</cfif>
							</cfloop>
						</variables>
					</class>
				</spec>
			</cfsavecontent>
		<cfelse>
			<cfsavecontent variable="mydocs">
				<a name="cfc_#mydata.name#"></a>
				<table cellspacing="0" class="doc" width="100%" 
				style="font-family:verdana; font-size: 9pt; margin-top: 20px; border-right:solid black 1px!important;"><tbody>
					<tr style="font-size: 12pt; background-color: ##D0D0FF;">
					<td colspan="6">#htmleditformat(getDisplayName(mydata))#</td></tr>
					<tr><td colspan="6"><b>Extends:</b>
						<cfif arraylen(ancestor)>
							<cfloop index="x" from="1" to="#arraylen(ancestor)#"><cfset parent = ancestor[x]>
								<cfset temp = rereplacenocase(getfilefrompath(parent.path),'\.cfc$','')>
								<cfif getLib().cfcExists(getMetaLibrary(parent) & "." & temp) or getLib().cfcExists(temp)>
								<a href="#getURL('?netaction=cfc/' & getMetaLibrary(parent) & '&cfc=' & temp,'docs')#">
								#parent.displayname#</a><cfelse>#parent.displayname#</cfif>
								<cfif x lt arrayLen(ancestor)>&raquo;</cfif>
							</cfloop>
						</cfif>
					</td></tr>
					<tr><td colspan="6" bgcolor="white"><b>Usage:</b> #htmleditformat(mydata.hint)#</td></tr>
					<tr><td colspan="6"><b>Class Path:</b> #mydata.name#</td></tr>
					<cfif len(trim(mydata.example))>
					<tr><td colspan="6" bgcolor="white"><b>Example:</b> #htmleditformat(mydata.example)#</td></tr></cfif>
					<cfif len(trim(mydata.author)) or len(trim(mydata.email))>
						<cfif not len(trim(mydata.author))><cfset mydata.author = mydata.email></cfif>
						<cfif len(trim(mydata.email))>
							<cfsavecontent variable="authorxref">
								<a href="mailto:#htmleditformat(mydata.email)#">
								#htmleditformat(mydata.author)#</a>
							</cfsavecontent>
						<cfelse><cfset authorxref = mydata.author></cfif>
						<tr><td colspan="6" bgcolor="white"><b>Author:</b> #authorxref#</td></tr>
					</cfif>
					<tr style="font-weight: bold; background-color: ##D0D0FF;">
					<td>Properties</td><td>Required</td><td>Type</td><td>Default</td><td>Purpose</td></tr>
					<cfif structIsEmpty(properties)>
						<tr bgcolor="white"><td colspan="6">This object has no declared properties</td></tr>
					</cfif>
					<cfloop index="x" list="#listsort(structkeylist(properties),'textnocase')#">
						<cfset property = properties[x]>
						<tr valign="top" bgcolor="white">
							<td nowrap>#property.name#</td>
							<td nowrap>#yesnoformat(property.required)#</td>
							<td nowrap>#property.type#</td>
							<td><cfif issimplevalue(property.default)>
							#htmleditformat(property.default)#<cfelse>
							[#getLib().typeof(property.default)#]</cfif>&##160;</td>
							<td>#htmleditformat(property.hint)#</td>
						</tr>
					</cfloop>
					<tr><td colspan="6" style="font-weight: bold; background-color: ##D0D0FF">Methods</td></tr>
					<cfloop index="x" list="#listsort(structkeylist(methods),'textnocase')#">
						<cfset mymethod = methods[x]>
						<cfset arglist = mymethod.parameters>
						<tr style="font-size: 10pt; background-color: ##F0F0F0;">
						<td colspan="6" style="whites-space:nowrap; border-bottom:0px; <cfif mymethod.access is "private">font-style:italic;color:gray;</cfif>">
						<cfif getTap().getPage().script><a href="javascript:void(0);" style="font-size:7pt;" 
						onclick="#getLib().js.toggleDisplay(mymethod.cfcname & '.' & mymethod.name)#">[+]</a></cfif>
						<cfif mymethod.cfcpath is not mydata.name>
						<a href="#getURL('?netaction=cfc/' & mymethod.cfclibrary & '&cfc=' & rereplacenocase(getFileFromPath(mymethod.cfcfile),'\.cfc$',''),'docs')#">
						#htmleditformat(mymethod.cfcname)#</a><cfelse>#htmleditformat(myMethod.cfcName)#</cfif>.#htmleditformat(iif(structkeyexists(mymethod,"displayname"),"mymethod.displayname","mymethod.name"))#
						(<cfif arraylen(arglist) and (not structKeyExists(arglist[1],"required") or not arglist[1].required)><i>[</cfif>
						<cfloop index="x" from="1" to="#arraylen(arglist)#"><cfset arg = arglist[x]>
						<cfparam name="arg.required" type="string" default="false">
						<cfif x gt 1><cfif arglist[x-1].required and not arglist[x].required><i>[</cfif>, 
						</cfif>#htmleditformat(arglist[x].name)#</cfloop>
						<cfif arrayLen(arglist) and not arglist[arraylen(arglist)].required>]</i></cfif>)
						<cfif len(trim(mymethod.returntype))>return = #htmleditformat(mymethod.returntype)#</cfif></td></tr>
						<tr><td colspan="6" style="padding:0px; border-left: 0px;">
							<table id="#mymethod.cfcname#.#mymethod.name#" cellpadding="0" cellspacing="0" 
							style="<cfif getTap().getPage().script>display:none;</cfif> width:100%; border: 0px;">
								<tr valign="top" bgcolor="white">
									<td colspan="6" style="border-top:0px;">
										<b>Usage:</b> <cfif structkeyexists(mymethod,"deprecated")>
											<span style="color:red;font-weight:bold;font-size:small;">DEPRECATED</span>
										</cfif>#htmleditformat(mymethod.hint)#
									</td>
								</tr>
								<cfif len(trim(mymethod.example))>
								<tr valign="top" bgcolor="white"><td colspan="6">
								<b>Example:</b> #htmleditformat(mymethod.example)#</td></tr></cfif>
								<tr bgcolor="white">
									<td colspan="2"><b>Access:</b> #mymethod.access#</td>
									<td colspan="2"><b>Output:</b> #mymethod.output#</td>
									<td colspan="2"><b>Roles:</b> #mymethod.roles#</td>
								</tr>
								<cfif arraylen(arglist)>
									<tr style="font-weight: bold; background-color: ##F0F0F0;">
									<td style="text-transform:capitalize;">Arguments</td>
									<td>Required</td><td>Type</td><td>Default</td><td colspan="2">Purpose</td></tr>
									<cfloop index="y" from="1" to="#arraylen(arglist)#">
										<cfset arg = arglist[y]>
										<cfparam name="arg.type" type="string" default="Any">
										<cfparam name="arg.required" type="boolean" default="false">
										<cfparam name="arg.default" default="n/a">
										<cfparam name="arg.hint" type="string" default="">
										<tr valign="top" bgcolor="white">
											<td nowrap>#arg.name#</td>
											<td nowrap>#yesnoformat(arg.required)#</td>
											<td nowrap>#lcase(arg.type)#</td>
											<td nowrap><cfif issimplevalue(arg.default)>
											#htmleditformat(arg.default)#<cfelse>
											[#getLib().typeof(arg.default)#]</cfif>&##160;</td>
											<td colspan="2">#htmleditformat(arg.hint)#&##160;</td>
										</tr>
									</cfloop>
								</cfif>
							</table>
						</td></tr>
					</cfloop>
				</tbody></table>
			</cfsavecontent>
		</cfif></cfoutput>
		
		<cfreturn trim(mydocs)>
	</cffunction>
</cfcomponent>
