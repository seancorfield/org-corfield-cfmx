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
		<cfargument name="iterator" type="string" required="true" />
		<cfargument name="it" type="string" required="true" />
		<cfargument name="body" type="any" required="true" />
				
		<cfset variables.iterator = arguments.iterator />
		<cfset variables.it = arguments.it />
		<cfset variables.body = arguments.body />
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="do" returntype="void" access="public" output="false" hint="">
		<cfargument name="context" type="struct" required="true" />

		<cfloop condition="arguments.context[variables.iterator].hasNext()">
		
			<cfset arguments.context[variables.it] = arguments.context[variables.iterator].next() />
			<cfset variables.body.do(arguments.context) />
		
		</cfloop>

	</cffunction>

</cfcomponent>