<!---
	Copyright 2005 Sean A Corfield http://corfield.org/
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	 
		http://www.apache.org/licenses/LICENSE-2.0
	 
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
	
	Release 1.2 2005-05-15 See README for details.
--->
<cfcomponent name="Callable" hint="I am the Java 5 style interface for 'future' callable objects. I am deprecated.">

	<!--- call() : any --->
	<cffunction name="call" returntype="any" access="public" output="false" 
				hint="Implement me in your code. I am called asynchronously when a FutureTask is run().">
		<cfthrow type="CALLABLE.UNIMPLEMENTED" message="Callable call() unimplemented"
				 detail="The method call() was not implemented in a child of Callable." />
	</cffunction>
	
</cfcomponent>
