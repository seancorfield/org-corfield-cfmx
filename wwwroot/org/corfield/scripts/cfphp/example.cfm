<!---

  examples.cfm - PHP for ColdFusion 8
 
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

<!---

	Installation:
	
	1. Copy lib/quercus.jar and lib/resin-util.jar to WEB-INF/cfusion/lib/
	2. Restart ColdFusion 8.
	3. Optionally copy customtags/php.cfm into your custom tags path.
	
	This example should run in place without step 3.
	
	Usage:
	
	<cf_php> your PHP code code goes here </cf_php>
	
	The output of the tag is the output of the executed PHP code.
	
	The PHP code can use $_COLDFUSION["varname"] to access ColdFusion variables
	in the calling page scope and $_SESSION["varname"] to access ColdFusion's
	session scope variables.
	
	Currently, the standard PHP variables $_GET, $_POST, $_SERVER and $_GLOBALS
	are not correctly supported. You can use the following similar names:
	- $GET["varname"]    - ColdFusion's URL.varname
	- $POST["varname"]   - ColdFusion's form.varname
	- $SERVER["varname"] - ColdFusion's CGI.varname
	
	Assignments to variables in those PHP 'scopes' will be reflected in the
	ColdFusion page after the tag has executed.

--->

<cfimport prefix="script" taglib="customtags" />

<cfset session.marker = "Hi, I'm a session variable!" />
<cfset who = "Sean" />
<cftimer label="Executing PHP" type="outline">
	<!--- <?php ... ?> is optional --->
	<script:php>
		/* read a variable from ColdFusion: */
		echo "Hello ".$_COLDFUSION["who"]."<br />";
		
		/* read a session variable from ColdFusion: */
		echo $_SESSION["marker"]."<br />";

		/* read a URL variable from ColdFusion - should be: $_GET["test"] */
		$test = $GET["test"];
		echo $test."<br />";
		
		/* read a CGI variables from ColdFusion - should be: $_SERVER["SCRIPT_FILENAME"] */
		echo $SERVER["SCRIPT_FILENAME"]."<br />";
		
		/* set a couple of ColdFusion variables: */
		$_COLDFUSION["greeting"] = "wibble";
		if ($test) {
			$_SESSION["what"] = $test;
		} else {
			$_SESSION["what"] = "test was not passed as a URL variable";
		}
	</script:php>
</cftimer>
<cfoutput>
	<p>
		greeting = #greeting#<br />
		<cfif structKeyExists(session,"what")>what = #session.what#<br /></cfif>
		<a href="?test=foo">Click me</a> to test URL variables.
	</p>
	<cffile action="read" file="#getCurrentTemplatePath()#" variable="source" />
<pre>
#htmlEditFormat(source)#
</pre>
</cfoutput>
