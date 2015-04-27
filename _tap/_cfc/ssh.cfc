<cfcomponent output="false" displayname="SSH" extends="ftp" 
hint="provides a secure-ftp wrapper for the cfftp tag enhanced with framework file tools">
	<cfproperty name="fingerprint" type="string" hint="matches the fingerprint attribute of the cfftp tag">
	<cfproperty name="key" type="string" default="" hint="matches the key attribute of the cfftp tag">
	<cfproperty name="passphrase" type="string" default="" hint="matches the passphrase attribute of the cfftp tag">

	<cffunction name="init" access="public" output="false" 
	hint="sets the path information for an individual file or directory">
		<cfargument name="server" type="string" required="true" hint="url to the ftp server">
		<cfargument name="fingerprint" type="string" required="true" hint="used for ssh encryption">
		<cfargument name="passphrase" type="string" required="false" default="" hint="used for asymetric ssh encryption">
		<cfargument name="usr" type="string" required="false" default="" hint="the username used to connect to the ftp server">
		<cfargument name="pwd" type="string" required="false" default="" hint="the password used to connect to the ftp server - use this property for the key attribute with asymetric encryption">
		<cfargument name="wait" type="numeric" required="false" default="#this.getValue('timeout')#" hint="time in seconds to wait for the ftp server response">
		<cfargument name="port" type="string" required="false" default="#this.getValue('port')#" hint="the port on which the ftp server listens for requests">
		<cfargument name="proxyServer" type="string" required="false" default="#this.getValue('proxyServer')#" hint="the name of a proxy server to use if applicable">
		
		<cfset setProperties(arguments)>
		
		<cfreturn this>
	</cffunction>

	<cffunction name="open" access="public" output="false" hint="opens the named connection to the ftp server">
		<cfargument name="wait" type="numeric" default="#this.getValue('timeout')#" hint="time to wait for the ssh server to respond to the request">
		<cfargument name="retryCount" type="numeric" default="#this.getValue('retryCount')#" hint="number of times to attempt the connection">
		<cfargument name="passive" type="boolean" default="#this.getValue('passive')#" hint="use passive mode when connecting">
		
		<cfset var cfftp = structNew()>
		
		<cfif not variables.isOpen>
			<cfset cfftp.server = this.getValue("server")>
			<cfset cfftp.username = this.getValue("usr")>
			<cfset cfftp.timeout = arguments.wait>
			<cfset cfftp.port = this.getValue("port")>
			<cfset cfftp.connection = connection()>
			<cfset cfftp.proxyserver = this.getValue("proxyserver")>
			<cfset cfftp.retrycount = arguments.retrycount>
			<cfset cfftp.stoponerror = stopOnError()>
			<cfset cfftp.passive = arguments.passive>
			<cfset cfftp.fingerprint = getValue("fingerprint")>
			<cfset cfftp.passphrase = getValue("passphrase")>
			<cfset cfftp[iif(len(cfftp.passphrase),de("key"),de("password"))] = getValue("pwd")>
			
			<cfftp attributecollection="#cfftp#">
			
			<cfset variables.isOpen = iif(cfftp.Succeeded and cfftp.ErrorCode eq 230,true,false)>
			<cfset broadcast("open",cfftp)><cfif variables.isOpen>
			<cfset this.changeDir(this.getValue("remote"))></cfif>
		</cfif>
		
		<cfreturn this>
	</cffunction>	
</cfcomponent>
