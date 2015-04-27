<cfparam name="attributes.tapdocs" type="boolean" default="false">
<cfif attributes.tapdocs>
	<cfparam name="attributes.xml" type="boolean" default="false">
	<cf_doc>
			<spec>
				<library name="file">
					<tag name="translate.cfm" xref="">
						<usage>
							reads text strings from a resource bundle into 
							the getTap().getLocal() object for use in i18n multi-lingual applications 
							- if a directory is specified instead of an individual file, the tag will load all relevant bundles in the directory based on locale 
							- bundles with an extension of .rb will be read via Java with unicode escape characters converted 
						</usage>
						<example>&lt;cf_translate file="/inc/mybundle/" /&gt;</example>
						<arguments>
							<attribute name="file" type="string" required="true" default="n/a">an absolute path to the target file</attribute>
							<attribute name="locale" type="string" required="false" default="#getTap().getLocal().language#">
								allows a directory to be specified and bundle files to be identified automatically in the specified directory</attribute>
							<attribute name="overwrite" type="boolean" required="false" default="true">
								indicates if values in the resource bundle should overwrite existing values in the getTap().getLocal() object
							</attribute>
							<attribute name="extension" type="string" required="false" default="rb,txt">
								indicates the file extension to use if only a directory is specified (comma delimited list of extensions in order of preference)</attribute>
							<attribute name="charset" type="string" required="false" default="#getTap().getPage().charset#">
								indicates the character set of the file or files used as resource bundles -- 
								declaring this explicitly to be "ISO-8859-1" will force the tag to use Java 
								to read the bundles and convert unicode escape characters 
							</attribute>
							<attribute name="refresh" type="boolean" required="false" default="#getTap().development#">
								corresponds to the refresh attribute of the file tag</attribute>
						</arguments>
					</tag>
				</library>
			</spec>
		</cf_doc>
<cfelse>
	<cfparam name="attributes.file" type="string">
	<cfparam name="attributes.overwrite" type="boolean" default="true">
	
	<cfinclude template="/cfc/mixin/tap.cfm" />
	
	<cfif not fileExists(attributes.file) and left(attributes.file,1) is "/">
		<cfset attributes.file = expandpath(attributes.file) />
	</cfif>
	
	<cfset format = getIoC().getBean("filemanager").getFormat("resourcebundle") />
	<cfset bundle = format.read(argumentcollection=attributes) />
	<cfset getTap().getLocal().appendKeys(bundle,attributes.overwrite) />
	
	<cfexit method="exittag" />
</cfif>

