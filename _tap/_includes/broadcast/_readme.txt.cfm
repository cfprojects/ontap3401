This directory is for creating broadcast-style 
event notifications in which it may be necessary 
to notify multiple business objects 
of a particular event at the same time

Use an include in this directory when: 
1 - you have more than one business object being referenced together 
		or more than one method of the same busines object called at the same time 
		
		<cfinclude template="needWidgetGateway.cfm" />
		<cfinclude template="needShoppingCart.cfm" />
		<cfset qWidgetList = widgetGateway.getAvailableWidgets() />
		<cfset qWidgetUpsell = shoppingCart.getSimilarWidgets() />
		
2 - Performance of the requested page is a premium 
		- AND/OR - 
		The application is internal and you have no plans to sell it outside your company 
		
If you're planning to sell this application to any third parties, 
you might want to consider using the <cf_process> custom tag 
to call an event in the /broadcast/ area instead. See the 
_readme.txt in /_tap/_includes/broadcast/ 

To broadcast messages using this directory, include these templates 
via the framework's /inc/ mapping like this: 

<cfinclude template="/inc/broadcast/needWidgetList.cfm" />

