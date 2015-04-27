<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif not isDefined("getTap")><cfinclude template="/cfc/mixin/tap.cfm" /></cfif>

<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">
	<cfset def = getIoC().getBean("mailman").getProperties()>
	
	<cf_doc>
			<spec>
				<library name="core">
					<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" return="none" xref="util/mail">
						<usage>
							this custom tag sends email using headers and defaults set within the application 
							-- defaults are stored in the getIoC().getBean("mailman") object 
						</usage>
						<versioninfo>
							<history>
								<change date="2003-12-31">concatenate multiple subtag parts and improved automatic formatting of text part</change>
							</history>
						</versioninfo>
						<cfoutput>
						<attributes>
							<attribute name="part" required="false" type="string" default="text">
								text | html = specifies which portion of a multi-part message 
								is being specified within the current tag - overridden by a sub-tag </attribute>
							<attribute name="subject" required="true" type="string" default="n/a">
								string to use for the subject header of this message</attribute>
							<attribute name="to" required="true" type="string" default="n/a">
								a list of addressed to send this message to</attribute>
							<attribute name="from" required="false" type="string" default="#def.from#">
								the address to use for replies to this message</attribute>
							<attribute name="replyto" required="false" type="string" default="##attributes.from##">
								Address(es) to which the recipient is directed to send replies.</attribute>
							<attribute name="query" required="false" type="query" default="n/a">
								a query containing recipients for the message 
							</attribute>
							<attribute name="startrow" required="false" type="numeric" default="1">
								an index of the query on which to start sending mail 
							</attribute>
							<attribute name="maxrows" required="false" type="numeric" default="-1">
								the maximum number of recipients to receive mail
							</attribute>
							<attribute name="group" required="false" type="string" default="">
								a column to group the query 
							</attribute>
							<attribute name="cc" required="false" type="string" default="">
								a list of addresses to &quot;carbon-copy&quot; this message to</attribute>
							<attribute name="bcc" required="false" type="string" default="">
								a list of addresses to &quot;bulk-carbon-copy&quot; this message to -- recipients will not see these addresses</attribute>
							<attribute name="server" required="false" type="string" default="#def.server#">
								the address of the smtp server to use to send this message</attribute>
							<attribute name="port" required="false" type="numeric" default="#def.port#">
								the port to send mail through the specified smtp server</attribute>
							<attribute name="attach" required="false" type="string|array" default="n/a">
								a string path indicating a file or directory or an array of absolute paths to files to attach to this message
								-- if a directory is specified, all files in the directory (not including subdirectories) will be attached</attribute>
							<attribute name="deletefiles" required="false" type="boolean" default="false">
								when true the tag deletes all files attached after sending the message</attribute>
							<attribute name="charset" required="false" type="string">
								the character set for outgoing email</attribute>
							<attribute name="encoding" required="false" type="string" default="#def.encoding#">
								the content-transfer-encoding for outgoing email</attribute>
							<attribute name="wrap" required="false" type="numeric" default="#def.wrap#">
								Specifies the maximum line length, in characters of the mail text. If a line has more than the 
								specified number of characters, replaces the last white space character, such as a tab or space, 
								preceding the specified position with a line break. If there are no white space characters, 
								inserts a line break at the specified position. A common value for this attribute is 72.
							</attribute>
							<attribute name="mailerid" required="false" type="string" default="#def.mailerid#">
								Mailer ID to be passed in X-Mailer SMTP header, which identifies the mailer application.</attribute>
							<attribute name="failto" required="false" type="string" default="##attributes.from##">
								Address to which mailing systems should send delivery failure notifications. 
								Sets the mail envelope reverse-path value.</attribute>
							<attribute name="usr" required="false" type="string">
								A user name to send to SMTP servers that require authentication. 
								Requires a password attribute.</attribute>
							<attribute name="pwd" required="false" type="string">
								A password to send to SMTP servers that require authentication. 
								Requires a username attribute.</attribute>
							<attribute name="timeout" required="false" type="numeric" default="#def.timeout#">
								Number of seconds to wait before timing out connection to SMTP server. 
								A value here overrides the Administrator.</attribute>
							<attribute name="spool" required="false" type="boolean" default="#def.spool#">
								Specifies whether to spool mail or always send it Immediately. 
								Overrides the ColdFusion Administrator Spool mail messages to disk for delivery setting.
								Yes saves a copy of the message until the sending operation is complete. 
								Pages that use this option might run slower than those that use the No option. 
								No queues the message for sending, without storing a copy until the operation is complete. 
								If a delivery error occurs when this option is No, ColdFusion generates 
								an Application exception and logs the error to the mail.log file.
							</attribute>
						</attributes>
						</cfoutput>
					</tag>
				</library>
			</spec>
		</cf_doc>

<cfelse>
	<cfsetting enablecfoutputonly="true">
	
	<cfparam name="attributes.part" type="string" default="text">
	<cfset variables.basetags = rereplacenocase(listchangedelims(getbasetaglist(),"/","\/"),"(CF_)[^,]*/([^,$]+)(,|$)","\1\2\3","ALL") />
	<cfset variables.basetags = rereplacenocase(variables.basetags,"(^|,)CF_MAIL(,|$)","\1\2","ONE")>
	<cfset variables.issubtag = listfindnocase(variables.basetags,"cf_mail")>
	
	<cfif variables.issubtag>
		
		<cfif thistag.executionmode is "end">
			<cfset attributes.content = thistag.generatedcontent>
			<cfassociate basetag="cf_mail" datacollection="#attributes.part#">
			<cfset thistag.generatedcontent = "">
		</cfif>
		
	<cfelse>
		
		<cfif thistag.executionmode is "end">
			<!--- format the message content -- use sub-tag parts or default to text part --->
			<cfparam name="thistag.#attributes.part#" type="array" default="#arraynew(1)#">
			<cfif not arraylen(thistag[attributes.part])>
				<cfset temp = structnew()>
				<cfset temp.part = attributes.part>
				<cfset temp.content = thistag.generatedcontent>
				<cfset arrayappend(thistag[attributes.part],temp)>
			</cfif>
			
			<!--- concatenate multiple text/html part sub-tags --->
			<cfloop index="x" list="html,text">
				<cfset attributes[x] = "">
				<cfif structkeyexists(thistag,x) and isarray(thistag[x])>
					<cfloop index="y" from="1" to="#arraylen(thistag[x])#">
						<cfset attributes[x] = attributes[x] & getTap().newline() & trim(thistag[x][y].content)>
					</cfloop>
				</cfif>
			</cfloop>
			
			<!--- check to see if this is a bulk message --->
			<cfparam name="attributes.query" type="query" default="#QueryNew('')#">
			<cfparam name="attributes.startrow" type="numeric" default="1">
			<cfparam name="attributes.maxrows" type="numeric" default="-1">
			
			<!--- the default mailer class is different for bulk mail than for single email --->
			<cfif attributes.query.recordcount>
				<cfparam name="attributes.mailer" type="string" default="bulkmail">
			<cfelse>
				<cfparam name="attributes.mailer" type="string" default="">
			</cfif>
			
			<!--- get the appropriate mailer from the application mailer --->
			<cfset mailman = getIoC().getBean("mailman")>
			<cfif len(attributes.mailer)>
				<cfset mailman = mailman.newMailer(attributes.mailer)>
			</cfif>
			
			<!--- send the message before exiting the tag --->
			<cfset mailman.send(argumentcollection=attributes)>
			<cfset thistag.generatedcontent = "">
		</cfif>
	</cfif>
	
	<cfsetting enablecfoutputonly="false">
	
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
</cfif>