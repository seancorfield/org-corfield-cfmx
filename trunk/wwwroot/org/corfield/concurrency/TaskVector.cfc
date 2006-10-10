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
<cfcomponent name="TaskVector" hint="I execute a single task against a vector of data.">

	<!--- PRIVATE DATA --->

	<!--- the vector of tasks to run: --->
	<cfset variables.vector = arrayNew(1) />
	<!--- the task to run on each element: --->
	<cfset variables.task = 0 />
	<!--- the optional method to call on the task: --->
	<cfset variables.method = "call" />
	
	<!--- PUBLIC METHODS --->

	<!--- init() : TaskVector --->
	<cffunction name="init" returntype="TaskVector" access="public" output="false"
				hint="I initialize the task vector.">
		<cfargument name="task" type="any" required="true" 
					hint="I am the task to be executed asynchronously."/>
		<cfargument name="result" type="any" required="false" 
					hint="I am the optional fixed result value."/>
		<cfargument name="method" type="string" default="call" 
					hint="I am the optional method name to be called."/>

		<cfset variables.task = arguments.task />
		<cfif structKeyExists(arguments,"result")>
			<cfset variables.result = arguments.result />
		</cfif>
		<cfset variables.method = arguments.method />
		
		<cfreturn this />

	</cffunction>
	
	<!--- run(data : array) : void --->
	<cffunction name="run" returntype="void" access="public" output="false" 
				hint="I run the vector of tasks asynchronously.<br />Throws: NOTSTARTED">
		<!--- argument name="?" type="any" required="true" --->

		<cfset var argName = listFirst(structKeyList(arguments)) />
		<cfset var numOfElements = arrayLen(arguments[argName]) />
		<cfset var args = 0 />
		<cfset var i = 0 />
		<cfset var future = 0 />
		<cfset var hasResult = structKeyExists(variables,"result") />
		
		<!--- build the vector of tasks --->
		<cfloop index="i" from="1" to="#numOfElements#">

			<cfif hasResult>
				<cfset future = createObject("component","FutureTask").init(variables.task, variables.result, variables.method) />
			<cfelse>
				<cfset future = createObject("component","FutureTask").init(task=variables.task, method=variables.method) />
			</cfif>

			<cfset variables.vector[i] = future />
			<cfset args = structNew() />
			<cfset args[argName] = arguments[argName][i] />
			<cfset future.run(argumentCollection=args) />

		</cfloop>

	</cffunction>
	
	<!--- cancel([mayInterruptIfRunning=false]) : boolean --->
	<cffunction name="cancel" returntype="boolean" access="public" output="false" 
				hint="I attempt to cancel the tasks.">
		<cfargument name="mayInterruptIfRunning" type="boolean" default="false" 
					hint="I specify whether a running task should be interrupted."/>

		<cfset var numOfElements = arrayLen(variables.vector) />
		<cfset var i = 0 />
		<cfset var future = 0 />
		<cfset var result = true />
		
		<cfloop index="i" from="1" to="#numOfElements#">

			<cfset future = variables.vector[i] />
			<cfset result = result and future.cancel(arguments.mayInterruptIfRunning) />

		</cfloop>

		<cfreturn result />

	</cffunction>
	
	<!--- get([reset=false],[index]) : array --->
	<cffunction name="get" returntype="array" access="public" output="false" 
				hint="I wait for the results to be ready and return them.<br />Throws: EXECUTIONEXCEPTION, INTERRUPTEDEXCEPTION">
		<cfargument name="reset" type="boolean" default="false"
					hint="I optionally specify whether to reset each task (so that it can be run again)." />
		<cfargument name="index" type="numeric" required="false" 
					hint="I am the optional specific task index." />

		<cfset var numOfElements = arrayLen(variables.vector) />
		<cfset var i = 0 />
		<cfset var results = arrayNew(1) />
		<cfset var future = 0 />
		
		<cfif structKeyExists(arguments, "index")>
			<cfset future = variables.vector[arguments.index] />
			<cfreturn future.get(arguments.reset) />
		</cfif>
		
		<cfloop index="i" from="1" to="#numOfElements#">

			<cfset future = variables.vector[i] />
			<cfset results[i] = future.get(arguments.reset) />

		</cfloop>

		<cfreturn results />

	</cffunction>
		
	<!--- getAvailable(unavailableResult,[reset=false]) : array --->
	<cffunction name="getAvailable" returntype="array" access="public" output="false" 
				hint="I wait for the results to be ready and return them.<br />Throws: EXECUTIONEXCEPTION, INTERRUPTEDEXCEPTION">
		<cfargument name="unavailableResult" type="any" required="true" 
					hint="I am the value to use if a result is not available yet." />
		<cfargument name="reset" type="boolean" default="false"
					hint="I optionally specify whether to reset each task (so that it can be run again)." />

		<cfset var numOfElements = arrayLen(variables.vector) />
		<cfset var i = 0 />
		<cfset var results = arrayNew(1) />
		<cfset var future = 0 />
		
		<cfloop index="i" from="1" to="#numOfElements#">

			<cfset future = variables.vector[i] />
			<cfif future.isDone()>
				<cfset results[i] = future.get(arguments.reset) />
			<cfelse>
				<cfset results[i] = arguments.unavailableResult />
			</cfif>

		</cfloop>

		<cfreturn results />

	</cffunction>
		
	<!--- isDone([index]) : boolean --->
	<cffunction name="isDone" returntype="boolean" access="public" output="false" 
				hint="I indicate whether all the tasks are completed (successfully or unsuccessfully).">
		<cfargument name="index" type="numeric" required="false" 
					hint="I am the optional specific task index." />

		<cfset var numOfElements = arrayLen(variables.vector) />
		<cfset var i = 0 />
		<cfset var future = 0 />
		<cfset var result = true />
		
		<cfif structKeyExists(arguments, "index")>
			<cfset future = variables.vector[arguments.index] />
			<cfreturn future.isDone() />
		</cfif>
		
		<cfloop index="i" from="1" to="#numOfElements#">

			<cfset future = variables.vector[i] />
			<cfset result = result and future.isDone() />

		</cfloop>

		<cfreturn result />

	</cffunction>
	
</cfcomponent>