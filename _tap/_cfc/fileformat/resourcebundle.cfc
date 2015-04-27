<cfcomponent displayname="Resource-Bundle File Format" extends="fileformat">
	<cfset variables.format = "resourcebundle">
	<cfset variables.defaultextension = "rb,txt">
	<cfset variables.defaultlocale = getTap().getLocal().language>
	
	<cffunction name="read" access="public" output="false" returntype="struct">
		<cfargument name="file" type="string" required="true" />
		<cfargument name="locale" type="string" required="false" default="" />
		<cfargument name="extension" type="string" required="false" default="#variables.defaultextension#" />
		<cfargument name="charset" type="string" required="false" default="#variables.defaultcharset#" />
		<cfargument name="refresh" type="boolean" required="false" default="#variables.defaultrefresh#" />
		<cfargument name="cache" type="boolean" required="false" default="#variables.defaultcache#" />
		<cfargument name="lockwait" type="numeric" default="#variables.defaulttimeout#" />
		<cfset var my = structnew() />
		<cfset var x = 0 />
		<cfset var y = 0 />
		<cfset var output = structnew() />
		<cfset var currentFile = "" />
		
		<cfif DirectoryExists(arguments.file)>
			<cfif not len(trim(arguments.locale))>
				<cfset arguments.locale = variables.defaultlocale />
			</cfif>
			
			<cfset my.aLocale = listToArray(lcase(locale),"-_") />
			<cfset my.next = "" />
			
			<cfloop index="x" from="1" to="#arrayLen(my.aLocale)#">
				<cfset my.next = listAppend(my.next,my.aLocale[x],"_")>
				<cfloop index="y" list="#arguments.extension#">
					<cfset currentFile = getPath(my.next & "." & y,arguments.file)>
					<cfif fileExists(currentFile)>
						<cfinvoke method="read" returnvariable="my.data" 
						charset="#arguments.charset#" refresh="#arguments.refresh#" 
						cache="#arguments.cache#" lockwait="#arguments.lockwait#" file="#currentFile#">
						
						<cfset structappend(output,my.data,true)>
						<cfbreak />
					</cfif>
				</cfloop>
			</cfloop>
			
			<cfreturn output>
		<cfelse>
			<cfreturn super.read(argumentcollection=arguments) />
		</cfif>
	</cffunction>
	
	<cffunction name="readFromDisk" access="private" output="false">
		<cfargument name="file" type="string" required="true" />
		<cfargument name="charset" type="string" required="false" default="#variables.defaultcharset#" />
		<cfset var content = "" />
		
		<cfif arguments.charset is "ISO-8859-1" or right(arguments.file,3) is ".rb">
			<!--- if the character set was explicitly declared on read as ANSI text 
			or if the bundle is saved with an extension of .rb, read it as a Java bundle 
			and convert the associated unicode escape strings --->
			<cfset content = CreateObject("java","java.io.FileInputStream").init(arguments.file) />
		<cfelse>
			<!--- otherwise assume it's just a UTF8 format text file --->
			<cffile action="read" file="#arguments.file#" variable="content" />
		</cfif>
		
		<cfreturn content />
	</cffunction>
	
	<cffunction name="readJavaResourceBundle" access="private" output="false" returntype="struct">
		<cfargument name="InputStream" required="true" />
		<cfset var rb = CreateObject("java","java.util.PropertyResourceBundle").init(InputStream) />
		<cfset var enum = rb.getKeys() />
		<cfset var st = StructNew() />
		<cfset var key = "" />
		
		<cfloop condition="enum.hasMoreElements()">
			<cfset key = enum.nextElement() />
			<cfset st[key] = rb.handleGetObject(key) />
		</cfloop>
		
		<cfreturn st />
	</cffunction>
	
	<cffunction name="readTextResourceBundle" access="private" output="false" returntype="struct">
		<cfargument name="text" type="string" required="true">
		<cfset var stringdata = structnew()>
		<cfset var lineitem = 0>
		
		<cfloop index="lineitem" list="#arguments.text#" delimiters="#chr(13)##chr(10)#">
			<!--- resource bundles don't execute cf-code -- use pound symbols for comments --->
			<cfif len(lineitem) AND left(lineitem,1) NEQ chr(35)>
				<cfset stringdata[trim(listFirst(lineitem,"="))] = trim(listRest(lineitem,"="))>
			</cfif>
		</cfloop>
		
		<cfreturn stringdata>
	</cffunction>
	
	<cffunction name="textToOutput" access="private" output="false" returntype="struct">
		<cfargument name="output" type="any" required="true">
		<cfset var stringdata = structnew()>
		<cfset var lineitem = 0>
		
		<cfif isSimpleValue(arguments.output)>
			<cfreturn readTextResourceBundle(arguments.output) />
		<cfelse>
			<cfreturn readJavaResourceBundle(arguments.output) />
		</cfif>
	</cffunction>
	
	<cffunction name="outputToText" access="private" output="false" returntype="string">
		<cfargument name="output" type="struct" required="true">
		<cfset var x = 0><cfset var text = ArrayNew(1)>
		<cfloop item="x" collection="#output#">
			<cfif isSimpleValue(output[x])>
				<cfset ArrayAppend(text,"#x#=#output[x]#")>
			</cfif>
		</cfloop>
		<cfreturn ArrayToList(text,getTap().newline())>
	</cffunction>
</cfcomponent>