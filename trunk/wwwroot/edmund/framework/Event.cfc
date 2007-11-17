<cfcomponent output="false" hint="I represent an event.">
	
	<cfset variables.name = "[unnamed event]" />
	<cfset variables.values = structNew() />
	
	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the event constructor.">
		<cfargument name="name" type="string" required="true" 
					hint="I am the name of this event." />
		<cfargument name="values" type="struct" default="#structNew()#" 
					hint="I am the optional initial values for this event." />

		<cfset variables.name = arguments.name />
		<cfset structClear(variables.values) />
		<cfset structAppend(variables.values,arguments.values) />

		<cfreturn this />
			
	</cffunction>
	
	<cffunction name="getName" returntype="string" access="public" output="false">
	
		<cfreturn variables.name />
	
	</cffunction>
	
	<cffunction name="getValue" returntype="any" access="public" output="false" 
				hint="I return the specified event value.">
		<cfargument name="name" type="string" required="true" 
					hint="I am the name of the value to return." />
	
		<cfreturn variables.values[arguments.name] />
	
	</cffunction>
	
	<cffunction name="getAllValues" returntype="struct" access="public" output="false" 
				hint="I return a shallow copy of all the event values.">
	
		<cfreturn structCopy(variables.values) />
	
	</cffunction>
	
	<cffunction name="setValue" returntype="void" access="public" output="false" 
				hint="I store a value in the event.">
		<cfargument name="name" type="string" required="true" 
					hint="I am the name of the value to store." />
		<cfargument name="value" type="any" required="true" 
					hint="I am the new value to store." />
			
		<cfset variables.values[arguments.name] = arguments.value />
			
	</cffunction>
	
	<cffunction name="values" returntype="any" access="public" output="false" 
				hint="I set event values. I take an arbitrary list of named arguments.">

		<cfset var i = 0 />
		
		<cfloop item="i" collection="#arguments#">
			<!--- only set named arguments, not positional arguments --->
			<cfif not isNumeric(i)>
				<cfset setValue(i,arguments[i]) />
			</cfif>
		</cfloop>
		
		<cfreturn this />

	</cffunction>
	
	<cffunction name="hasValue" returntype="boolean" access="public" output="false" 
				hint="I return true iff the specified value exists in the event.">
		<cfargument name="name" type="string" required="true" 
					hint="I am the name of the value to test for." />

		<cfreturn structKeyExists(variables.values,arguments.name) />

	</cffunction>

</cfcomponent>