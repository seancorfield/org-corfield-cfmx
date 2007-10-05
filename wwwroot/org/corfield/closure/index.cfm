<!---

  index.cfm - Closures for ColdFusion
 
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

<!---
	This file is both the unit test suite and a set of examples of how
	to use the Closures for ColdFusion library, as well as the new Collection class.
	
--->

<p>Creating ClosureFactory...</p>
<!--- you would typically put this in application scope: --->
<cfset cf = createObject("component","ClosureFactory") />

<p>Running Closure Tests...</p>
<cfinclude template="closure_test.cfm" />

<cfif left(server.ColdFusion.ProductName,10) is "ColdFusion" and listFirst(server.ColdFusion.ProductVersion) gte 8>
	<p>Running Collection Class Tests...</p>
	<cfinclude template="collection_test.cfm" />
<cfelse>
	<p>The Collection Class requires ColdFusion 8!</p>
</cfif>
