<cfcomponent output="false">
	
	<cffunction name="init" returntype="any" access="public" output="false">
		
		<cfreturn this />
			
	</cffunction>
	
	<cffunction name="handleEvent" returntype="void" access="public" output="false" 
				hint="I handle an event - I just log the information.">
		<cfargument name="event" type="any" required="true" 
					hint="I am the event to be handled." />

		<cflog application="true" text="logger.handleEvent(#arguments.event.getName()#)" type="information" log="application" />

	</cffunction>

</cfcomponent>