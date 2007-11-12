<cfcomponent hint="I am the main entry point for the framework." output="false">

	<cffunction name="init" returntype="any" access="public" output="false" hint="I am the framework constructor.">
		<cfargument name="maximumEventDepth" type="numeric" default="10"
					hint="I am the maximum event nesting depth." />
		<cfargument name="ignoreAsync" type="boolean" default="false"
					hint="I indicate whether async mode should fallback to sync mode on servers that do not support it." />
		
		<cfset variables.handler = createObject("component","edmund.framework.EventHandler").init(arguments.maximumEventDepth,arguments.ignoreAsync) />
		
		<cfreturn this />
			
	</cffunction>
	
	<cffunction name="new" returntype="any" access="public" output="false" 
				hint="I return a new event.">
		<cfargument name="name" type="string" required="true" 
					hint="I am the name of the new event." />
					
		<cfset var eventName = arguments.name />

		<cfreturn createObject("component","edmund.framework.Event").init(eventName) />

	</cffunction>
	
	<cffunction name="register" returntype="void" access="public" output="false" 
				hint="I register a new event handler.">
		<cfargument name="eventName" type="string" required="true" 
					hint="I am the event to listen for." />
		<cfargument name="listener" type="any" required="true" 
					hint="I am the listener object." />
		<cfargument name="method" type="string" default="handleEvent" 
					hint="I am the method to call on the listener when the event occurs." />
		<cfargument name="async" type="boolean" default="false"
					hint="I specify whether the listener should be invoked asynchronously." />

		<cfset variables.handler.addListener(argumentCollection=arguments) />
		
	</cffunction>
	
	<cffunction name="dispatchEvent" returntype="void" access="public" output="false" 
				hint="I dispatch an event.">
		<cfargument name="event" type="edmund.framework.Event" required="true" 
					hint="I am the event to be handled." />

		<cfset variables.handler.handleEvent(arguments.event) />

	</cffunction>
	
	<!--- hooks for Application.cfc usage --->
	<cffunction name="onApplicationStart"
				hint="I can be called at the end of onApplicationStart, once all the listeners are registered.">
		
		<cfset dispatchEvent( new("onApplicationStart") ) />
		
	</cffunction>

	<cffunction name="onSessionStart"
				hint="I can be called from onSessionStart.">
		
		<cfset dispatchEvent( new("onSessionStart") ) />
		
	</cffunction>

	<cffunction name="onRequestStart"
				hint="I can be called from onRequestStart.">
		<cfargument name="targetPage" type="string" required="false" 
					hint="I am the targetPage (argument to Application.onRequestStart)." />
					
		<cfset dispatchEvent( new("onRequestStart").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<cffunction name="onRequestEnd"
				hint="I can be called from onRequestEnd.">
		<cfargument name="targetPage" type="string" required="false" 
					hint="I am the targetPage (argument to Application.onRequestEnd)." />
					
		<cfset dispatchEvent( new("onRequestEnd").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<cffunction name="onSessionEnd"
				hint="I can be called from onSessionEnd.">
		<cfargument name="sessionScope" required="false" 
					hint="I am the sessionScope (argument to Application.onSessionEnd)." />
		<cfargument name="applicationScope" required="false" 
					hint="I am the applicationScope (argument to Application.onSessionEnd)." />
					
		<cfset dispatchEvent( new("onSessionEnd").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<cffunction name="onApplicationEnd"
				hint="I can be called from onApplicationEnd.">
		<cfargument name="applicationScope" required="false" 
					hint="I am the applicationScope (argument to Application.onApplicationEnd)." />
					
		<cfset dispatchEvent( new("onApplicationEnd").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<cffunction name="onError"
				hint="I can be called from onError.">
		<cfargument name="exception" required="false" 
					hint="I am the exception (argument to Application.onError)." />
		<cfargument name="eventName" type="string" required="false" 
					hint="I am the eventName (argument to Application.onError)." />
					
		<cfset dispatchEvent( new("onError").values(argumentCollection=arguments) ) />
		
	</cffunction>

</cfcomponent>