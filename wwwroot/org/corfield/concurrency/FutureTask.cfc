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
<cfcomponent name="FutureTask" hint="I am the basic implementation of a Java 5 style 'future'">

	<!---
		SLEEP_UNIT - The default amount of time in milliseconds that
				the future sleeps for between checks to see if the task
				has completed. This is public so that it can be modified
				easily by user code if a different granularity is desired
				however it is not exposed as a public get/set method pair
				since it is not part of the API and it is hoped that most
				code will not need to modify it!
	--->
	<cfset this.SLEEP_UNIT = 100 />
	
	<!--- PRIVATE DATA --->

	<!--- thread - the Java Thread we use for sleeping: --->
	<cfset variables.thread = createObject("java","java.lang.Thread") />
	<!--- task - the task we will execute - it is any object: --->
	<cfset variables.task = 0 />
	<!--- method - the name of the method to execute on the task: --->
	<cfset variables.method = "call" />
	<!--- result - we deliberately leave this undefined until a result is set() --->
	<!--- variables.result = undefined --->
	<!--- taskArgs - optional arguments passed via initialization and/or via run() --->
	<cfset variables.taskArgs = structNew() />
	<!--- status - the current state of the task: NULL, READY, RUNNING, DONE, FAILED, CANCELLED: --->
	<cfset variables.status = "NULL" />
	<!--- exception - the exception thrown by the executing task, if any (for state FAILED): --->
	<cfset variables.exception = 0 />
	
	<!--- PUBLIC METHODS --->

	<!--- init(task,[method="call"],[result]) : FutureTask --->
	<cffunction name="init" returntype="FutureTask" access="public" output="false" 
				hint="I am the constructor.<br />Throws: BADARGUMENT.">
		<cfargument name="task" type="any" required="true" 
					hint="I am the task to be executed asynchronously."/>
		<cfargument name="result" type="any" required="false" 
					hint="I am the optional fixed result value."/>
		<cfargument name="method" type="string" default="call" 
					hint="I am the optional method name to be called."/>
					
		<cfset var closure = createClosure(arguments.task,arguments.method) />
		
		<cfset variables.task = closure.object />
		<cfset variables.method = closure.method />
		<cfset structAppend(variables.taskArgs,arguments,true) />
		<cfif structKeyExists(arguments,"result")>
			<cfset variables.fixedResult = arguments.result />
		</cfif>
		<cfset resetTask() />

		<cfreturn this />

	</cffunction>

	<!--- cancel([mayInterruptIfRunning=false]) : boolean --->
	<cffunction name="cancel" returntype="boolean" access="public" output="false" 
				hint="I attempt to cancel the task.">
		<cfargument name="mayInterruptIfRunning" type="boolean" default="false" 
					hint="I specify whether a running task should be interrupted."/>

		<cfset var result = false />

		<cfswitch expression="#variables.status#">

		<cfcase value="READY">
			<!--- ok to cancel before it starts --->
			<cfset result = true />
			<cfset terminate("CANCELLED") />
		</cfcase>

		<cfcase value="RUNNING">
			<cfif arguments.mayInterruptIfRunning>
				<!--- may be able to cancel a running task --->
				<cfif structKeyExists(variables.task,"stop") and 
					  isCustomFunction(variables.task.stop)>
					<!---
						our convention is that a stop() method can be called
						that takes a FutureTask as an argument and when it
						actually stops, it calls FutureTask.stopped()
					--->
					<cftry>
						<cfset variables.task.stop(this) />
						<!--- at this point we *assume* the task will stop... --->
						<cfset result = true />
						<!--- ...but we do not terminate() --->
					<cfcatch type="any">
						<!--- we ignore exceptions - cancel() just fails --->
					</cfcatch>
					</cftry>
				</cfif>
			</cfif>
		</cfcase>
	
		<cfdefaultcase>
			<!--- task is null, done, failed or cancelled so the cancel operation fails --->
		</cfdefaultcase>

		</cfswitch>

		<cfreturn result />

	</cffunction>
	
	<!--- get([reset=false]) : any --->
	<cffunction name="get" returntype="any" access="public" output="false" 
				hint="I wait for the result to be ready and return it.<br />Throws: EXECUTIONEXCEPTION, INTERRUPTEDEXCEPTION">
		<cfargument name="reset" type="boolean" default="false"
					hint="I optionally specify whether to reset the task (so that it can be run again)." />

		<cfloop condition="not isDone()">
			<cfset waitFor(this.SLEEP_UNIT) />
		</cfloop>

		<cfreturn getResult(arguments.reset) />

	</cffunction>
	
	<!--- getWithTimeout(timeout,[reset=false]) : any --->
	<cffunction name="getWithTimeout" returntype="any" access="public" output="false" 
				hint="I wait for a specified period and return the result if it is available.<br />Throws: TIMEOUTEXCEPTION, EXECUTIONEXCEPTION, INTERRUPTEDEXCEPTION">
		<cfargument name="timeout" type="numeric" required="true" 
					hint="I specify how many milliseconds to wait for the result before giving up."/>
		<cfargument name="reset" type="boolean" default="false"
					hint="I optionally specify whether to reset the task (so that it can be run again)." />

		<cfset waitForResult(arguments.timeout) />
		<cfif isDone()>
			<cfreturn getResult(arguments.reset) />
		<cfelse>
			<!--- per the Java 5 spec, throw a TimeoutException: --->
			<cfthrow type="CONCURRENCY.FUTURE.TIMEOUTEXCEPTION" message="FutureTask timeout"
					 detail="The computation did not complete within #arguments.timeout#ms." />
		</cfif>

	</cffunction>
	
	<!--- isCancelled() : boolean --->
	<cffunction name="isCancelled" returntype="boolean" access="public" output="false" 
				hint="I indicate whether a task has been (successfully) cancelled.">

		<cfset var result = false />

		<cfswitch expression="#variables.status#">

		<cfcase value="CANCELLED">
			<!--- yes, it was cancelled --->
			<cfset result = true />
		</cfcase>

		<cfdefaultcase>
			<!--- task is null, ready, running, done or failed so it is not considered cancelled --->
		</cfdefaultcase>

		</cfswitch>

		<cfreturn result />

	</cffunction>
	
	<!--- isDone() : boolean --->
	<cffunction name="isDone" returntype="boolean" access="public" output="false" 
				hint="I indicate whether a task is completed (successfully or unsuccessfully).">

		<cfset var result = true />

		<cfswitch expression="#variables.status#">

		<cfcase value="RUNNING">
			<!--- a running task is not done --->
			<cfset result = false />
		</cfcase>

		<cfdefaultcase>
			<!--- task is null, ready, done, failed or cancelled so it is considered done --->
		</cfdefaultcase>

		</cfswitch>

		<cfreturn result />

	</cffunction>
	
	<!--- run() : void --->
	<cffunction name="run" returntype="void" access="public" output="false" 
				hint="I run the task asynchronously.<br />Throws: NOTSTARTED">

		<cfset var taskData = structNew() />

		<cfswitch expression="#variables.status#">

		<cfcase value="READY">
			<!--- a ready task can be started --->
			<cfset taskData.future = this />
			<cfset taskData.callable = variables.task />
			<cfset structAppend(variables.taskArgs,arguments,true) />
			<cfset taskData.arguments = variables.taskArgs />
			<cfset variables.status = "RUNNING" />
			<cfif sendGatewayMessage("CFML-Future",taskData)>
				<!--- good, it's running --->
			<cfelse>
				<!--- the task remains ready, we throw an exception, user can attempt run() again --->
				<cfset variables.status = "READY" />
				<cfthrow type="CONCURRENCY.FUTURE.NOTSTARTED" message="FutureTask not started"
						 detail="Unable to add the task to the event gateway queue, please try again later." />
			</cfif>
		</cfcase>

		<cfdefaultcase>
			<!--- task is null, running, done, failed or cancelled so it cannot be run --->
		</cfdefaultcase>

		</cfswitch>

	</cffunction>
	
	<!--- stopped() : void --->
	<cffunction name="stopped" returntype="void" access="public" output="false" 
				hint="I can be called by the task to indicate that it has successfully stopped itself after a stop() request.">

		<cfset terminate("CANCELLED") />

	</cffunction>
	
	<!--- PROTECTED METHODS --->

	<!--- done() : void --->
	<cffunction name="done" returntype="void" access="private" output="false" 
				hint="I am a hook for user-defined callbacks.">

		<!--- do nothing, can be overridden --->

	</cffunction>
	
	<!--- PACKAGE METHODS --->

	<!--- getMethod() : string --->
	<cffunction name="getMethod" returntype="string" access="package" output="false" 
				hint="I return the name of the method to call on the task.">

		<cfreturn variables.method />

	</cffunction>
	
	<!--- hasResult() : boolean --->
	<cffunction name="hasResult" returntype="boolean" access="package" output="false" 
				hint="I indicate whether a result has already been recorded for a task.">

		<cfreturn structKeyExists(variables,"result") />

	</cffunction>
	
	<!--- set(v) : void --->
	<cffunction name="set" returntype="void" access="package" output="false" 
				hint="I set the result of this future.">
		<cfargument name="v" type="any" required="false" 
					hint="I am the optional result value to set."/>

		<cfswitch expression="#variables.status#">

		<cfcase value="RUNNING">
			<!--- it was running so we can set the result and mark it done --->
			<cfif structKeyExists(arguments,"v")>
				<cfset variables.result = arguments.v />
			</cfif>
			<cfset terminate("DONE") />
		</cfcase>

		<cfdefaultcase>
			<!--- task is null, ready, done, failed or cancelled so we ignored the set --->
		</cfdefaultcase>

		</cfswitch>

	</cffunction>
	
	<!--- setException(e) : void --->
	<cffunction name="setException" returntype="void" access="package" output="true" 
				hint="I remember the exception thrown by the task.">
		<cfargument name="e" type="any" required="true" 
					hint="I am the exception the task threw."/>

		<cfset variables.exception = arguments.e />
		<cfset terminate("FAILED") />

	</cffunction>
	
	<!--- PRIVATE METHODS - implementation details only! --->

	<!--- getResult() : any --->
	<cffunction name="getResult" returntype="any" access="private" output="false" 
				hint="I return the task's result if it completed successfully.">
		<cfargument name="reset" type="boolean" required="true"
					hint="I specify whether to reset the task (so that it can be run again)." />

		<cfset var result = 0 />
		
		<cfswitch expression="#variables.status#">

		<cfcase value="DONE">
			<!--- it completed so it has a result --->
			<cfset result = variables.result />
			<cfif arguments.reset>
				<cfset resetTask() />
			</cfif>
			<cfreturn result />
		</cfcase>

		<cfcase value="FAILED">
			<!--- failed, throw an execution exception --->
			<cfthrow type="CONCURRENCY.FUTURE.EXECUTIONEXCEPTION" message="#variables.exception.message#"
					 detail="#variables.exception.detail#" errorcode="#variables.exception.type#" />
		</cfcase>

		<cfcase value="RUNNING">
			<!---
				this should never happen because get() and getWithTimeout() only call this
				method once isDone() returns true...
			--->
			<cfthrow type="CONCURRENCY.FUTURE.INTERNALERROR" message="FutureTask internal error"
					 detail="An internal attempt was made to retrieve the result of a task that is still running." />
		</cfcase>

		<cfdefaultcase>
			<!--- task is null, ready or cancelled so we treat it as interrupted --->
			<cfthrow type="CONCURRENCY.FUTURE.INTERRUPTEDEXCEPTION" message="FutureTask interrupted"
					 detail="The computation was cancelled or has not yet run." />
		</cfdefaultcase>

		</cfswitch>

	</cffunction>
	
	<!--- terminate(status) : void --->
	<cffunction name="terminate" returntype="void" access="private" output="false" 
				hint="I set the final status of the task and call the done() callback.">
		<cfargument name="status" type="string" required="true" 
					hint="I am the final status of the task."/>

		<cfset variables.status = arguments.status />
		<cfset done() />

	</cffunction>
	
	<!--- waitFor(timeout) : void --->
	<cffunction name="waitFor" returntype="void" access="private" output="false" 
				hint="I wait for a specified time.">
		<cfargument name="timeout" type="numeric" required="true" 
					hint="I am the time in milliseconds to wait."/>

		<cfset variables.thread.sleep(arguments.timeout) />

	</cffunction>
	
	<!--- waitForResult(timeout) : void --->
	<cffunction name="waitForResult" returntype="void" access="private" output="false" 
				hint="I wait for the result for a specified time.">
		<cfargument name="timeout" type="numeric" required="true" 
					hint="I am the time in milliseconds to wait."/>

		<!--- we wait in increments of this.SLEEP_UNIT --->
		<cfset var jumps = int(arguments.timeout / this.SLEEP_UNIT) />
		<cfset var hops = arguments.timeout mod this.SLEEP_UNIT />
		<cfset var bigtime = 0 />
		<cfset var startTime = getTickCount() />

		<!--- 'big' jumps of waiting time: --->
		<cfloop index="bigtime" from="1" to="#jumps#">
			<cfif isDone() or (getTickCount() - startTime) gt arguments.timeout>
				<cfreturn />
			</cfif>
			<cfset waitFor(this.SLEEP_UNIT) />
		</cfloop>
		<cfif isDone() or (getTickCount() - startTime) gt arguments.timeout>
			<cfreturn />
		</cfif>
		<!--- final 'hops' of waiting time: --->
		<cfset waitFor(hops) />

	</cffunction>
	
	<!--- resetTask() : void --->
	<cffunction name="resetTask" returntype="void" access="private" output="false"
				hint="I reset the task to its initial state.">
		<cfif structKeyExists(variables,"fixedResult")>
			<cfset variables.result = variables.fixedResult />
		<cfelse>
			<cfset structDelete(variables,"result") />
		</cfif>
		<cfset variables.status = "READY" />
	</cffunction>

	<!--- createClosure(objectOrName,method) : struct --->
	<cffunction name="createClosure" returntype="struct" access="private" output="false"
				hint="I return a struct containing an instantiated object and a method name based on the string or object passed in.">
		<cfargument name="objectOrName" type="any" required="true"
					hint="I should be either an instantiated object or a name of the form 'Component.Name' or 'Component.Name.method()'." />
		<cfargument name="method" type="string" required="true"
					hint="I am the default method to use if objectOrName is an object or just a component name." />

		<cfset var closure = structNew() />
		<cfset var objectName = arguments.objectOrName />
		<cfset var methodName = arguments.method />
		<cfset var objectNameLen = 0 />
		<cfset var methodNameLen = 0 />
		
		<cfif isValid("string",arguments.objectOrName)>
		
			<cfset objectNameLen = len(objectName) />
			<cfif objectNameLen gte 5 and right(objectName,2) is "()">
			
				<!--- should be component.name.method() --->
				<cfset methodName = listLast(objectName,".") />
				<cfset methodNameLen = len(methodName) />
				<cfif objectNameLen gte methodNameLen+2>
				
					<cfset objectName = left(objectName,objectNameLen-methodNameLen-1) />
					<cfset methodName = left(methodName,methodNameLen-2) />
				
				<cfelse>
				
					<!--- no method name --->
					<cfthrow type="CONCURRENCY.FUTURE.BADARGUMENT" message="FutureTask invalid argument"
							 detail="'#arguments.objectOrName#' does not identify a valid component/method." />
				
				</cfif>
			
			<!--- else assume it is just a method name --->
			</cfif>
			<cftry>

				<cfset closure.object = createObject("component",objectName) />
				<cfset closure.method = methodName />

			<cfcatch type="any">
				<cfthrow type="CONCURRENCY.FUTURE.BADARGUMENT" message="FutureTask invalid argument"
						 detail="'#arguments.objectOrName#' does not identify a valid component/method."
						 errorcode="#cfcatch.message# #cfcatch.detail#" />
			</cfcatch>

			</cftry>
			
		<cfelseif isObject(arguments.objectOrName)>
		
			<cfset closure.object = arguments.objectOrName />
			<cfset closure.method = arguments.method />
			
		<cfelse>
		
			<cfthrow type="CONCURRENCY.FUTURE.BADARGUMENT" message="FutureTask invalid argument"
					 detail="The argument passed does not identify a valid component/method nor contain a component instance." />
		
		</cfif>
		
		<cfreturn closure />
		
	</cffunction>

</cfcomponent>
