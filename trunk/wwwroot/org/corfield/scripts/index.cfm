<!---

  index.cfm - Scripting for ColdFusion 8
 
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

<h1>Welcome to Scripting for ColdFusion 8</h1>

<p>This is a collection of custom tags and libraries that allow you to run
	a variety of scripting languages directly inside ColdFusion.</p>

<p>This package <strong>requires Java 6</strong> (which is why it requires
	ColdFusion 8). Java 6 introduced the 
	<a href="http://java.sun.com/javase/6/docs/api/javax/script/package-summary.html" 
		target="_blank">javax.script.* package</a> that allows scripting
	languages to be hosted within a Java application. Naturally that allows
	us to host these scripting languages within ColdFusion as well.</p>

<p>Currently, the following languages have been implemented:</p>
<ul>
	<li>PHP - run the <a href="cfphp/example.cfm">PHP example</a>.</li>
	<li>Ruby - run the <a href="cfruby/example.cfm">Ruby example</a>.</li>
</ul>

<p>For more information, read the <a href="http://scripting.riaforge.org/wiki/"
		target="_blank">documentation on the wiki</a>.</p>