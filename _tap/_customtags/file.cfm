<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">
	
	<cf_doc>
			<spec>
				<library name="core">
					<tag name="<cfoutput>#lcase(getfilefrompath(getcurrenttemplatepath()))#</cfoutput>" return="string" xref="">
						<usage>
							this custom tags acts as a wrapper for the ColdFusion native cffile tag
							with lots of additional built-in features including content caching and xml serialization
						</usage>
						<example>
							&lt;cf_file action=&quot;read&quot; 
							method=&quot;text&quot; return=&quot;myfile&quot; 
							file=&quot;#ExpandPath('/path/to/myfile')#&quot;&gt;
						</example>
						<attributes>
							<attribute name="file" required="true" type="string" default="n/a">an absolute path to the file to be manipulated</attribute>
							<attribute name="action" required="true" type="string" default="n/a">the action to perform on the file (read|write|append|delete|deltree|upload|download|move|copy|rename)</attribute>
							<attribute name="format" required="false" type="string" default="text">the method for the given action (text|binary|xml|wddx|include|resourcebundle) - not required for upload, download, move, rename or delete</attribute>
							<cfinclude template="docs/returnattributes.cfm">
							<attribute name="output" required="false" type="any" default="n/a">content to write to the file - required when action is write or append</attribute>
							<attribute name="destination" required="false" type="string" default="n/a">an absolute path to the destination file or directory where a file is to be moved or renamed - required for the actions move, rename and upload</attribute>
							<attribute name="charset" required="false" type="string" default="#getTap().getPage().charset#">determines the character set when action = write or append</attribute>
							<attribute name="refresh" required="false" type="boolean" default="false">forces file content to be drawn from the file system instead of memory - default is reversed in development</attribute>
							<attribute name="cache" required="false" type="boolean" default="true">caches file content in the server scope based on its absolute file path</attribute>
							<attribute name="timeout" required="false" type="numeric" default="5">a timeout value in seconds to lock and perform file actions</attribute>
							<attribute name="attributes" required="false" type="string" default="normal">sets attributes of the file, i.e. (ReadOnly,Temporary,Archive,Hidden,System,Normal)</attribute>
							<attribute name="mode" required="false" type="string" default="775">sets file permissions on a unix server</attribute>
							<attribute name="extension" required="false" type="string" default="txt">indicates the file extension used to read a resource bundle when only the directory is specified in the file attribute</attribute>
							<attribute name="filefield" required="false" type="string" default="n/a">indicates the form field for a file to be uploaded when action=upload</attribute>
							<attribute name="nameconflict" required="false" type="string" default="overwrite">indicates how to handle name conflicts when action=upload</attribute>
							<attribute name="accept" required="false" type="string" default="">the acceptable mime type for a file upload</attribute>
							<attribute name="addnewline" required="false" type="boolean" default="false">determines if a new line should be added when action=append</attribute>
							<attribute name="overwrite" required="false" type="booleaan" default="true">when false the tag will throw an exception during a write operation if the file exists prior to writing</attribute>
							<attribute name="casesensitive" required="false" type="boolean" default="false">case sensitivity when action = read and method = xml</attribute>
							<attribute name="filename" required="false" type="string" default="n/a">provides an alternate file name for a delivered file when action = download</attribute>
							<attribute name="deletefile" required="false" type="boolean" default="false">indicates if a file should be deleted after performing a download with action = download</attribute>
						</attributes>
					</tag>
				</library>
			</spec>
		</cf_doc>

<cfelse>
	<cfif thistag.executionmode is "end" or not thistag.hasendtag>
		<cfsilent>
			<cfparam name="attributes.action" type="string">
			<cfparam name="attributes.format" type="string" default="text">
			
			<cfinclude template="/cfc/mixin/tap.cfm" />
			
			<cfif thistag.executionmode is "end">
				<cfset attributes.output = thistag.generatedcontent>
				<cfset thistag.generatedcontent = "">
			</cfif>
			
			<cfset attributes.format = lcase(rereplace(attributes.format,"\W","","ALL")) />
			<cfif structkeyexists(attributes,"file")><cfset attributes.file = getFS().getPath(attributes.file,"",false,false) /></cfif>
			<cfif structkeyexists(attributes,"destination")><cfset attributes.destination = getFS().getPath(attributes.destination,"",false,false) /></cfif>
			<cfset format = getIoC().getBean("filemanager").getFormat(attributes.format)>
			
			<cfinvoke component="#format#" 
						method="#attributes.action#" 
						argumentcollection="#attributes#" 
						returnvariable="variables.filedata">
						
			<cfif isdefined("variables.filedata")>
				<cfinclude template="#getFS().return(variables.filedata)#">
			</cfif>
		</cfsilent>
		
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
</cfif>
