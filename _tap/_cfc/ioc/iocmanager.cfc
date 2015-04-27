<cfcomponent displayname="IoC.IoCManager" extends="cfc.ontap"
hint="Manages all IoC containers for the framework">
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="defaultContainerName" type="string" required="false" default="" />
		<cfargument name="defaultContainer" type="any" required="false" default="" />
		<cfset reset() />
		
		<cfif len(trim(defaultContainerName))>
			<cfset setValue("defaultContainer",arguments.defaultContainerName) />
			<cfset setDefaultContainer(arguments.defaultContainer) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setDefaultContainer" access="public" output="false">
		<cfargument name="container" type="any" required="false" default="" />
		<cfif not isObject(container)>
			<cfset container = getDefaultIoCContainer() />
		</cfif>
		<cfset addContainer(getValue("defaultContainer"),container) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getAllContainers" access="private" output="false">
		<cfreturn variables.container />
	</cffunction>
	
	<cffunction name="getContainer" access="public" output="false">
		<cfargument name="name" type="string" required="false" default="#getValue('defaultContainer')#" />
		<cfset var st = getAllContainers() />
		<cfreturn st[name] />
	</cffunction>
	
	<cffunction name="listContainers" access="public" output="false" returntype="string"
	hint="returns a comma delimited list of all loaded containers">
		<cfreturn structKeyList(getAllContainers()) />
	</cffunction>
	
	<cffunction name="hasContainer" access="public" output="false">
		<cfargument name="name" type="string" required="false" default="ontap" />
		<cfset var st = getAllContainers() />
		<cfreturn structKeyExists(st,name) />
	</cffunction>
	
	<cffunction name="addContainer" access="public" output="false" 
	hint="adds a pre-loaded IoC container to the manager">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="container" type="any" required="true" />
		<cfset var st = getAllContainers() />
		<cfset container.setValue("iocContainerName",arguments.name) />
		<cfset st[name] = container />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="detach" access="public" output="false" 
	hint="removes a specified IoC container from the manager">
		<cfargument name="name" type="string" required="true" />
		<cfset var container = getAllContainers() />
		
		<cftry>
			<cfif structKeyExists(container,arguments.name)>
				<cfset container = container[arguments.name] />
				<cfset structDelete(getAllContainers(),arguments.name) />
				<!--- resetting the container when we throw it out also allows the factory to clean up cache, etc --->
				<cfset container.reset() />
			</cfif>
			
			<cfcatch>
				<cfset structDelete(getAllContainers(),arguments.name) />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="newContainer" access="public" output="false" 
	hint="returns a new IoC container / adapter to be initialized but pre-added to the manager">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="className" type="string" required="false" default="ioccontainer" />
		<cfset var container = CreateObject("component",className) />
		<cfset addContainer(name,container) />
		<cfreturn container />
	</cffunction>
	
	<cffunction name="getBean" access="public" output="false" hint="returns a bean from a specified container">
		<cfargument name="beanName" type="string" required="true" />
		<cfargument name="container" type="string" required="false" default="#getValue('defaultContainer')#" />
		<cfreturn getContainer(container).getBean(beanName) />
	</cffunction>
	
	<cffunction name="findBean" access="public" output="false" returntype="string" 
	hint="returns the name of a container which has a specified bean from a list of containers - ignores missing containers">
		<cfargument name="beanName" type="string" required="true" hint="the name of the bean you would like to find" />
		<cfargument name="container" type="string" required="false" default="" hint="a comma-delimited list of containers to check - defaults to all containers" />
		<cfset var temp = 0 />
		
		<cfif not len(trim(container))>
			<cfset container = listContainers() />
		</cfif>
		
		<cfloop index="container" list="#container#">
			<cfif this.hasContainer(container)>
				<cftry>
					<cfif this.getContainer(container).containsBean(beanName)>
						<cfreturn container />
					</cfif>
					<cfcatch></cfcatch>
				</cftry>
			</cfif>
		</cfloop>
		
		<cfreturn "" />
	</cffunction>
	
	<cffunction name="containsBean" access="public" output="false" returntype="boolean" 
	hint="tests for the existence of a specified bean within a given list of containers - ignores missing containers">
		<cfargument name="beanName" type="string" required="true" hint="the name of the bean you would like to find" />
		<cfargument name="container" type="string" required="false" default="" hint="a comma delimited list of containers to check - defaults to all containers" />
		<cfreturn iif(len(trim(findBean(beanName,container))),true,false) />
	</cffunction>
	
	<cffunction name="listBeans" access="public" output="false" returntype="string" 
	hint="returns a comma delimited list of the names of containers which have a bean matching a specified bean name, i.e. 'datasource'">
		<cfargument name="beanName" type="string" required="true" />
		<cfset var st = getAllContainers() />
		<cfset var container = "" />
		<cfset var beans = ArrayNew(1) />
		
		<cfloop item="container" collection="#st#">
			<cfif st[container].containsBean(beanName)>
				<cfset ArrayAppend(beans,container) />
			</cfif>
		</cfloop>
		
		<cfreturn ArrayToList(beans) />
	</cffunction>
	
	<cffunction name="resetContainers" access="public" output="false" returntype="string" 
	hint="resets the cache in all IoC containers - used primarily during active development">
		<cfset var cache = getAllContainers() />
		<cfset var container = "" />
		<cfloop item="container" collection="#cache#">
			<cftry>
				<cfset cache[container].reset() />
				<cfcatch><!--- it would be nice to reset them, but it's not absolutely necessary ---></cfcatch>
			</cftry>
		</cfloop>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="reset" access="public" output="false">
		<cfset variables.container = structNew() />
		<cfreturn this />
	</cffunction>
	
</cfcomponent>
