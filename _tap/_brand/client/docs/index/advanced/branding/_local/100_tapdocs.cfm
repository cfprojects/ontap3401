<!--- this shows how nested application code for branded sites 
is inclusive of default application code for the same sites 
use cfset to overwrite core variables or cfparam to allow 
core variables to be kept when they exist --->

<cfset request.currentlybrandedas = getTap().getPath().brand>
<cfparam name="request.sometimesbrandedas" type="string" default="#getTap().getPath().brand#">
<cfset request.linkbrand = request.sometimesbrandedas>
