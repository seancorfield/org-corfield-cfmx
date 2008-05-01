<cfcomponent hint="I am the logging utility." output="false">
	
	<cffunction name="init" returntype="any" access="public" output="false" hint="I am the constructor.">
		<cfargument name="logging" type="string" default=""
					hint="I indicate if or where to do logging: I can be empty - no logging - or the name of a log file." />

		<cfset variables.target = arguments.logging />
		
		<cfif variables.target is "">
			<cfset variables.logger = variables.nullLogger />
		<cfelseif listFindNoCase("application,scheduler,console",variables.target ) gt 0>
			<cfset variables.logger = variables.cfLogger />
		<cfelse>
			<cfset variables.logger = variables.fileLogger />
		</cfif>
		
		<cfreturn this />
			
	</cffunction>
	
	<cffunction name="error" returntype="void" access="public" output="false" hint="I log an error.">
		<cfargument name="text" type="string" required="true" />
		<cfargument name="application" type="boolean" default="false" />

		<cfset variables.logger(text = arguments.text, application = arguments.application, type = "error") />
		
	</cffunction>

	<cffunction name="info" returntype="void" access="public" output="false" hint="I log an informational message.">
		<cfargument name="text" type="string" required="true" />
		<cfargument name="application" type="boolean" default="false" />

		<cfset variables.logger(text = arguments.text, application = arguments.application, type = "information") />
		
	</cffunction>

	<cffunction name="warn" returntype="void" access="public" output="false" hint="I log a warning.">
		<cfargument name="text" type="string" required="true" />
		<cfargument name="application" type="boolean" default="false" />

		<cfset variables.logger(text = arguments.text, application = arguments.application, type = "warning") />
		
	</cffunction>

	<cffunction name="nullLogger" returntype="void" access="private" output="false" hint="I am a no-op logger.">
	</cffunction>

	<cffunction name="cfLogger" returntype="void" access="private" output="false" hint="I am a CF built-in logger.">
		
		<cflog application="#arguments.application#" log="#variables.target#" text="#arguments.text#" type="#arguments.type#" />
		
	</cffunction>

	<cffunction name="fileLogger" returntype="void" access="private" output="false" hint="I am a file-based logger.">
		
		<cflog application="#arguments.application#" file="#variables.target#" text="Edmund : #arguments.text#" type="#arguments.type#" />
		
	</cffunction>

</cfcomponent>