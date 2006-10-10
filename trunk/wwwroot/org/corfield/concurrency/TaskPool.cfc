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
<cfcomponent name="TaskPool" hint="I am a pool of future tasks to be executed">

	<!--- PRIVATE DATA --->

	<!--- the pool of tasks to run: --->
	<cfset variables.pool = structNew() />
	
	<!--- PUBLIC METHODS --->

	<!--- init() : TaskPool --->
	<cffunction name="init" returntype="TaskPool" access="public" output="false"
				hint="I initialize the task pool.">

		<cfset variables.pool = structNew() />
		
		<cfreturn this />

	</cffunction>
	
	<!--- addTask(task,[method="call"],[result],[autorun=false]) : uuid --->
	<cffunction name="addTask" returntype="string" access="public" output="false" 
				hint="I add a task to the pool.<br />Throws: BADARGUMENT">
		<cfargument name="task" type="any" required="true" 
					hint="I am the task to be executed asynchronously."/>
		<cfargument name="result" type="any" required="false" 
					hint="I am the optional fixed result value."/>
		<cfargument name="method" type="string" default="call" 
					hint="I am the optional method name to be called."/>
		<cfargument name="autorun" type="boolean" default="false"
					hint="I indicate whether to automatically run the task."/>
					
		<cfset var taskID = createUUID() />
		<cfset var future = createObject("component","FutureTask").init(argumentCollection=arguments) />
		
		<cfset variables.pool[taskID] = future />
		
		<cfif arguments.autorun>
			<cfset future.run(argumentCollection=arguments) />
		</cfif>

		<cfreturn taskID />

	</cffunction>

	<!--- cancel([mayInterruptIfRunning=false],[uuid]) : boolean --->
	<cffunction name="cancel" returntype="boolean" access="public" output="false" 
				hint="I attempt to cancel a task (or all tasks).">
		<cfargument name="mayInterruptIfRunning" type="boolean" default="false" 
					hint="I specify whether a running task should be interrupted."/>
		<cfargument name="taskID" type="string" required="false" 
					hint="I am the optional task to cancel."/>

		<cfset var id = 0 />
		<cfset var future = 0 />
		<cfset var success = true />
		
		<cfif structKeyExists(arguments,"taskID")>
			<cfset future = variables.pool[arguments.taskID] />
			<cfset success = future.cancel(arguments.mayInterruptIfRunning) />
		<cfelse>
			<cfloop collection="#variables.pool#" item="id">
				<cfset success = success and cancel(arguments.mayInterruptIfRunning,id) />
			</cfloop>
		</cfif>
		
		<cfreturn success />

	</cffunction>
	
	<!--- get(uuid,[reset=false]) : any --->
	<cffunction name="get" returntype="any" access="public" output="false" 
				hint="I wait for the result to be ready and return it.<br />Throws: EXECUTIONEXCEPTION, INTERRUPTEDEXCEPTION">
		<cfargument name="taskID" type="string" required="true"
					hint="I specify the task whose result to return."/>
		<cfargument name="reset" type="boolean" default="false"
					hint="I optionally specify whether to reset the task (so that it can be run again)." />

		<cfset var future = variables.pool[arguments.taskID] />

		<cfreturn future.get(reset) />

	</cffunction>
	
	<!--- getWithTimeout(timeout) : any --->
	<cffunction name="getWithTimeout" returntype="any" access="public" output="false" 
				hint="I wait for a specified period and return the result if it is available.<br />Throws: TIMEOUTEXCEPTION, EXECUTIONEXCEPTION, INTERRUPTEDEXCEPTION">
		<cfargument name="taskID" type="string" required="true"
					hint="I specify the task whose result to return."/>
		<cfargument name="timeout" type="numeric" required="true" 
					hint="I specify how many milliseconds to wait for the result before giving up."/>
		<cfargument name="reset" type="boolean" default="false"
					hint="I optionally specify whether to reset the task (so that it can be run again)." />

		<cfset var future = variables.pool[arguments.taskID] />

		<cfreturn future.getWithTimeout(timeout,reset) />

	</cffunction>
	
	<!--- isCancelled([uuid]) : boolean --->
	<cffunction name="isCancelled" returntype="boolean" access="public" output="false" 
				hint="I indicate whether a task has (or all tasks have) been (successfully) cancelled.">
		<cfargument name="taskID" type="string" required="false" 
					hint="I am the optional task to check for status."/>

		<cfset var id = 0 />
		<cfset var future = 0 />
		<cfset var cancelled = true />
		
		<cfif structKeyExists(arguments,"taskID")>
			<cfset future = variables.pool[arguments.taskID] />
			<cfset cancelled = future.isCancelled() />
		<cfelse>
			<cfloop collection="#variables.pool#" item="id">
				<cfset cancelled = cancelled and isCancelled(id) />
			</cfloop>
		</cfif>
		
		<cfreturn cancelled />

	</cffunction>
	
	<!--- isDone([uuid]) : boolean --->
	<cffunction name="isDone" returntype="boolean" access="public" output="false" 
				hint="I indicate whether a task is (or all tasks are) completed (successfully or unsuccessfully).">
		<cfargument name="taskID" type="string" required="false" 
					hint="I am the optional task to check for status."/>

		<cfset var id = 0 />
		<cfset var future = 0 />
		<cfset var completed = true />
		
		<cfif structKeyExists(arguments,"taskID")>
			<cfset future = variables.pool[arguments.taskID] />
			<cfset completed = future.isDone() />
		<cfelse>
			<cfloop collection="#variables.pool#" item="id">
				<cfset completed = completed and isDone(id) />
			</cfloop>
		</cfif>
		
		<cfreturn cancelled />

	</cffunction>
	
	<!--- join([reset=true]) : void --->
	<cffunction name="join" returntype="void" access="public" output="false"
				hint="I wait for all the results to be ready.<br />Throws: EXECUTIONEXCEPTION, INTERRUPTEDEXCEPTION">
		<cfargument name="reset" type="boolean" default="false"
					hint="I optionally specify whether to reset the tasks (so that they can be run again)." />

		<cfset var id = 0 />
		<cfset var future = 0 />
		
		<!--- the simplest approach is to just get each result and ignore it: --->
		<cfloop collection="#variables.pool#" item="id">
			<cfset future = variables.pool[id] />
			<cfset future.get(arguments.reset) />
		</cfloop>

	</cffunction>
	
	<!--- run([uuid]) : void --->
	<cffunction name="run" returntype="void" access="public" output="false" 
				hint="I run any task that is ready.<br />Throws: NOTSTARTED">
		<cfargument name="taskID" type="string" required="false" 
					hint="I am the optional task to run."/>

		<cfset var id = 0 />
		<cfset var future = 0 />
		<cfset var args = 0 />
		
		<cfif structKeyExists(arguments,"taskID")>
			<cfset future = variables.pool[arguments.taskID] />
			<cfset future.run(argumentCollection=arguments) />
		<cfelse>
			<cfloop collection="#variables.pool#" item="id">
				<cfset args = arguments />
				<cfset args.taskID = id />
				<cfset run(argumentCollection=args) />
			</cfloop>
		</cfif>

	</cffunction>
	
</cfcomponent>
