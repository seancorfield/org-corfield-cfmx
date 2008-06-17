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

<cfcomponent hint="I am the ColdFusion 8+ threading model" output="false">
	
	<cffunction name="init" returntype="any" access="public" output="false">
		<cfargument name="eventHandler" type="any" required="true" 
					hint="I am the Edmund event handler." />
		
		<cfset variables.eventHandler = arguments.eventHandler />
		<cfset variables.javaThread = createObject("java","java.lang.Thread") />

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

		<cfset var threadName = variables.javaThread.currentThread().getThreadGroup().getName() />

		<!--- if we're inside a cfthread or other asynchronous event, run synchronously --->
		<cfif threadName eq "cfthread" or threadName eq "scheduler">

			<cfinvoke component="#arguments.object#" method="#arguments.method#">
				<cfinvokeargument name="event" value="#arguments.event#" />
			</cfinvoke>

		<cfelse>

			<cfparam name="request.__edmund_thread_id" default="0" />
			<cfset request.__edmund_thread_id = request.__edmund_thread_id + 1 />
			<cfset request["__edmund_data_" & request.__edmund_thread_id] = structNew() />
			<cfset request["__edmund_data_" & request.__edmund_thread_id].object = arguments.object />
			<cfset request["__edmund_data_" & request.__edmund_thread_id].event = arguments.event />

			<!--- thread name is required and must be unique per thread --->
			<cfthread action="run" name="edmund_thread_#request.__edmund_thread_id#"
						method="#arguments.method#">
	
				<cfinvoke component="#request['__edmund_data_' & request.__edmund_thread_id].object#" 
							method="#attributes.method#">
					<cfinvokeargument name="event" value="#request['__edmund_data_' & request.__edmund_thread_id].event#" />
				</cfinvoke>

			</cfthread>

		</cfif>

	</cffunction>

</cfcomponent>