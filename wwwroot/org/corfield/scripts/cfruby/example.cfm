<!---

  examples.cfm - Ruby for ColdFusion 8
 
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
	
	1. Copy lib/*.jar to WEB-INF/cfusion/lib/
	2. Restart ColdFusion 8.
	3. Optionally copy customtags/ruby.cfm into your custom tags path.
	
	This example should run in place without step 3.
	
	Usage:
	
	<cf_ruby> your Ruby code code goes here </cf_ruby>
	
	The output of the tag is the last expression executed in the Ruby code.
	print and puts (in Ruby) simple writes to the console (so if you started
	ColdFusion from the command line, you'll see Ruby output intermixed there).
	
	Ruby code has access to the following global variables that map to certain
	scopes in your ColdFusion code:
	- $coldfusion["varname"] - ColdFusion's variables.varname in the calling page
	- $session["varname"]    - ColdFusion's session.varname
	- $url["varname"]        - ColdFusion's URL.varname
	- $form["varname"]       - ColdFusion's form.varname
	- $cgi["varname"]        - ColdFusion's CGI.varname
	
	Assignments to variables in those Ruby 'scopes' will be reflected in the
	ColdFusion page after the tag has executed.

--->

<cfimport prefix="script" taglib="customtags" />

<cfset session.marker = "Hi, I'm a session variable!" />
<cfset who = "Sean" />
<cftimer label="Executing Ruby" type="outline">
	<script:ruby>
		# since we need to return the last expression in the script
		# we run other code first, unless the PHP example:
		
		# set a page level variable in ColdFusion:
		$coldfusion["greeting"] = "wibble"
		# read a URL variable and set a session variable in ColdFusion:
		$test = $url["test"]
		if $test then
			$session["what"] = $url["test"]
		else
			$session["what"] = "test was not passed as a URL variable"
		end
		
		# this builds a single string which is the result of the script:
		"Hi " + $coldfusion["who"] + "<br />" +
		$session["marker"] + "<br />" +
		($test ? $test : "") + "<br />" +
		$cgi["SCRIPT_FILENAME"] + "<br />"
	</script:ruby>
</cftimer>
<cftimer label="Executing Ruby with a class" type="outline">
	<script:ruby>
		class Person
			def initialize(firstName,lastName)
				@firstName = firstName
				@lastName = lastName
			end
			attr_reader :firstName, :lastName
		end
		people = [
			Person.new("Ben","Forta"),
			Person.new("Jason","Delmore"),
			Person.new("Tim","Buntel")
		]
		people.collect {
			|person|
			person.firstName + " " + person.lastName + " rocks!<br />"
		}
	</script:ruby>
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
