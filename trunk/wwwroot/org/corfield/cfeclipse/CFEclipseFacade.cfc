<!---
   Copyright (c) 2007, Sean Corfield
   All rights reserved.

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

<cfcomponent extends="org.cfcunit.framework.TestListener" 
			hint="I implement a remotely accessible facade for cfcUnit that can be invoked from Robert Blackburn's CFUnit CFEclipse plugin.">
	
	<!--- any newline character that Java recognizes - chr(13) is CR (ctl+m) and works on Windows and Mac: --->
	<cfset variables.newline = chr(13) />

	<!----------------------------------------------------------------------->
	
	<cffunction name="execute" returntype="void" access="remote" 
				hint="I am called by the CFEclipse plugin to execute a specific test case.
					  I output a string that represents the execution of the tests, readable by the plugin.">
		<cfargument name="test" required="true" type="string" 
					hint="I am the name of the test case to execute." />

		<cfset var testCaseName = arguments.test />
		<cfset var suite = 0 />
		<cfset var testCase = 0 />
		
		<cflog text="execute: #arguments.test#" />
		<!--- attempt to create the test case: --->
		<cftry>
			
			<cfset testCase = createObject("component",testCaseName).init(testCaseName) />
			
		<cfcatch type="NoSuchTemplateException">
			<!---
				retry with the prefix stripped if it fails - this allows for the funky
				way the plugin locates files across Eclipse projects (it puts the project
				name onto the front of the component name)
			--->
			<cfif listLen(testCaseName,".") gt 1>

				<cfset testCaseName = right(testCaseName,len(testCaseName)-len(listFirst(testCaseName,"."))-1) />
				<!--- if this fails we'll just let it throw an exception --->
				<cfset testCase = createObject("component",testCaseName) />
				<!--- Luis Majano pointed out there is actually no requirement to have an init() method on a test suite: --->
				<cfif structKeyExists(testCase,"init") and isCustomFunction(testCase.init)>
					<cfset testCase.init(testCaseName) />
				</cfif>

			<cfelse>
				<!--- hmm, it's just a simple CFC name and we can't create it... --->
				<cfrethrow />

			</cfif>

		</cfcatch>
		</cftry>

		<!--- create an instance of the desired test case and build a test suite from it: --->
		<cfif structKeyExists(testCase,"suite") and isCustomFunction(testCase.suite)>
			<cfset suite = testCase.suite() />
		<cfelse>
			<cfset suite = createObject("component","org.cfcunit.framework.TestSuite").init(testClass=testCase) />
		</cfif>

		<!--- ensure CF debug output doesn't mess with us: --->
		<cfsetting showdebugoutput="false" enablecfoutputonly="true" />

		<!--- create a test runner with this object as a test listener and run the test suite --->
		<cfset variables.buffer = "" />
		<cfset createObject("component","org.cfcunit.service.TestRunner").init(this).doRun(suite) />

		<!--- send the specially formatted output to the plugin: --->
		<cfcontent type="text/plain" reset="true" />
		<cfoutput>{version=1.0:framework=cfcunit:count=#suite.countTestCases()#}#variables.newline##variables.buffer#</cfoutput>

	</cffunction>
	
	<!----------------------------------------------------------------------->
	
	<cffunction name="getTests" returntype="void" access="remote" 
				hint="I am called by the CFEclipse plugin to output a list of CFC paths based on a directory or file.">
		<cfargument name="location" required="true" type="string" 
					hint="I am either a directory or a file path to search for CFCs." />
		
		<cfset var directory = 0 />
		<cfset var webRoot = expandPath("/") />
		<cfset var webRootLen = len(webRoot) - 1 />
		<cfset var relativeLocation = "" />

		<cflog text="getTests: #arguments.location#" />
		<!--- strip the trailing / from webRoot so it won't matter whether the location has one or not: --->
		<cfset webRoot = left(webRoot,webRootLen) />
		<cfif len(arguments.location) gte webRootLen and left(arguments.location,webRootLen) is webRoot>
			<cfset relativeLocation = right(arguments.location,len(arguments.location)-webRootLen) />
			<!--- at this point, relativeLocation is either empty or begins with a / --->
			<cfset relativeLocation = listChangeDelims(relativeLocation,".","/\") />
		<cfelse>
			<!--- could be a file path anywhere on the system --->
		</cfif>
		
		<cfif directoryExists(arguments.location)>

			<cflog text="it's a directory" />
			<!--- it's a directory, search for test case files (which begin with "Test" by convention): --->
			<cfdirectory action="list" directory="#arguments.location#" name="directory" filter="Test*.cfc" />
			
		<cfelseif fileExists(arguments.location) and listLast(arguments.location,".") is "cfc">

			<cflog text="it's a file" />
			<!--- it's a file, reformat it as a CFC path by dropping .cfc from the relativeLocation: --->
			<cfset relativeLocation = left(relativeLocation,len(relativeLocation) - 4) />
			
		<cfelse>

			<cflog text="assume it's a path" />
			<!--- we will assume it's a CFC path and just echo it back --->
			<cfset relativeLocation = arguments.location />

		</cfif>

		<!--- ensure CF debug output doesn't mess with us: --->
		<cfsetting showdebugoutput="false" enablecfoutputonly="true" />

		<cflog text="relativeLocation: #relativeLocation#" />
		<!--- output list of CFC paths that we found in the requested location: --->
		<cfcontent type="text/plain" reset="true" />
		<cfif isQuery( directory )>
			<cfoutput query="directory"><cfif relativeLocation is not "">#relativeLocation#.</cfif>#listFirst( directory.name, "." )##variables.newline#</cfoutput>
		<cfelse>
			<cfoutput>#relativeLocation#</cfoutput>			
		</cfif>
		
	</cffunction>
	
	<!----------------------------------------------------------------------->
	
	<cffunction name="startTest" returntype="void" access="public" output="false" 
				hint="I override the base listener method to record that a test has started.">
		<cfargument name="test" required="true" type="any" 
					hint="I am a test case (a cfcUnit Test object)." />

		<cfset variables.buffer = variables.buffer & "[" & arguments.test.getName() & "]" & variables.newline />
		
	</cffunction>

	<!----------------------------------------------------------------------->
	
	<cffunction name="endTest" returntype="void" access="public" output="false" 
				hint="I override the base listener method to record that a test has finished.">
		<cfargument name="test" required="true" type="any" 
					hint="I am a test case (a cfcUnit Test object)." />
					
		<!--- I do nothing --->
		
	</cffunction>
	

	<!----------------------------------------------------------------------->
	
	<cffunction name="addError" returntype="void" access="public" output="false" 
				hint="I override the base listener method to record that a test failed to run unexpectedly.">
		<cfargument name="test" type="any" required="true" 
					hint="I am a test case (a cfcUnit Test object)." />
		<cfargument name="error" type="any" required="true" 
					hint="I am the exception that was thrown when we tried to run the test." />
		
		<cfset outputMessage(arguments.test,arguments.error,"ERROR")/>
		
	</cffunction>
	
	<!----------------------------------------------------------------------->
	
	<cffunction name="addFailure" returntype="void" access="public" output="false" 
				hint="I override the base listener method to record that a test assertion failed.">
		<cfargument name="test" type="any" required="true" 
					hint="I am a test case (a cfcUnit Test object)." />
		<cfargument name="failure" type="any" required="true" 
					hint="I am the exception that was thrown when the test assertion failed." />
		
		<cfset outputMessage(arguments.test,arguments.failure,"FAILURE")/>
		
	</cffunction>

	<!----------------------------------------------------------------------->
	
	<cffunction name="outputMessage" access="private" returntype="void" output="false" 
				hint="I add a failure or error message to the output buffer.">
		<cfargument name="test" required="true" type="any" 
					hint="I am a test case (a cfcUnit Test object)." />
		<cfargument name="thrown" required="true" type="any" 
					hint="I am the exception that was thrown by the test." />
		<cfargument name="type" required="true" type="string"
					hint="I represent the type of exception (ERROR or FAILURE)." />

		<cfset var iterator = 0 />
		<cfset var context = 0 />
		
		<cfset var message = arguments.thrown.message />
		<cfset var exceptionType = arguments.type />
		<cfset var details = "" />
		
		<cfif arguments.thrown.detail is not "">
			<cfset details = details & variables.newline & HTMLEditFormat( arguments.thrown.detail ) />
		</cfif>
		
		<cfif structKeyExists(arguments.thrown, "sql")>
			<cfset details = details & variables.newline & arguments.thrown.sql />
		</cfif>
		
		<!--- if this is something other than a simple assertion failure, add more detail for the plugin to display: --->
		<cfif listFirst(arguments.thrown.type,".") is not "AssertionFailedError">
			<cfset exceptionType = exceptionType & ":" & arguments.thrown.type />
			<cfset iterator = arguments.thrown.tagContext.iterator() />
			<cfloop condition="#iterator.hasNext()#">
				<cfset context = iterator.next()>
				<cfset details = details & variables.newline & context.template & ":" & context.line />
			</cfloop>
		</cfif>
		
		<!--- finally, stuff everything into the buffer that we will eventually output to the plugin: --->
		<cfset variables.buffer = variables.buffer & "#exceptionType##variables.newline##message##details##variables.newline#" />
		
	</cffunction>

</cfcomponent>
