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

	<!--- create Sun's JRuby engine: --->
	<cfset factory = createObject("java","com.sun.script.jruby.JRubyScriptEngineFactory").init() />
	<cfset engine = factory.getScriptEngine() />
	<!--- we don't both with a writer because JRuby writes to System.out directly :( --->

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
	<cfset result = engine.eval(thisTag.generatedContent) />
	
	<!--- Ruby returns the last expression which may be null: --->
	<cfif isDefined("result")>
		<cfset thisTag.generatedContent = result />
	<cfelse>
		<cfset thisTag.generatedContent = "" />
	</cfif>
	
</cfif>