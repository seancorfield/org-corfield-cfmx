<cfcomponent>
<!---

  Closure.cfc - Closures for ColdFusion
 
  Copyright (c) 2006, Sean Corfield
  
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

	<cffunction name="init" returntype="Closure" access="public" output="false" hint="I am the constructor">
		<cfargument name="function" type="any" required="true" hint="I am the function/UDF for this closure" />
		
		<cfset variables._method = arguments.function />
		<cfset variables._methodName = "" />
		<cfset this.call = variables._method />
		
		<cfreturn this />
		
	</cffunction>
  
	<cffunction name="bind" returntype="Closure" access="public" output="false" 
				hint="I clone this closure and bind an arbitrary sequence of arguments into it">
		<!--- takes any sequence of names arguments --->
		
		<cfset var key = "" />
		<cfset var newClosure = createObject("component","Closure").init(variables._method) />
		
		<!--- add a public method from the private method so we can bind the arguments in: --->
		<cfset newClosure.rebind = _bindVariables />
		<cfset newClosure.rebind(argumentCollection=arguments) />
		
		<!--- perpetuate the method name if present: --->
		<cfif variables._methodName is not "">
			<cfset newClosure.name(variables._methodName) />
		</cfif>

		<cfreturn newClosure />
				
	</cffunction>
	
	<cffunction name="_bindVariables" returntype="void" access="private" output="false" 
				hint="I bind an arbitrary sequence of arguments into this closure (but I do not overwrite variables)">
		<!--- takes any sequence of names arguments --->
		
		<cfloop collection="#arguments#" item="key">
			<!--- we only bind in variables that don't clash! --->
			<cfif not structKeyExists(variables,key)>
				<cfset variables[key] = arguments[key] />
			</cfif>
		</cfloop>
		
	</cffunction>
  
	<cffunction name="name" returntype="Closure" access="public" output="false" 
				hint="I rename the (internal) method as a public, external method for thise closure">
		<cfargument name="methodName" type="string" required="true" />
		
		<cfset variables._methodName = arguments.methodName />
		<cfset this[variables._methodName] = variables._method />
		
		<cfreturn this />
		
	</cffunction>
 
</cfcomponent>