<cfcomponent displayname="Thumbnail" output="false" hint="scales images with caching">
	<cfset variables.supportedformats = GetWriteableImageFormats()>
	<cfset this.threadpriority = "high">
	<cfset this.interpolation = "highperformance">
	<cfset this.cachepath = "cache">
	<cfset this.jpegquality = 1>
	<cfset this.blur = 1>
	
	<cfinclude template="/cfc/mixin/tap.cfm" />
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="MaintainAspectRatio" type="boolean" required="false" default="true">
		<cfset structAppend(variables,arguments,true)>
		<cfset variables.FileMan = getIoC().getBean("filemanager") />
		<cfreturn this>
	</cffunction>
	
	<cffunction name="supportsFormat" access="public" output="false" returntype="boolean" hint="indicates if the thumbnail component is able to resize a specified image">
		<cfargument name="source" type="string" required="true" hint="absolute path to an image file">
		<cfreturn iif(listfindnocase(variables.supportedformats,listlast(arguments.source,".")),true,false)>
	</cffunction>
	
	<cffunction name="getSizedImage" access="public" output="false" returntype="string" hint="returns a final url to a cached and resized copy of an image">
		<cfargument name="source" type="string" required="true" hint="absolute path to an image file">
		<cfargument name="width" type="string" required="false" default="" hint="width of the resized image">
		<cfargument name="height" type="string" required="false" default="" hint="height of the resized image">
		<cfargument name="Placeholder" type="string" required="false" default="" hint="an alternative image to display if the specified image is not found">
		<cfargument name="MaintainAspectRatio" type="boolean" required="false" default="true" hint="when true width and height arguments are treated as maximums">
		<cfset var image = getSizedImageCache(argumentcollection=arguments)>
		
		<cfif isSimpleValue(image)>
			<cfreturn image />
		<cfelse>
			<cfreturn resize(argumentcollection=image) />
		</cfif>
	</cffunction>
	
	<cffunction name="getSizedImageCache" access="private" output="false" hint="returns a final url to a cached and resized copy of an image">
		<cfargument name="source" type="string" required="true" hint="absolute path to an image file">
		<cfargument name="width" type="string" required="false" default="" hint="width of the resized image">
		<cfargument name="height" type="string" required="false" default="" hint="height of the resized image">
		<cfargument name="Placeholder" type="string" required="false" default="" hint="an alternative image to display if the specified image is not found">
		<cfargument name="MaintainAspectRatio" type="boolean" required="false" default="true" hint="when true width and height arguments are treated as maximums">
		<cfset var fso = CreateObject("java","java.io.File")>
		<cfset var img = "">
		<cfset var mask = "">
		<cfset var thumb = "">
		<cfset var scale = 0>
		<cfset var st = structNew()>
		
		<cfif not len(trim(arguments.source))>
			<cfset arguments.source = arguments.placeholder />
			<cfset arguments.placeholder = "" />
		</cfif>
		
		<!--- if the component doesn't support the format, return the original image --->
		<cfif not this.supportsFormat(getPath(arguments.source))>
			<cfreturn getURL(arguments.source)>
		</cfif>
		
		<cfset mask = getPropertyMask(argumentcollection=arguments)>
		<cfset img = readImage(source,placeholder)>
		
		<!--- if the file can't be read, return the original url --->
		<cfif isSimpleValue(img)><cfreturn getURL(img)></cfif>
		
		<!--- if the mask is found in the img structure, the stored value is the cached image path --->
		<cfif structKeyExists(img,mask)>
			<cfreturn img[mask]>
		</cfif>
		
		<cfset scale = getDimensions(img.image,width,height,MaintainAspectRatio)>
		<cfif scale.width eq img.image.width and scale.height eq img.image.height>
			<!--- asked for the original image size -- return the original --->
			<cfset img[mask] = getURL(img.image.source)>
			<cfreturn img[mask]>
		</cfif>
		
		<cfset thumb = getCacheDirectory(img.image.source)>
		<cfset fso.init(thumb).mkdirs()>
		<cfif not fileExists(fso.getCanonicalPath() & "/source.cfm")>
			<!--- this file stubs the image source for later cleanup operations --->
			<cffile action="write" file="#fso.getCanonicalPath()#/source.cfm" output="#img.image.source#">
		</cfif>
		
		<cfset thumb = thumb & "/" & getCacheFileName(img.image.source,scale.width,scale.height) />
		<cfif fileExists(thumb) and fso.init(img.image.source).lastModified() lt fso.init(thumb).lastModified()>
			<cfset img[mask] = getURL(thumb)>
			<cfreturn img[mask]>
		</cfif>
		
		<cfset st.source = img.image.source />
		<cfset st.destination = thumb />
		<cfset st.width = scale.width />
		<cfset st.height = scale.height />
		<cfset st.maintainaspect = arguments.maintainaspectratio />
		
		<cfreturn st />
	</cffunction>
	
	<cffunction name="resize" access="private" output="false">
		<cfargument name="source" type="string" required="true">
		<cfargument name="width" type="numeric" required="true">
		<cfargument name="height" type="numeric" required="true">
		<cfargument name="maintainaspect" type="boolean" required="true">
		<cfargument name="destination" type="string" required="true">
		<cfset var fso = CreateObject("java","java.io.File").init(destination) />
		
		<cfif fso.exists()>
			<cfset fso.setWritable(true, false) />
		<cfelse>
			<cfset fso.getParentFile().mkdirs() />
		</cfif>
		<cfset source = ImageRead(source) />
		<cfset ImageResize(source,width,height,this.interpolation,this.blur) />
		<cfset ImageWrite(source,destination,this.jpegquality) />
		<cfset fso.setLastModified(datediff("s","1/1/1970",now())*1000) />
		
		<cfreturn getURL(fso.getCanonicalPath()) />
	</cffunction>
	
	<cffunction name="getCacheDirectory" access="private" output="false" returntype="string">
		<cfargument name="source" type="string" required="true">
		<cfreturn getTap().getPath().getPath(this.cachepath & "/" & hash(arguments.source),"img")>
	</cffunction>
	
	<cffunction name="CleanUp" access="public" output="false">
		<cfargument name="source" type="string" required="true">
		<cfset CreateObject("component","cfc.file").init("",getCacheDirectory(source)).delete()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getCacheFileName" access="private" output="false" returntype="string">
		<cfargument name="source" type="string" required="true">
		<cfargument name="width" type="string" required="true">
		<cfargument name="height" type="string" required="true">
		<cfreturn width & "x" & height & "." & listlast(source,".")>
	</cffunction>
	
	<cffunction name="getPropertyMask" access="private" output="false" returntype="string">
		<cfargument name="width" type="string" required="false" default="">
		<cfargument name="height" type="string" required="false" default="">
		<cfargument name="Placeholder" type="string" required="false" default="">
		<cfargument name="MaintainAspectRatio" type="boolean" required="false" default="#variables.MaintainAspectRatio#">
		<cfset var mask = "w=#width#&h=#height#&ar=#iif(MaintainAspectRatio,1,0)#">
		<cfif len(placeholder)><cfset mask = mask & "&p=#hash(lcase(placeholder))#"></cfif>
		<cfreturn mask>
	</cffunction>
	
	<cffunction name="getFileMan" access="private" output="false">
		<cfreturn variables.fileman>
	</cffunction>
	
	<cffunction name="getMemCache" access="private" output="false">
		<cfargument name="image" type="string" required="true">
		<cfreturn getFileMan().getFileCache(arguments.image,true)>
	</cffunction>
	
	<cffunction name="setMemCache" access="private" output="false">
		<cfargument name="image" required="true">
		<cfset getFileMan().setFileCache(arguments.image.source,"image",arguments.image,true)>
	</cffunction>
	
	<cffunction name="readImage" access="private" output="false">
		<cfargument name="source" type="string" required="true">
		<cfargument name="placeholder" type="string" required="false" default="">
		<cfset var img = "">
		<cfset var cache = StructNew() />
		
		<cfset source = getPath(source)>
		<cfif not fileExists(source) and len(placeholder)>
			<cfset placeholder = getPath(placeholder)>
			<cfif FileExists(placeholder)>
				<cfset source = placeholder>
				<cfset placeholder = "">
			</cfif>
		</cfif>
		
		<cfset img = getMemCache(source)>
		<cfif structKeyExists(img,"image")>
			<cfreturn img>
		</cfif>
		
		<!--- read the file and resize it for display --->
		<cftry>
			<cfset img = ImageRead(source)>
			<!--- the source file doesn't exist or can't be read - read the placeholder --->
			<cfcatch>
				<cftry>
					<cfif len(placeholder) and FileExists(placeholder)>
						<cfreturn readImage(placeholder)>
					<cfelse>
						<cfreturn source>
					</cfif>
					<cfcatch><cfreturn source></cfcatch>
				</cftry>
			</cfcatch>
		</cftry>
		
		<cfset setMemCache(img) />
		<cfset cache.image = img />
		<cfreturn cache />
	</cffunction>
	
	<cffunction name="getScaling" access="private" output="false" returntype="numeric">
		<cfargument name="size" type="numeric" required="true">
		<cfargument name="scaleto" type="string" required="true">
		<cfif find("%",scaleto)>
			<cfreturn val(scaleto)/100>
		<cfelseif not len(scaleto) or val(scaleto) lt 1>
			<cfreturn 0>
		<cfelse>
			<cfreturn val(scaleto) / size>
		</cfif>
	</cffunction>
	
	<cffunction name="getDimensions" access="private" output="false">
		<cfargument name="img" required="true">
		<cfargument name="width" type="string" required="true">
		<cfargument name="height" type="string" required="true">
		<cfargument name="MaintainAspectRatio" type="boolean" required="false" default="#variables.MaintainAspectRatio#">
		<!--- get ratios using iif to prevent divide by zero --->
		<cfset var xratio = getScaling(img.width,width)>
		<cfset var yratio = getScaling(img.height,height)>
		<cfset var temp = 0>
		
		<cfif not len(arguments.height) and not len(arguments.width)>
			<cfset temp = { width=img.width, height=img.height }>
			<cfreturn temp>
		</cfif>
		
		<cfif not len(arguments.height)><cfset yratio = xratio></cfif>
		<cfif not len(arguments.width)><cfset xratio = yratio></cfif>
		
		<cfif arguments.MaintainAspectRatio>
			<cfset xratio = min(xratio,yratio)>
			<cfset yratio = xratio>
		</cfif>
		
		<!--- don't make the image any bigger --->
		<cfset xratio = min(1,xratio)>
		<cfset yratio = min(1,yratio)>
		
		<cfset xratio = round(img.width * xratio)>
		<cfset yratio = round(img.height * yratio)>
		<cfset temp = { width=xratio, height=yratio }>
		<cfreturn temp>
	</cffunction>
	
	<cffunction name="getURL" access="private" output="false" returntype="string">
		<cfargument name="path" type="string" required="true">
		<cfif left(path,7) is "http://"><cfreturn path></cfif>
		<cfreturn getTap().getPath().getURL(path)>
	</cffunction>
	
	<cffunction name="getPath" access="private" output="false" returntype="string">
		<cfargument name="src" type="string" required="true">
		<cfif left(src,7) is not "http://"><cfreturn src></cfif>
		<cfreturn getTap().getHREF().getPath(src)>
	</cffunction>
	
	<cffunction name="batch" access="public" output="false" returntype="array" hint="batch processes an array of image thumbnails asynchronously to reduce wait time">
		<cfargument name="source" type="array" required="true" hint="absolute path to an image file">
		<cfargument name="width" type="string" required="false" default="" hint="width of the resized image">
		<cfargument name="height" type="string" required="false" default="" hint="height of the resized image">
		<cfargument name="Placeholder" type="string" required="false" default="" hint="an alternative image to display if the specified image is not found">
		<cfargument name="MaintainAspectRatio" type="boolean" required="false" default="true" hint="when true width and height arguments are treated as maximums">
		<cfset var i = 0 />
		<cfset var th = ArrayNew(1) />
		
		<cfloop index="i" from="1" to="#ArrayLen(source)#">
			<cfset source[i] = getSizedImageCache(
														source=source[i],
														width=width,
														height=height,
														placeholder=placeholder,
														maintainaspectratio=maintainaspectratio) />
			
			<cfif isStruct(source[i])>
				<cfset arrayPrepend(th,"th_" & hash(source[i].source) & "_" & numberformat(randrange(1,999999),000000)) />
				
				<cfthread action="run" name="#th[1]#" priority="#this.threadpriority#" 
				source="#source[i]#" width="#width#" height="#height#" 
				placeholder="#placeholder#" image="#source[i]#">
					<cfset thread.src = resize(argumentcollection=image) />
				</cfthread>
			</cfif>
		</cfloop>
		
		<cfif arrayLen(th)>
			<cfthread action="join" name="#arraytolist(th)#" />
			<cfloop index="i" from="#arraylen(th)#" to="1" step="-1">
				<cfif cfthread[th[i]].status is "completed">
					<cfset source[i] = cfthread[th[i]].src>
				<cfelse>
					<cfset arrayDeleteAt(source,i)>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn source />
	</cffunction>
</cfcomponent>

