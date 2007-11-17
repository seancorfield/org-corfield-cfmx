<cfcomponent output="false">
	
	<cffunction name="init" returntype="any" access="public" output="false">
		
		<cfreturn this />
			
	</cffunction>
	
	<cffunction name="handleEvent" returntype="void" access="public" output="false" 
				hint="I handle an event - I just log the information.">
		<cfargument name="event" type="any" required="true" 
					hint="I am the event to be handled." />

		<cfset var i = 0 />
		<cfset var values = arguments.event.getAllValues() />
		
		<cflog application="true" text="logger.handleEvent(#arguments.event.getName()#)" type="information" log="application" />
		<cfloop item="i" collection="#values#">
			<cfif isSimpleValue(values[i])>
				<cflog application="true" text="logger.handleEvent() - #i# = #values[i]#" type="information" log="application" />
			<cfelse>
				<cflog application="true" text="logger.handleEvent() - #i# = #values[i].toString()#" type="information" log="application" />
			</cfif>
		</cfloop>

	</cffunction>

</cfcomponent>