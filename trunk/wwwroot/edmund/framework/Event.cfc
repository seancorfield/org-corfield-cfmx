<!---
 
  Copyright (c) 2008, Sean Corfield
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
       http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

---> 

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