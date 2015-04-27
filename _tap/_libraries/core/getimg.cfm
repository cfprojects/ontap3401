<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="core">
					<function name="getIMG" return="string"  xref="">
						<usage>returns an absolute url to an image in any /_image/ process subdirectory 
						as part of the nested subdirectories for the top-level process of the current page </usage>
						<example>&lt;img src=&quot;#this.getIMG('logo.gif')#&quot;&gt;</example>
						<arguments>
							<arg name="source" required="true" type="string" default="n/a">relative path to the target image from the images directory</arg>
							<arg name="dynamic" required="false" type="boolean" default="true">when true the function checks for nested directories and images -- used for branded layouts</arg>
							<arg name="getcache" required="false" type="boolean" default="true">indicates if a dynamic path to the image file should be returned from cache</arg>
							<arg name="cache" required="false" type="boolean" default="true">indicates if a dynamic path should be stored in cache</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	
	<cffunction name="getIMG" access="public" output="false" returntype="string">
		<cfargument name="source" type="string" required="true">
		<cfargument name="dynamic" type="boolean" required="false" default="true">
		<cfargument name="getcache" type="boolean" required="false" default="true">
		<cfargument name="cache" type="boolean" required="false" default="true">
		<cfscript>
			var my = structNew();
			var oPath = getTap().getPath();
			var nest = oPath.nest;
			var fullpath = "";
			var temp = "";
			var lang = lcase(listchangedelims(getTap().getLocal().language,"/","_-"));
			var spath = oPath.getPath("_images/" & arguments.source,"P");
			var x = 0; 
			
			if (not arguments.dynamic) { return oPath.getURL(spath); } 
			
			if (arguments.getcache or arguments.cache) { 
				my.cachename = "application.tap_images.#hash(spath)#.#lang#.#hash(oPath.brand)#.#hash(nest[arraylen(nest)])#"; 
				if (arguments.getcache) { 
					fullpath = getIoC().getBean("cachemanager").fetch(my.cachename); 
					if (not fullpath.status) { return fullpath.content; } 
				} 
			} 
			
			for (x = arraylen(nest); x; x = x - 1) { 
				if (getTap().getLocal().uselsdata) { 
					temp = "#nest[x]#/_images/_l10n/#lang#/#source#"; 
					if (getTap().brand) { 
						fullpath = oPath.getPath(temp,"B"); 
						if (fileexists(fullpath)) { break; } 
					} 
					fullpath = oPath.getPath(temp,"P"); 
					if (fileexists(fullpath)) { break; } 
					if (find("/",lang)) { 
						temp = rereplacenocase(temp,"/_l10n/#lang#/","/_l10n/#listfirst(lang,'/')#/"); 
						if (getTap().brand) { 
							fullpath = oPath.getPath(temp,"B"); 
							if (fileexists(fullpath)) { break; } 
						} 
						fullpath = oPath.getPath(temp,"P"); 
						if (fileexists(fullpath)) { break; } 
					} 
				} 
				temp = rereplacenocase(temp,"/_l10n/\w+","/"); 
				if (getTap().brand) { 
					fullpath = oPath.getPath(temp,"B"); 
					if (fileexists(fullpath)) { break; } 
				} 
				fullpath = oPath.getPath(temp,"P"); 
				if (fileexists(fullpath)) { break; } 
			} 
			if (fileexists(fullpath)) { 
				fullpath = oPath.getURL(fullpath); 
				if (arguments.cache) { getIoC().getBean("cachemanager").store(my.cachename,fullpath); } 
			} else { fullpath = oPath.getURL(spath); } 
		</cfscript>
		
		<cfreturn fullpath>
	</cffunction>
	<cfset tStor("getIMG")>
</cfif>

