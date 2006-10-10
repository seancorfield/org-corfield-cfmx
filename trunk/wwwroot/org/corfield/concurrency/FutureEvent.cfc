<!---
	Copyright 2005 Sean A Corfield http://corfield.org/
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	 
		http://www.apache.org/licenses/LICENSE-2.0
	 
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
	
	Release 1.2 2005-05-15 See README for details.
--->
<cfcomponent name="FutureEvent" hint="I am the event gateway that manages how FutureTask objects execute their task.">

	<!--- onIncomingMessage(event) : void --->
	<cffunction name="onIncomingMessage" returntype="struct" access="public" output="false" 
				hint="I am called automatically by the CFML asynchronous event gateway.">
		<cfargument name="event" type="struct" required="true" 
					hint="I am the data passed from the FutureTask. I contain a reference to the task to be called and the future in which the result should be set."/>

		<cfset var result = 0 />
		<cfset var future = 0 />
		<cfset var gatewayResult = structNew() />

		<cftry>
			<cfset future = arguments.event.data.future />
			<cfinvoke returnvariable="result" 
					  component="#arguments.event.data.callable#" 
					  method="#future.getMethod()#"
					  argumentcollection="#arguments.event.data.arguments#" />
			<cfif future.hasResult()>
				<cfset future.set() />
			<cfelse>
				<cfset future.set(result) />
			</cfif>
		<cfcatch type="any">
			<cfset future.setException(cfcatch) />
		</cfcatch>
		</cftry>
		
		<cfreturn gatewayresult />

	</cffunction>

</cfcomponent>
