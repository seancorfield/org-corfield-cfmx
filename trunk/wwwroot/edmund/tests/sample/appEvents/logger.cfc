<!--- extends ICommand because we're using it in workflow as well as being just a regular event handler --->
<cfcomponent implements="edmund.framework.workflow.ICommand" output="false">
	
	<cffunction name="init" returntype="any" access="public" output="false">
		<cfargument name="prefix" type="string" required="true" />
		
		<cfset variables.prefix = arguments.prefix />
		
		<cfreturn this />
			
	</cffunction>
	
	<cffunction name="handleEvent" returntype="boolean" access="public" output="false" 
				hint="I handle an event - I just log the information.">
		<cfargument name="event" type="edmund.framework.Event" required="true" 
					hint="I am the event to be handled." />

		<cfset var i = 0 />
		<cfset var values = arguments.event.all() />
		
		<cflog application="true" text="#variables.prefix# : logger.handleEvent(#arguments.event.name()#)" type="information" log="application" />
		<cfloop item="i" collection="#values#">
			<cfif isSimpleValue(values[i])>
				<cflog application="true" text="#variables.prefix# : logger.handleEvent() - #i# = #values[i]#" type="information" log="application" />
			<cfelse>
				<cflog application="true" text="#variables.prefix# : logger.handleEvent() - #i# = #values[i].toString()#" type="information" log="application" />
			</cfif>
		</cfloop>
		
		<cfreturn true />

	</cffunction>

</cfcomponent>