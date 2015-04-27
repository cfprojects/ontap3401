<cfcomponent displayname="MailMan" output="false" extends="ontap" hint="provides enhanced outgoing email features">
	<cfproperty name="server" type="string" default="" hint="address of the smtp server">
	<cfproperty name="port" type="numeric" default="25" hint="port of the smtp server">
	<cfproperty name="usr" type="string" default="" hint="username for the smtp server">
	<cfproperty name="pwd" type="string" default="" hint="password for the smtp server">
	<cfproperty name="from" type="string" default="" hint="a default from header for outgoing mail">
	<cfproperty name="wrap" type="numeric" default="60" hint="indicates the column at which to wrap outgoing text messages">
	<cfproperty name="mailerid" type="string" default="onTap Framework - ColdFusion" hint="mailerid header for outgoing messages">
	<cfproperty name="failto" type="string" default="" hint="a failto address for outgoing messages">
	<cfproperty name="spool" type="boolean" default="true" hint="indicates if messages should be spooled">
	<cfproperty name="charset" type="string" default="UTF-8" hint="the character set for outgoing messages">
	<cfproperty name="encoding" type="string" default="7bit" hint="the smtp encoding type for outgoing messages">
	<cfproperty name="attachments" type="string" default="" hint="a path or path alias from which attachments are relative">
	<cfproperty name="doctype" type="string" default="" hint="indicates the doctype used for the html part of outgoing messages">
	<cfproperty name="style" type="string" default="" hint="CSS style declarations used for outgoing messages">
	
	<cfset setProperty("port",25)>
	<cfset setProperty("wrap",60)>
	<cfset setProperty("encoding","7bit")>
	<cfset setProperty("charset","UTF-8")>
	<cfset setProperty("mailerid","onTap Framework - ColdFusion")>
	<cfset setProperty("spool",true)>
	<cfset setProperty("timeout",60)>
	<cfset setProperty("failto","")>
	<cfset setProperty("server","")>
	<cfset setProperty("usr","")>
	<cfset setProperty("pwd","")>
	<cfset setProperty("doctype","")>
	<cfset setProperty("style","")>
	<cfset setProperty("from","")>
	
	<cfset variables.newline = chr(13) & chr(10)>
	<cfset variables.header = structNew()>
	<cffile action="read" file="#getPath('/mail/html2text.xsl','CFC')#" variable="variables.transform">
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="server" type="string" default="" hint="address of the smtp server">
		<cfargument name="usr" type="string" default="" hint="username for the smtp server">
		<cfargument name="pwd" type="string" default="" hint="password for the smtp server">
		<cfargument name="from" type="string" default="" hint="a default from header for outgoing mail">
		
		<cfset setProperties(arguments)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setTransform" access="public" output="false">
		<cfargument name="xslt" type="string" required="true">
		<cfset variables.transform = arguments.xslt>
	</cffunction>
	
	<cffunction name="setHeader" access="public" output="false">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="string" required="true">
		<cfset variables.header[arguments.name] = arguments.value>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="removeHeader" access="public" output="false">
		<cfargument name="name" type="string" required="true">
		<cfset structDelete(variables.header,arguments.name)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getHeaderCollection" access="public" output="false" returntype="struct">
		<cfreturn structCopy(variables.header)>
	</cffunction>
	
	<cffunction name="appendHeaders" access="public" output="false">
		<cfargument name="headers" type="struct" required="true">
		<cfargument name="overwrite" type="boolean" required="false" default="true">
		<cfset structAppend(variables.header,arguments.headers,arguments.overwrite)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="newMailer" access="public" output="false" hint="returns a new mail object populated with this object's properties">
		<cfargument name="classname" type="string" required="false" default="mailman">
		<cfreturn getNewMailer(classname)>
	</cffunction>
	
	<cffunction name="getNewMailer" access="private" output="false">
		<cfargument name="classname" type="string" required="true">
		<cfset var mailer = "">
		
		<cfinvoke component="#CreateObject('component','cfc.' & classname)#" method="init" 
			argumentcollection="#getProperties()#" returnvariable="mailer">
		<cfreturn mailer.appendHeaders(getHeaderCollection(),true)>
	</cffunction>
	
	<cffunction name="getTextFromHTMLStruct" access="private" output="false">
		<cfargument name="html" type="struct" required="true">
		<cfreturn getLib().html.showText(html)>
	</cffunction>
	
	<cffunction name="flattenHTMLStruct" access="private" output="false">
		<cfargument name="html" type="struct" required="true">
		<cfreturn getLib().html.show(html)>
	</cffunction>
	
	<cffunction name="getMessageStrings" access="private" output="false" returntype="struct">
		<cfargument name="html" required="true">
		<cfargument name="text" required="true">
		
		<cfif isStruct(arguments.html)>
			<cfif not len(trim(arguments.text))>
				<cfset arguments.text = getTextFromHTMLStruct(arguments.html)>
			</cfif>
			<cfset arguments.html = flattenHTMLStruct(arguments.html)>
		<cfelseif len(trim(arguments.html)) and not len(trim(arguments.text))>
			<cfset arguments.text = HTML2Text(arguments.html)>
		</cfif>
		
		<cfreturn arguments>
	</cffunction>
	
	<cffunction name="send" access="public" output="false" hint="all mailer properties can be overriden by specifying them as arguments">
		<cfargument name="to" type="string" required="true">
		<cfargument name="subject" type="string" required="true">
		<cfargument name="html" type="any" required="false" default="">
		<cfargument name="text" type="string" required="false" default="">
		<cfargument name="cc" type="string" required="false" default="">
		<cfargument name="bcc" type="string" required="false" default="">
		<cfargument name="attach" type="any" required="false" default="">
		<cfargument name="deletefiles" type="boolean" required="false" default="false">
		<cfargument name="from" type="string" required="false" default="#getValue('from')#">
		<cfargument name="replyto" type="string" required="false" default="#arguments.from#">
		<cfargument name="attachfrom" type="string" required="false" default="#getValue('attachments')#">
		<cfargument name="headers" type="struct" required="false" default="#StructNew()#">
		<cfset var i = 0>
		<cfset var header = getHeaderCollection()>
		<cfset structAppend(header,arguments.headers,true)>
		
		<cfset structAppend(arguments,getProperties(),false)>
		<cfset structAppend(arguments,getMessageStrings(arguments.html,arguments.text),true)>
		<cfset arguments.attach = getAttachmentArray(arguments.attach,arguments.attachfrom)>
		
		<cfmail server="#arguments.server#" 
			from="#arguments.from#" 
			to="#arguments.to#" 
			cc="#arguments.cc#" 
			bcc="#arguments.bcc#" 
			port="#arguments.port#" 
			subject="#arguments.subject#" 
			replyto="#arguments.replyto#" 
			failto="#arguments.failto#" 
			mailerid="#arguments.mailerid#" 
			username="#arguments.usr#" 
			password="#arguments.pwd#" 
			timeout="#arguments.timeout#" 
			spoolenable="#arguments.spool#">
			
			<!--- include mail headers specified in the framework --->
			<cfloop item="i" collection="#header#">
			<cfmailparam name="#i#" value="#header[i]#"></cfloop>
			
			<cfmailpart type="text/plain" charset="#arguments.charset#" 
				wraptext="#arguments.wrap#">#arguments.text#</cfmailpart>
			
			<cfif len(trim(arguments.html))>
				<cfmailpart type="text/html" charset="#arguments.charset#" 
				wraptext="#arguments.wrap#">#formatHTML(argumentcollection=arguments)#</cfmailpart>
			</cfif>
			
			<cfif arraylen(arguments.attach)>
				<cfloop index="i" from="1" to="#arraylen(arguments.attach)#">
				<cfmailparam file="#arguments.attach[i]#"></cfloop>
			</cfif>
		</cfmail>
		
		<!--- remove sent files from the server if specified --->
		<cfif arguments.deletefiles and arraylen(arguments.attach)>
			<cfset removeAttachedFiles(arguments.attach)>
		</cfif>
	</cffunction>
	
	<cffunction name="formatHTML" access="private" output="false" returntype="string">
		<cfargument name="html" type="string" required="true">
		<cfargument name="style" type="string" required="false" default="">
		<cfargument name="doctype" type="string" required="false" default="">
		<cfset var content = "">
		
		<cfsavecontent variable="content">
			<cfoutput>
				#arguments.doctype#
				<html>
					<head>
						<style>
							/* <![CDATA[ */
							#arguments.style#
							/* ]]> */
						</style>
					</head>
					<body>#arguments.html#</body>
				</html>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn content>
	</cffunction>
	
	<cffunction name="removeAttachedFiles" access="private" output="false">
		<cfargument name="attachments" type="array" required="true">
		<cfset var i = 0>
		<cfset var File = CreateObject("component","cfc.file").init()>
		<cfloop index="i" from="1" to="#arraylen(arguments.attachments)#">
			<cfset File.setValue("domain",arguments.attachments[i]).delete()>
		</cfloop>
	</cffunction>
	
	<cffunction name="getPath" access="private" output="false" returntype="string">
		<cfargument name="file" type="string" required="true">
		<cfargument name="domain" type="string" required="true">
		<cfreturn getFS().getPath(file,domain)>
	</cffunction>
	
	<cffunction name="getAttachmentArray" access="private" output="false" returntype="array">
		<cfargument name="attach" required="true" type="any">
		<cfargument name="attachfrom" required="true" type="string">
		<cfset var rsattach = 0>
		<cfset var temp = 0>
		<cfset var localarray = ArrayNew(1)>
		<cfset var file = "">
		
		<cfif issimplevalue(arguments.attach) and len(trim(arguments.attach))>
			<cfset file = CreateObject("component","cfc.file").init(arguments.attach,arguments.attachfrom)>
			<cfif file.isFile()>
				<cfset ArrayAppend(localarray,file.getValue("filepath"))>
			<cfelseif file.isDirectory()>
				<cfset rsattach = file.dir()>
				<cfloop query="rsattach">
					<cfif rsattach.type is "file">
						<cfset arrayappend(localarray,getPath(rsattach.name,rsattach.directory))>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		
		<cfreturn localarray>
	</cffunction>
	
	<cffunction name="HTML2Text" access="private" output="false" returntype="string">
		<cfargument name="html" type="string" required="true">
		<cfset var text = arguments.html>
		<cfset var nl = variables.newline>
		
		<cftry>
			<cfset text = XmlTransform("<mail>#text#</mail>",variables.transform)>
			<cfcatch>
				<!--- remove script and/or style tags --->
				<cfset text = rereplacenocase(text,"<\s*(script|style)[^>]*>.*<\s*/\s*\1\s*>","","ALL")>
				<cfset text = rereplacenocase(text,"<head[^>]*>.*?<\s*/\s*head\s*>","","ONE")>
				<!--- replace paragraph tags with line breaks --->
				<cfset text = rereplacenocase(text,"<\s*/\s*p\s*>\s*<p[^>]*>",nl & nl,"ALL")>
				<cfset text = replacenocase(text,"<\s*/\s*p\s*>",nl & nl)>
				<cfset text = replacenocase(text,"<li[^>]*>",nl & " - ","ALL")>
				<cfset text = replacenocase(text,"(<table[^>]*>|<\s*/\s*(tr|ol|ul)\s*>)",nl,"ALL")>
				<!--- remove any remaining html tags --->
				<cfset text = rereplace(text,"<[^>]*>","","ALL")>
				<!--- remove leading white space on a line --->
				<cfset text = rereplace(text,"([#chr(13)##chr(10)#])[#chr(9)##chr(32)#]+","\1","ALL")>
				<!--- remove more than 2 consecutive line breaks --->
				<cfset text = rereplacenocase(text,"[#chr(13)##chr(10)#]{4,}",repeatstring(getTap().newline(),2),"ALL")>
				<!--- convert common html entities to their text equivalents --->
				<cfset text = replacelist(text,"&lt;,&gt;,&quot;,&apos;","<,>,"",'")>
			</cfcatch>
		</cftry>

		<cfreturn text>
	</cffunction>
	
	<cffunction name="get_doctype" access="public" output="false" returntype="string">
		<cfset var doctype = getProperty("doctype")>
		<cfif not len(trim(doctype))>
			<cfset doctype = getTap().getHTML().doctype />
		</cfif>
		<cfreturn "">
	</cffunction>
	
	<cffunction name="get_style" access="public" output="false" returntype="string">
		<cfset var style = getProperty("style")>
		<cfif not len(trim(style))>
			<cfset style = getDefaultStyle()>
			<cfset setProperty("style",style)>
		</cfif>
		<cfreturn style>
	</cffunction>
	
	<cffunction name="getDefaultStyle" access="private" output="false" returntype="string">
		<cfset var dir = getPath("_htmlhead","P")>
		<cfset var style = ListToArray("/* onTap framework email styles */")>
		<cfset var css = 0>
		<cfset var file = "">

		<cfdirectory action="list" name="css" directory="#dir#" filter="*.css">
		<cfloop query="css">
			<cffile action="read" file="#getPath(css.name,dir)#" variable="file">
			<cfset ArrayAppend(style,file)>
		</cfloop>
		
		<cfreturn ArrayToList(style,chr(13) & chr(10))>
	</cffunction>
</cfcomponent>
