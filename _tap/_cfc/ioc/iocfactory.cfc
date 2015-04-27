<cfcomponent displayname="IoC.IoCFactory" output="false" extends="cfc.ontap" 
hint="I'm a generic IoC factory with simple autowiring">
	<cfset variables.bean = structNew() />
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="storage" type="any" required="false" default="" />
		<cfargument name="cascade" type="string" required="false" default="" />
		<cfargument name="package" type="string" required="false" default="" />
		
		<cfif isSimpleValue(arguments.storage)>
			<cfif not len(trim(arguments.storage))>
				<cfset arguments.storage = "cfc.simplestorage" />
			</cfif>
			<cfset arguments.storage = CreateObject("component",arguments.storage).init() />
		</cfif>
		
		<cfset setProperties(arguments) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="define" access="public" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfargument name="beanClass" type="string" required="false" default="#beanName#" />
		<cfargument name="autoinit" type="boolean" required="false" default="true" />
		<cfargument name="transient" type="boolean" required="false" default="false" />
		<cfargument name="initArgs" type="struct" required="false" default="#structNew()#" />
		<cfset var args = structNew() />
		<cfset structAppend(args, arguments, true) />
		<cfset variables.bean[beanName] = args />
	</cffunction>
	
	<cffunction name="hasDefinition" access="private" output="false" returntype="boolean">
		<cfargument name="beanName" type="string" required="true" />
		<cfreturn structKeyExists(variables.bean,arguments.beanName) />
	</cffunction>
	
	<cffunction name="containsBean" access="public" output="false" returntype="boolean">
		<cfargument name="beanName" type="string" required="true" />
		<cfif hasDefinition(beanName) or cfcExists(beanName)>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="isBeanDefined" access="private" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfreturn structKeyExists(bean,beanName) />
	</cffunction>
	
	<cffunction name="getCachedBean" access="private" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfset var obj = 0 />
		
		<cfif structKeyExists(variables,"getCached_" & beanName)>
			<cfinvoke method="getCached_#beanName#" returnvariable="obj" />
		<cfelse>
			<cfset obj = getProperty("storage").fetch(beanName) />
			<cfset obj = iif(obj.status,de(""),"obj.content") />
		</cfif>
		
		<cfreturn obj />
	</cffunction>
	
	<cffunction name="cacheBean" access="private" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfargument name="bean" type="any" required="true" />
		<cfset var cache = 0 />
		
		<cfif structKeyExists(variables,"cache_" & beanName)>
			<cfinvoke method="cache_#beanName#" bean="#arguments.bean#" />
		<cfelse>
			<cfset cache = getProperty("storage") />
			<cfset arguments.bean = cache.store(beanName,bean).content />
		</cfif>
		
		<cfreturn arguments.bean />
	</cffunction>
	
	<cffunction name="getBean" access="public" output="false" returntype="any">
		<cfargument name="beanName" type="string" required="true" />
		<cfset var obj = getCachedBean(arguments.beanName) />
		<cfset var package = 0 />
		<cfset var def = 0 />
		
		<cfif not isObject(obj)>
			<cfset package = getProperty("package") />
			<cfif structKeyExists(variables,"create_" & beanName)>
				<cfinvoke method="create_#beanName#" returnvariable="obj" />
			<cfelseif structKeyExists(bean,beanName)>
				<cfset def = bean[beanName] />
				<cfset obj = createBean(argumentCollection=def) />
				<cfif def.transient>
					<!--- don't cache the bean if it's transient --->
					<cfreturn obj />
				</cfif>
			<cfelseif cfcExists(package & beanName)>
				<cfset obj = createBean(beanClass=package & beanName,autoinit=true) />
			<cfelse>
				<cfset def = canGetBeanFrom(beanName)>
				<cfif len(def)>
					<cfreturn getIoC().getBean(beanName,def) />
				<cfelse>
					<cfset raiseMissingBeanException(beanName) />
				</cfif>
			</cfif>
			<cfset obj = cacheBean(beanName,obj) />
		</cfif>
		
		<cfreturn obj />
	</cffunction>
	
	<cffunction name="raiseMissingBeanException" access="private" output="false">
		<cfargument name="beanname" type="string" required="true" />
		<cfthrow type="onTap.IoC.MissingBean" message="onTap: Unable to locate bean." detail="#beanname#" />
	</cffunction>
	
	<cffunction name="cfcExists" access="private" output="false" returntype="boolean">
		<cfargument name="className" type="string" required="true" />
		<cfreturn getLib().cfcExists(arguments.className) />
	</cffunction>
	
	<cffunction name="createBean" access="private" output="false" returntype="any">
		<cfargument name="beanClass" type="string" required="true" />
		<cfargument name="autoinit" type="boolean" required="false" default="false" />
		<cfargument name="transient" type="boolean" required="false" default="false" />
		<cfargument name="initargs" type="struct" required="false" default="#structNew()#" />
		<cfset var obj = CreateObject("component",beanClass) />
		
		<cfif autoinit>
			<cfset constructBean(obj,initargs) />
		<cfelse>
			<cfset obj.init(argumentCollection=initargs) />
		</cfif>
		
		<cfreturn obj />
	</cffunction>
	
	<cffunction name="canGetBeanFrom" access="private" output="false" 
	hint="indicates alternate IoC containers that can supply the requested bean for autoinit">
		<cfargument name="beanName" type="string" required="true" />
		<cfset var cascade = getValue("cascade") />
		<cfif not len(trim(cascade))><cfreturn "" /></cfif>
		<cfreturn getIoC().findBean(beanName,cascade) />
	</cffunction>
	
	<cffunction name="getInitArguments" access="private" output="false" returntype="array">
		<cfargument name="bean" type="any" required="true" />
		<cfreturn duplicate(getMetaData(bean.init).parameters) />
	</cffunction>
	
	<cffunction name="constructBean" access="private" output="false" returntype="any">
		<cfargument name="bean" type="any" required="true" />
		<cfargument name="initargs" type="struct" required="false" default="#structNew()#" />
		<cfset var arg = getInitArguments(bean) />
		<cfset var ioc = getIoC() /><!--- ioc manager --->
		<cfset var container = this />
		<cfset var obj = 0 />
		<cfset var x = 0 />
		
		<cfloop index="x" from="1" to="#ArrayLen(arg)#">
			<cfif not structKeyExists(initargs,arg[x].name)>
				<cfif not structKeyExists(arg[x],"default") and structKeyExists(arg[x],"required") and arg[x].required>
					<cfif not structKeyExists(arg[x],"type") or arg[x].type is "any" or 
					not listfindnocase("string,numeric,date,boolean,struct,array,query,binary,xml,xmlelem,xmldoc",arg[x].type)>
						<!--- if the bean isn't explicitly defined in the current container, 
						then get it (cached?) from another container if it's available 
						to prevent duplication of singletons across multiple containers --->
						<cfset obj = "" />
						<cfif this.containsBean(arg[x].name)>
							<cfset obj = getBean(arg[x].name) />
						<cfelse>
							<cfset obj = canGetBeanFrom(arg[x].name) />
							<cfif len(trim(obj))>
								<cfset obj = IoC.getBean(arg[x].name,obj) />
							</cfif>
						</cfif>
						
						<cfif isObject(obj)>
							<cfset initargs[arg[x].name] = obj />
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfset bean.init(argumentCollection=initargs) />
		<cfreturn bean />
	</cffunction>
	
	<cffunction name="detach" access="public" output="false" 
	hint="I evict the cache if this factory is detached from the IoC Manager">
		<cfset getValue("storage").reset() />
	</cffunction>
	
	<cffunction name="getStruct" access="private" output="false">
		<cfreturn arguments />
	</cffunction>
	
	<cffunction name="onMissingMethod" access="public" output="false">
		<cfargument name="missingmethodname" type="string" required="true" />
		<cfargument name="missingmethodarguments" type="struct" required="true" />
		
		<cfif left(missingmethodname,3) is "get" and structisempty(missingmethodarguments)>
			<cfreturn getBean(removechars(missingmethodname,1,3)) />
		<cfelse>
			<cfreturn super.onMissingMethod(argumentcollection=arguments) />
		</cfif>
	</cffunction>
	
	<cffunction name="debug" access="public" output="true" returntype="void" hint="used for debugging objects during active development - should not appear in production code">
		<cfargument name="thing" type="any" required="false" default="#variables.bean#" />
		<cfargument name="abort" type="boolean" required="false" default="true" />
		<cfset super.debug(argumentCollection = arguments) />
	</cffunction>
	
</cfcomponent>
