<cfcomponent>
<!---

  ClosureFactory.cfc - Closures for ColdFusion
 
  Copyright (c) 2006, Sean Corfield
  
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

	<cfset variables.cache = structNew() />

	<cffunction name="new" returntype="Closure" access="public" output="false" 
				hint="I create a new closure object based on a code block or function and an optional argument specification">
		<cfargument name="block" type="any" required="true" 
					hint="I am either a code block (a string) or a function/UDF" />
		<cfargument name="args" type="string" default="" 
					hint="I am an optional argument specification - only useful for a code block" />
		
		<cfif isCustomFunction(arguments.block)>
			<cfreturn makeClosureFromFunction(arguments.block) />
		<cfelseif isSimpleValue(arguments.block)>
			<cfreturn makeClosureFromString(arguments.block,arguments.args) />
		<cfelse>
			<cfthrow type="CLOSURE.NEW.BAD_BLOCK" message="Illegal argument for ClosureFactory.new()" 
					detail="The argument 'block' passed to ClosureFactory.new() must either be a function or a string containing code." />
		</cfif>
		
	</cffunction>
	
	<cffunction name="makeClosureFromFunction" returntype="Closure" access="private" output="false" 
				hint="I make a closure from a function/UDF">
		<cfargument name="function" type="any" required="true" hint="I am a function/UDF" />
		
		<cfreturn createObject("component","Closure").init(arguments.function) />
		
	</cffunction>
	
	<cffunction name="makeClosureFromString" returntype="Closure" access="private" output="false" 
				hint="I make a closure from a code block string by writing a function to disk and including it back in">
		<cfargument name="codeString" type="string" required="true" hint="I am a code block (string)" />
		<cfargument name="args" type="string" required="true" hint="I am an optional argument specification" />
		
		<cfset var code = trim(arguments.codeString) />
		<cfset var functionName = "" />
		<cfset var filePath = "" />
		<cfset var closure = 0 />
		<cfset var argName = "" />
		<cfset var bareArgName = "" />
		<cfset var bareArgType = "" />
		<cfset var cfArgs = "" />
		<cfset var key = code & "|" & arguments.args />

		<!--- don't construct the closure if we already made it: --->
		<cfif isInCache(key)>
			<cfreturn getFromCache(key) />
		<cfelse>
		
			<!--- synthesize a unique function name: --->
			<cfset functionName = "_" & replace(createUUID(),"-","","all") />
			<cfset filePath = getDirectoryFromPath(getCurrentTemplatePath()) & functionName />
	
			<!--- if the code seems to be script code, wrap it in a cfscript tag: --->
			<cfif left(code,1) is not '<'>
				<!--- if the code appears to be just an expression, wrap it in a return statement: --->
				<cfif find(";",code) eq 0 and findNoCase("return",code) eq 0>
					<cfset code = "return #code# ;" />
				</cfif>
				<cfset code = "<cfscript> #code# </cfscript>" />
			</cfif>
			
			<!--- add cfargument tags for any specified arguments: --->
			<cfloop list="#arguments.args#" index="argName">
				<cfif listLen(argName,":") eq 2>
					<!--- it has a type specification --->
					<cfset bareArgName = listFirst(argName,":") />
					<cfset bareArgType = listLast(argName,":") />
				<cfelse>
					<!--- just an untyped argument --->
					<cfset bareArgName = argName />
					<cfset bareArgType = "any" />
				</cfif>
				<cfset cfArgs = cfArgs & '<cfargument name="#trim(bareArgName)#" type="#trim(bareArgType)#" required="true" /> ' />
			</cfloop>
			
			<cfset code = cfArgs & code />
			<cfset code = '<' & 'cffunction name="#functionName#"> #code# </' & 'cffunction>' />
			
			<cflock name="#filePath#" type="exclusive" timeout="30">
	
				<cffile action="write" file="#filePath#" output="#code#" />
				
				<!--- this adds the function to this closure factory... --->
				<cfinclude template="#functionName#" />
				<!--- ...so make a closure from the new local private method... --->
				<cfset closure = makeClosureFromFunction(variables[functionName]) />
				<!--- ...add it to the cache to make subsequent uses of the same code block faster... --->
				<cfset addToCache(key,closure) />
				<!--- ...and finally remove the local private method --->
				<cfset structDelete(variables,functionName) />
	
				<cffile action="delete" file="#filePath#" />

			</cflock>

		</cfif>		

		<cfreturn closure />

	</cffunction>
	
	<cffunction name="isInCache" returntype="boolean" access="private" output="false" 
				hint="I return true if the specified code block is already in the cache">
		<cfargument name="key" type="string" required="true" hint="I am the text of a code block" />
		
		<cfset var inCache = false />
		
		<cflock name="#application.ApplicationName#_#arguments.key#" type="readonly" timeout="30">
			<cfset inCache = structKeyExists(variables.cache,arguments.key) />
		</cflock>
		
		<cfreturn inCache />
		
	</cffunction>
	
	<cffunction name="getFromCache" returntype="any" access="private" output="false" 
				hint="I return a closure from the cache">
		<cfargument name="key" type="string" required="true" hint="I am the text of a code block" />
		
		<cfset var item = 0 />
		
		<cflock name="#application.ApplicationName#_#arguments.key#" type="readonly" timeout="30">
			<cfset item = variables.cache[arguments.key] />
		</cflock>
		
		<cfreturn item />
		
	</cffunction>
	
	<cffunction name="addToCache" returntype="void" access="private" output="false" 
				hint="I add a code block and its matching closure to the cache">
		<cfargument name="key" type="string" required="true" hint="I am the text of a code block" />
		<cfargument name="value" type="any" required="true" hint="I am a closure made from that code block" />
		
		<cflock name="#application.ApplicationName#_#arguments.key#" type="exclusive" timeout="30">
			<cfset variables.cache[arguments.key] = arguments.value />
		</cflock>
	
	</cffunction>
	
</cfcomponent>