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

<cfcomponent hint="I am the BlueDragon 7+ threading model" output="false">
	
	<cffunction name="init" returntype="any" access="public" output="false">
		<cfargument name="eventHandler" type="any" required="true" 
					hint="I am the Edmund event handler." />
		
		<cfset variables.eventHandler = arguments.eventHandler />

		<cfreturn this />
			
	</cffunction>
	
	<cffunction name="asyncInvoke" returntype="void" access="public" output="false" 
				hint="I perform an asynchronous invocation of a listener.">
		<cfargument name="object" type="any" required="true" 
					hint="I am the object to handle the event." />
		<cfargument name="method" type="string" required="true" 
					hint="I am the method to handle the event." />
		<cfargument name="event" type="edmund.framework.Event" required="true" 
					hint="I am the event to be handled." />

		<!--- BlueDragon allows nested threads and automatically names threads --->
		<cfthread object="#arguments.object#" method="#arguments.method#" event="#arguments.event#">

			<cfinvoke component="#attributes.object#" method="#attributes.method#">
				<cfinvokeargument name="event" value="#attributes.event#" />
			</cfinvoke>

		</cfthread>
	
	</cffunction>

</cfcomponent>