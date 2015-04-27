<cfset variables.tap.layout = "local">

<!--- include local stage code in nested subdirectories --->
<cfloop index="cfmod" list="#arraytolist(getFS().processTemplates(variables.tap.nest,variables.tap.layout))#">
<cfinclude template="#cfmod#"></cfloop>
