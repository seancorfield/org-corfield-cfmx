<!--- example showing how application events can be tied into listeners --->
<cfcomponent output="false">
	
	<cfset this.name = "edmund_sample_using_application_events" />
	<cfset this.sessionmanagement = true />
	<cfset this.sessiontimeout = createTimeSpan(0,0,1,0) />
	<cfset this.applicationtimeout = createTimeSpan(0,0,2,0) />

	<cffunction name="onApplicationStart">
		
		<!--- create a handler: it can be local, Edmund keeps a reference to it once it is registered --->
		<cfset var logger = createObject("component","logger").init() />

		<!--- create edmund system: ignoreAsync if server does not support it --->
		<cfset application.edmund = createObject("component","edmund.Edmund").init(ignoreAsync=true) />
		
		<cfset application.edmund.register("onApplicationStart",logger,"handleEvent",true) />
		<cfset application.edmund.register("onSessionStart",logger) />
		<cfset application.edmund.register("onRequestStart",logger,"handleEvent",true) />
		<cfset application.edmund.register("onRequestEnd",logger) />
		<cfset application.edmund.register("onSessionEnd",logger,"handleEvent",true) />
		<cfset application.edmund.register("onApplicationEnd",logger) />
		<cfset application.edmund.register("onError",logger) />
		
		<!--- fire the onApplicationStart event --->
		<cfset application.edmund.onApplicationStart() />
		
	</cffunction>

	<cffunction name="onSessionStart">
		
		<cfset application.edmund.onSessionStart() />
		
	</cffunction>

	<cffunction name="onRequestStart">
		<cfargument name="targetPage" type="string" required="false" />
		
		<cfif structKeyExists(URL,"reload") and URL.reload>
			<cfset onApplicationStart() />
		</cfif>
					
		<cfset application.edmund.onRequestStart(arguments.targetPage) />
		
	</cffunction>

	<cffunction name="onRequestEnd">
		<cfargument name="targetPage" type="string" required="false" />
					
		<cfset application.edmund.onRequestEnd(arguments.targetPage) />
		
	</cffunction>

	<cffunction name="onSessionEnd">
		<cfargument name="sessionScope" required="false" />
		<cfargument name="applicationScope" required="false" />

		<!--- in case an exception occurs - we can't reference application scope in onError at this point --->		
		<cfset variables.edmund = arguments.applicationScope.edmund />
		<cfset arguments.applicationScope.edmund.onSessionEnd(arguments.sessionScope,arguments.applicationScope) />
		
	</cffunction>

	<cffunction name="onApplicationEnd">
		<cfargument name="applicationScope" required="false" />
					
		<!--- in case an exception occurs - we can't reference application scope in onError at this point --->		
		<cfset variables.edmund = arguments.applicationScope.edmund />
		<cfset arguments.applicationScope.edmund.onApplicationEnd(arguments.applicationScope) />
		
	</cffunction>

	<cffunction name="onError">
		<cfargument name="exception" required="false" />
		<cfargument name="eventName" type="string" required="false" />
						
		<!--- if an exception occurred during onSessionEnd or onApplicationEnd, edmund is in variables scope --->
		<cfif structKeyExists(variables,"edmund")>
			<cfset variables.edmund.onError(arguments.exception,arguments.eventName) />
		<cfelse>
			<cfset application.edmund.onError(arguments.exception,arguments.eventName) />
		</cfif>
		
	</cffunction>

</cfcomponent>