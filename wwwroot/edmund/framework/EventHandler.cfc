<cfcomponent hint="I am the primary event handler." output="false">

	<cfset variables.registry = structNew() />
	
	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the event handler constructor.">
		<cfargument name="maximumEventDepth" type="numeric" required="true"
					hint="I am the new maximum event nesting depth." />
		<cfargument name="ignoreAsync" type="numeric" required="true"
					hint="I indicate whether async mode should fallback to sync mode on servers that do not support it." />

		<cfset variables.maximumEventDepth = arguments.maximumEventDepth />
		<cfset variables.ignoreAsync = arguments.ignoreAsync />
		<cfset setUpThreadingModel() />

		<cfreturn this />
			
	</cffunction>
	
	<cffunction name="addListener" returntype="void" access="public" output="false" 
				hint="I add a listener for the specified event.">
		<cfargument name="eventName" type="string" required="true" 
					hint="I am the event to listen for." />
		<cfargument name="listener" type="any" required="true" 
					hint="I am the listener object." />
		<cfargument name="method" type="string" default="handleEvent" 
					hint="I am the method to call on the listener when the event occurs." />
		<cfargument name="async" type="boolean" default="false"
					hint="I specify whether the listener should be invoked asynchronously." />

		<cfset var tuple = structNew() />
		
		<cfset tuple.listener = arguments.listener />
		<cfset tuple.method = arguments.method />
		<cfset tuple.async = arguments.async />
		
		<cfif arguments.async and threadingIsNotSupported()>
			<cfif variables.ignoreAsync>
				<cfset tuple.async = false />
			<cfelse>
				<cfthrow type="edmund.asyncNotSupported" 
						message="Asynchronous listeners are not supported on this server" 
						detail="This server does not support the necessary threading model to allow asynchronous listeners." />
			</cfif>
		</cfif>
		
		<cflock name="#application.ApplicationName#_edmund_eventhandler_addListener_#arguments.eventName#" type="exclusive" timeout="10">
			<cfif not structKeyExists(variables.registry,arguments.eventName)>
				<cfset variables.registry[arguments.eventName] = arrayNew(1) />
			</cfif>
			<cfset arrayAppend(variables.registry[arguments.eventName],tuple) />
		</cflock>

	</cffunction>
	
	<cffunction name="handleEvent" returntype="void" access="public" output="false" 
				hint="I handle an event by invoking any registered listeners.">
		<cfargument name="event" type="edmund.framework.Event" required="true" 
					hint="I am the event to be handled." />

		<cfset var i = 0 />
		<cfset var n = 0 />
		<cfset var name = arguments.event.getName() />
		<cfset var handler = 0 />
		
		<cfif structKeyExists(variables.registry,name)>

			<cfparam name="request.__edmund_event_handling" default="#structNew()#" />
			<cfif structKeyExists(request.__edmund_event_handling,name) and
					request.__edmund_event_handling[name]>
				<cfthrow type="edmund.recursiveEvent" 
						message="Event dispatched recursively" 
						detail="An attempt was made to dispatch the '#name#' event while an active handler for that event was already in progress." />
			<cfelse>
				<cfset request.__edmund_event_handling[name] = true />
			</cfif>
			
			<cftry>

				<cfset n = arrayLen(variables.registry[name]) />
				<cfloop index="i" from="1" to="#n#">
					<cfset handler = variables.registry[name][i] />
					<cfif handler.async>
						<cfset variables.threadingModel.asyncInvoke(handler.listener,handler.method,arguments.event) />
					<cfelse>
						<cfinvoke component="#handler.listener#" method="#handler.method#">
							<cfinvokeargument name="event" value="#arguments.event#" />
						</cfinvoke>
					</cfif>
				</cfloop>

			<cfcatch type="any">
				<cfset request.__edmund_event_handling[name] = false />
				<cfrethrow />
			</cfcatch>
			
			</cftry>

			<cfset request.__edmund_event_handling[name] = false />
			
		</cfif>

	</cffunction>
	
	<cffunction name="setUpThreadingModel" returntype="void" access="private" output="false" 
				hint="I determine whether threading is supported and how it is supported.">

		<cfset variables.serverSupportsThreading = false />
		
		<cfif server.ColdFusion.ProductName is "coldfusion server">
			<cfif listFirst(server.ColdFusion.ProductVersion) gte 8>
				<cfset variables.serverSupportsThreading = true />
				<cfset variables.threadingModel = createObject("component","edmund.framework.coldfusion.Threading").init(this) />
			</cfif>
		<cfelseif server.ColdFusion.ProductName is "bluedragon">
			<cfif listFirst(server.ColdFusion.ProductVersion) gte 7>
				<cfset variables.serverSupportsThreading = true />
				<cfset variables.threadingModel = createObject("component","edmund.framework.bluedragon.Threading").init(this) />
			</cfif>
		</cfif>
		
	</cffunction>
	
	<cffunction name="threadingIsNotSupported" returntype="boolean" access="private" output="false" 
				hint="I return true iff threading is not supported!">

		<cfreturn not variables.serverSupportsThreading />

	</cffunction>

</cfcomponent>