<cfcomponent displayname="BulkMail" output="false" extends="mailman" hint="a mailmain extension for query-driven multi-recipient email">
	<cfproperty name="evaluate" type="boolean" default="false" hint="when true subject and message are evaluated to include coldfusion variables">
	<cfset setProperty("evaluate",false)>
	
	<cffunction name="newMailer" access="public" output="false" hint="returns a new mail object populated with this object's properties">
		<cfargument name="classname" type="string" required="false" default="bulkmail">
		<cfreturn getNewMailer(classname)>
	</cffunction>
	
	<cffunction name="send" access="public" output="false" hint="all mailer properties can be overriden by specifying them as arguments">
		<cfargument name="query" type="query" required="true" hint="a query containing recipient addresses">
		<cfargument name="subject" type="string" required="true">
		<cfargument name="html" type="any" required="false" default="">
		<cfargument name="text" type="string" required="false" default="">
		<cfargument name="attach" type="any" required="false" default="">
		<cfargument name="deletefiles" type="boolean" required="false" default="false">
		<cfargument name="to" type="string" required="false" default="email" hint="indicates the query column containing the to email address">
		<cfargument name="cc" type="string" required="false" default="cc" hint="indicates the query column containing cc addresses">
		<cfargument name="bcc" type="string" required="false" default="bcc" hint="indicates the query column containing bcc addresses">
		<cfargument name="from" type="string" required="false" default="#getValue('from')#">
		<cfargument name="replyto" type="string" required="false" default="#arguments.from#">
		<cfargument name="attachfrom" type="string" required="false" default="#getValue('attachments')#">
		<cfargument name="headers" type="struct" required="false" default="#StructNew()#">
		<cfargument name="startrow" type="numeric" required="false" default="1">
		<cfargument name="maxrows" type="numeric" required="false" default="#query.recordcount#">
		<cfset var header = getHeaderCollection()>
		<cfset var ccInQuery = false>
		<cfset var bccInQuery = false>
		<cfset var htmlpart = "">
		<cfset var i = 0>
		<cfset structAppend(header,arguments.headers,true)>
		<cfset structAppend(arguments,getProperties(),false)>
		<cfset structAppend(arguments,getMessageStrings(arguments.html,arguments.text),true)>
		
		<cfset htmlpart = arguments.html>
		<cfif arguments["evaluate"]>
			<cfset htmlpart = replace(htmlpart,"'","''","AlL")>
			<cfset arguments.text = replace(arguments.text,"'","''","ALL")>
			<cfset arguments.subject = replace(arguments.subject,"'","''","ALL")>
		<cfelse>
			<cfset arguments.subject = replace(arguments.subject,chr(35),repeatstring(chr(35),2),"ALL")>
		</cfif>
		
		<cfset arguments.attach = getAttachmentArray(arguments.attach,arguments.attachfrom)>
		<cfset arguments.cc = trim(arguments.cc)>
		<cfset arguments.bcc = trim(arguments.bcc)>
		<cfset ccInQuery = iif(len(arguments.cc) and listFindNoCase(query.columnlist,arguments.cc),true,false)>
		<cfset bccInQuery = iif(len(arguments.bcc) and listFindNoCase(query.columnlist,arguments.bcc),true,false)>
		<cfif not ccInQuery><cfset arguments.cc = rereplaceNoCase(arguments.cc,"^cc$","")></cfif>
		<cfif not bccInQuery><cfset arguments.bcc = rereplaceNoCase(arguments.bcc,"^bcc$","")></cfif>
		
		<cfmail server="#arguments.server#" 
			from="#arguments.from#" 
			to="#evaluate(arguments.to)#" 
			cc="#iif(ccInQuery,'evaluate(arguments.cc)','arguments.cc')#" 
			bcc="#iif(bccInQuery,'evaluate(arguments.bcc)','arguments.bcc')#" 
			port="#arguments.port#" 
			subject="#evaluate("'#arguments.subject#'")#" 
			replyto="#arguments.replyto#" 
			failto="#arguments.failto#" 
			mailerid="#arguments.mailerid#" 
			username="#arguments.usr#" 
			password="#arguments.pwd#" 
			timeout="#arguments.timeout#" 
			spoolenable="#arguments.spool#" 
			query="arguments.query" 
			startrow="#arguments.startrow#" 
			maxrows="#arguments.maxrows#">
			
			<!--- include mail headers specified in the framework --->
			<cfloop item="i" collection="#header#">
			<cfmailparam name="#i#" value="#header[i]#"></cfloop>
			
			<cfmailpart type="text/plain" charset="#arguments.charset#" wraptext="#arguments.wrap#"
			><cfif arguments["evaluate"]>#evaluate("'#arguments.text#'")#<cfelse>#arguments.text#</cfif></cfmailpart>
			
			<cfif len(trim(htmlpart))>
				<cfif arguments["evaluate"]>
					<cfset arguments.html = evaluate("'#htmlpart#'")>
				</cfif>
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
</cfcomponent>
