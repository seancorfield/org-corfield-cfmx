<cfcomponent hint="I am the ColdFusion 8+ threading model" output="false">
	
	<cffunction name="init" returntype="any" access="public" output="false">
		<cfargument name="eventHandler" type="any" required="true" 
					hint="I am the Edmund event handler." />
		
		<cfset variables.eventHandler = arguments.eventHandler />
		<cfset variables.javaThread = createObject("java","java.lang.Thread") />

		<cfreturn this />
			
	</cffunction>
	
	<cffunction name="asyncInvoke" returntype="void" access="public" output="false" 
				hint="I perform an asynchronous invocation of a listener.">
		<cfargument name="object" type="any" required="true" 
					hint="I am the object to handle the event." />
		<cfargument name="method" type="string" required="true" 
					hint="I am the method to handle the event." />
		<cfargument name="event" type="edmund.framework.Event" required="true" 
					hint="I am the event to be handled." />

		<!--- if we're inside a cfthread, run synchronously --->
		<cfif variables.javaThread.currentThread().getThreadGroup().getName() eq "cfthread">

			<cfinvoke component="#arguments.object#" method="#arguments.method#">
				<cfinvokeargument name="event" value="#arguments.event#" />
			</cfinvoke>

		<cfelse>

			<cfparam name="request.__edmund_thread_id" default="0" />
			<cfset request.__edmund_thread_id = request.__edmund_thread_id + 1 />

			<!--- thread name is required and must be unique per thread --->
			<cfthread action="run" name="edmund_thread_#request.__edmund_thread_id#"
						object="#arguments.object#" method="#arguments.method#" event="#arguments.event#">
	
				<cfinvoke component="#attributes.object#" method="#attributes.method#">
					<cfinvokeargument name="event" value="#attributes.event#" />
				</cfinvoke>

			</cfthread>

		</cfif>

	</cffunction>

</cfcomponent>