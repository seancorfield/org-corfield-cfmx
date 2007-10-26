<cfcomponent hint="I am the BlueDragon 7+ threading model" output="false">
	
	<cffunction name="init" returntype="any" access="public" output="false">
		<cfargument name="eventHandler" type="any" required="true" 
					hint="I am the Edmund event handler." />
		
		<cfset variables.eventHandler = arguments.eventHandler />

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

		<!--- BlueDragon allows nested threads and automatically names threads --->
		<cfthread object="#arguments.object#" method="#arguments.method#" event="#arguments.event#">

			<cfinvoke component="#attributes.object#" method="#attributes.method#">
				<cfinvokeargument name="event" value="#attributes.event#" />
			</cfinvoke>

		</cfthread>
	
	</cffunction>

</cfcomponent>