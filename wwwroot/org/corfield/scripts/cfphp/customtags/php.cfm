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

	<!--- create Quercus engine and setup output buffer: --->
	<cfset factory = createObject("java","com.caucho.quercus.script.QuercusScriptEngineFactory").init() />
	<cfset engine = factory.getScriptEngine() />
	<cfset writer = createObject("java","java.io.StringWriter").init() />
	<cfset engine.getContext().setWriter(writer) />

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

	<!--- wrap PHP code with <?php ... ?> if necessary: issue 4 --->
	<cfset code = trim(thisTag.generatedContent) />
	<cfif left(code,5) is not "<?php">
		<cfset code = "<?php #code# ?>" />
	</cfif>
	<!--- execute the PHP code: --->	
	<cfset engine.eval(code) />
	
	<!--- extract the PHP output buffer: --->
	<cfset thisTag.generatedContent = writer.toString() />
	
</cfif>