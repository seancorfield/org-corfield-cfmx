<!---

  ruby.cfm - Ruby for ColdFusion 8
 
  Copyright (c) 2007, Sean Corfield
  
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

<cfif thisTag.executionMode is "start">

	<cfif not thisTag.hasEndTag>
		<cfthrow type="Ruby" message="No end tag" detail="The ruby custom tag must have an end tag." />
	</cfif>

<cfelse>

	<!--- create Sun's JRuby engine and script cache: --->
	<cfif not structKeyExists(application,"__scripting") or 
			not structKeyExists(application.__scripting,"ruby") or
			not structKeyExists(application.__scripting.ruby,"cache") or
			structKeyExists(URL,"refreshScriptCache")>
		<cflock name="#application.applicationName#__scripting__ruby" timeout="300" type="exclusive">
			<cfif not structKeyExists(application,"__scripting") or 
					not structKeyExists(application.__scripting,"ruby") or
					not structKeyExists(application.__scripting.ruby,"cache") or
					structKeyExists(URL,"refreshScriptCache")>

				<cfset ruby = structNew() />
				<cfset ruby.cache = structNew() />
				<cfset ruby.factory = createObject("java","com.sun.script.jruby.JRubyScriptEngineFactory").init() />
				<cfset application.__scripting.ruby = ruby />

			</cfif>
		</cflock>
	</cfif>
	
	<cfset script = thisTag.generatedContent />
	<cfset scriptKey = script />
	<cfset hashValue = hash(scriptKey) />
	
	<!--- because we cache the engine and script in application scope, we need to single thread execution per block: --->
	<cflock name="#application.applicationName#__scripting__ruby__#hashValue#" timeout="300" type="exclusive">
		<cfif not structKeyExists(application.__scripting.ruby.cache,scriptKey)>

			<!--- compile the Ruby code: --->
			<cfset engine = application.__scripting.ruby.factory.getScriptEngine() />			
			<cfset code = engine.compile(thisTag.generatedContent) />
			<cfset application.__scripting.ruby.cache[scriptKey] = code />

		</cfif>
	
		<cfset code = application.__scripting.ruby.cache[scriptKey] />
	
		<cfset engine = code.getEngine() />
		<!--- create coldfusion variable in Ruby for calling page: --->
		<cfset engine.put("coldfusion",caller) />
	
		<!--- wire in URL, form and CGI scopes: --->
		<cfset engine.put("url",URL) />
		<cfset engine.put("form",form) />
		<cfset engine.put("cgi",CGI) />
	
		<!--- connect session scope if available: --->
		<cftry>
			<cfset engine.put("session",session) />
		<cfcatch />
		</cftry>
	
		<!--- execute the Ruby code and get the result: --->
		<cfset result = code.eval() />
		
		<!--- Ruby returns the last expression which may be null: --->
		<cfif isDefined("result")>
			<cfset thisTag.generatedContent = result />
		<cfelse>
			<cfset thisTag.generatedContent = "" />
		</cfif>
		
	</cflock>
	
</cfif>