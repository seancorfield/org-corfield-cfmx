<!---
 
  Copyright (c) 2008, Sean Corfield
  
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

<cfcomponent implements="ICommand" output="false">

	<cffunction name="init" returntype="any" access="public" output="false" hint="">
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="handleEvent" returntype="boolean" access="public" output="false" hint="">
		<cfargument name="event" type="edmund.framework.Event" required="true" />

		<cfreturn true />
		
	</cffunction>

</cfcomponent>