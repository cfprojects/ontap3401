<cfif attributes.tapdocs>
	<cf_doc>
			<spec>
				<library name="core">
					<function name="getIMGatSize" return="string"  xref="">
						<usage>
							gets a url to a specified image and if necessary resizes the image 
							automatically and stores it in an image cache directory 
						</usage>
						<arguments>
							<arg name="source" required="true" type="string" default="n/a">relative path to the target image from the images directory</arg>
							<arg name="width" required="false" type="string" default="n/a">width to resize the image - may be a number of pixels or a percentage</arg>
							<arg name="height" required="false" type="string" default="n/a">height to resize the image - may be a number of pixels or a percentage</arg>
							<arg name="placeholder" required="false" type="string" default="n/a">indicates the path to a placeholder image to display if the source image doesn't exist</arg>
							<arg name="maintainaspectratio" required="false" type="boolean" default="true">indicates if the aspect ratio of the image should be maintained when both height and width are specified</arg>
						</arguments>
					</function>
				</library>
			</spec>
	</cf_doc>
<cfelse>
	<cfset tReq("core/getURL")>
	
	<cffunction name="getIMGatSize" access="public" output="false" returntype="string">
		<cfargument name="source" type="string" required="true">
		<cfargument name="width" type="string" required="false" default="">
		<cfargument name="height" type="string" required="false" default="">
		<cfargument name="Placeholder" type="string" required="false" default="">
		<cfargument name="MaintainAspectRatio" type="boolean" required="false" default="true">
		<cfset var po = getTap().getPath()>
		
		<cfset arguments.source = po.getPath(source,"img")>
		<cfif len(placeholder)>
			<cfset arguments.placeholder = po.getPath(placeholder,"img")>
		</cfif>
		
		<cfreturn getTap().getIoC().getBean("thumbnail").getSizedImage(argumentcollection=arguments)>
	</cffunction>
	<cfset tStor("getIMGatSize")>
</cfif>

