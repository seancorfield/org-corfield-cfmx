<!---

  php.cfm - PHP for ColdFusion 8
 
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
		<cfthrow type="PHP" message="No end tag" detail="The php custom tag must have an end tag." />
	</cfif>

<cfelse>

	<!--- create Quercus engine and script cache: --->
	<cfif not structKeyExists(application,"__scripting") or 
			not structKeyExists(application.__scripting,"php") or
			not structKeyExists(application.__scripting.php,"cache") or
			structKeyExists(URL,"refreshScriptCache")>
		<cflock name="#application.applicationName#__scripting__php" timeout="300" type="exclusive">
			<cfif not structKeyExists(application,"__scripting") or 
					not structKeyExists(application.__scripting,"php") or
					not structKeyExists(application.__scripting.php,"cache") or
					structKeyExists(URL,"refreshScriptCache")>

				<cfset php = structNew() />
				<cfset php.cache = structNew() />
				<cfset php.factory = createObject("java","com.caucho.quercus.script.QuercusScriptEngineFactory").init() />
				<cfset application.__scripting.php = php />

			</cfif>
		</cflock>
	</cfif>
	
	<cfset script = thisTag.generatedContent />
	<cfset scriptKey = script />
	<cfset hashValue = hash(scriptKey) />
	
	<!--- because we cache the engine and script in application scope, we need to single thread execution per block: --->
	<cflock name="#application.applicationName#__scripting__php__#hashValue#" timeout="300" type="exclusive">
		<cfif not structKeyExists(application.__scripting.php.cache,scriptKey)>

			<!--- compile the PHP code: --->
			<cfset engine = application.__scripting.php.factory.getScriptEngine() />			
			<cfset code = engine.compile(thisTag.generatedContent) />
			<cfset application.__scripting.php.cache[scriptKey] = code />

		</cfif>
	
		<cfset code = application.__scripting.php.cache[scriptKey] />
	
		<cfset engine = code.getEngine() />
		<!--- create coldfusion variable in PHP for calling page: --->
		<cfset engine.put("_COLDFUSION",caller) />
	
		<!--- TODO: this is a hack right now - _GET, _POST and _SERVER do not work: --->
		<cfset engine.put("GET",URL) />
		<cfset engine.put("POST",form) />
		<cfset engine.put("SERVER",CGI) />
<!--- 
		<cfset engine.put("_GET",URL) />
		<cfset engine.put("_POST",form) />
		<cfset engine.put("_SERVER",CGI) />
 --->
		<!--- connect session scope if available: --->
		<cftry>
			<cfset engine.put("_SESSION",session) />
		<cfcatch />
		</cftry>
	
		<!--- need to create a unique writer for each code block: --->
		<cfset writer = createObject("java","java.io.StringWriter").init() />
		<cfset engine.getContext().setWriter(writer) />
	
		<cfset code.eval() />
		
		<!--- extract the PHP output buffer: --->
		<cfset thisTag.generatedContent = writer.toString() />
		
	</cflock>

</cfif>