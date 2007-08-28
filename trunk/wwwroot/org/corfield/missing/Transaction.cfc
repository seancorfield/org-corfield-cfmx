<cfcomponent output="false">

	<cffunction name="init" returntype="any" access="public" output="false">
		<cfargument name="obj" type="any" required="true" />
		<cfargument name="suffix" type="string" default="WithTransaction" />
		
		<cfset variables.obj = arguments.obj />
		<cfset variables.suffix = arguments.suffix />
		<cfset variables.suffixLength = len(variables.suffix) />
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="onMissingMethod">
		<cfargument name="missingMethodName" />
		<cfargument name="missingMethodArguments" />
		
		<cfset var result = 0 />

		<cfif len(arguments.missingMethodName) gt variables.suffixLength and
				right(arguments.missingMethodName,variables.suffixLength) is variables.suffix>
			<cftransaction>
				<cfoutput>---Begin Transaction<br /></cfoutput>
				<cfset result = variables.obj.call(
						left(arguments.missingMethodName,len(arguments.missingMethodName)-variables.suffixLength),
						arguments.missingMethodArguments) />
				<cfoutput>---End Transaction<br /></cfoutput>
			</cftransaction>
		<cfelse>
			<cfset result = variables.obj.call(arguments.missingMethodName,arguments.missingMethodArguments) />
		</cfif>
		
		<cfif isDefined("result")>
			<cfreturn result />
		</cfif>
	
	</cffunction>

</cfcomponent>