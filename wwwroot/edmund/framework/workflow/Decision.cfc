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

<cfcomponent implements="ICommand" output="false">
	
	<cffunction name="init" returntype="any" access="public" output="false" hint="">
		<cfargument name="condition" type="any" required="true" />
		<cfargument name="ifTrue" type="any" required="true" />
		<cfargument name="else" type="any" required="false" />
				
		<cfset variables.condition = arguments.condition />
		<cfset variables.ifTrue = arguments.ifTrue />
		<cfif structKeyExists(arguments,"else")>
			<cfset variables.else = arguments.else />
		</cfif>
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="do" returntype="void" access="public" output="false" hint="">
		<cfargument name="context" type="struct" required="true" />

		<cfif variables.condition.do(arguments.context)>

			<cfset variables.ifTrue.do(arguments.context) />

		<cfelseif structKeyExists(variables,"else")>

			<cfset variables.else.do(arguments.context) />

		</cfif>

	</cffunction>

</cfcomponent>