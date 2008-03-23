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
		<cfargument name="body" type="edmund.framework.workflow.ICommand" required="true" />
				
		<cfset variables.iterator = arguments.iterator />
		<cfset variables.it = arguments.it />
		<cfset variables.body = arguments.body />
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="handleEvent" returntype="boolean" access="public" output="false" hint="">
		<cfargument name="event" type="edmund.framework.Event" required="true" />
		
		<cfset var result = true />

		<cfloop condition="result and arguments.event.getValue(variables.iterator).hasNext()">
		
			<cfset arguments.event.setValue( variables.it, arguments.event.getValue( variables.iterator ).next() ) />
			<cfset result = result and variables.body.handleEvent(arguments.event) />
		
		</cfloop>
		
		<cfreturn result />

	</cffunction>

</cfcomponent>