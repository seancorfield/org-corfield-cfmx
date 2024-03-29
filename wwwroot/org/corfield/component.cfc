<cfsilent>
<!---

  component.cfc - Universal Base Class for ColdFusion
 
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

  dump() and throw() are just convenience methods

  onMissingMethod() implements automatic get/set methods on all
    components (with no security checking, just uses variables scope)

  call() provides a way to call an arbitrary method by name on an object
    passing arguments in a struct by name or positionally which makes it
    it easier to use onMissingMethod() to create smart proxies

  getFunctionMetadata() provides a high-performance way to get metadata
    by name for a function in the *current* object, used by call()

--->

	<cffunction name="dump" magic="true">
		<cfargument name="var" />
		<cfargument name="label" default="" />
		<cfargument name="output" default="browser" />
		
		<cfif not structKeyExists(arguments,"var")>
			<cfset arguments.var = variables />
			<cfif arguments.label is "">
				<cfset arguments.label = getMetadata(this).name />
			</cfif>
		</cfif>

		<cfdump attributeCollection="#arguments#" />
		
	</cffunction>

	<cffunction name="throw" magic="true">
		<cfargument name="type" default="" />
		<cfargument name="message" default="" />
		<cfargument name="detail" default="" />
		
		<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#" />
		
	</cffunction>
	
	<cffunction name="call" magic="true">
		<cfargument name="method" type="string" />
		<cfargument name="args" type="struct" default="#structNew()#" />
		
		<cfset var result = 0 />
		<cfset var md = 0 />
		<cfset var i = 0 />
		<cfset var n = 0 />
		
		<cfif structKeyExists(arguments.args,1)>
			<!--- unnamed arguments - we need to map to named arguments --->
			<cfset md = getFunctionMetadata(arguments.method) />
			<cfif structKeyExists(md,"parameters")>
				<cfset n = arraylen(md.parameters) />
				<cfloop index="i" from="1" to="#n#">
					<cfif structKeyExists(arguments.args,i)>
						<cfset arguments.args[md.parameters[i].name] = arguments.args[i] />
					</cfif>
				</cfloop>
			</cfif>
		</cfif>

		<cfinvoke component="#this#" method="#arguments.method#" argumentcollection="#arguments.args#" returnvariable="result" />
		
		<cfif isDefined("result")>
			<cfreturn result />
		</cfif>
		
	</cffunction>
	
	<cffunction name="getFunctionMetadata" magic="true">
		<cfargument name="method" type="string" />
		
		<cfset var md = getMetadata(this) />
		<cfset var i = 0 />
		<cfset var n = 0 />
		
		<cfif not structKeyExists(md,"functionsbyname")>
			<cflock name="md_#md.name#_functionsbyname" type="exclusive" timeout="10">
				<cfif not structKeyExists(md,"functionsbyname")>
					<cfset md.functionsbyname = structNew() />
				</cfif>
			</cflock>
		</cfif>
		
		<cfif not structKeyExists(md.functionsbyname,arguments.method)>
			<cflock name="md_#md.name#_fn_#arguments.method#" type="exclusive" timeout="10">
				<cfif not structKeyExists(md.functionsbyname,arguments.method)>
					<cfset md.functionsbyname[arguments.method] = getMetadata(this[arguments.method]) />
				</cfif>
			</cflock>
		</cfif>
		
		<cfreturn md.functionsbyname[arguments.method] />
	
	</cffunction>

	<cffunction name="onMissingMethod" magic="true">
		<cfargument name="missingMethodName" />
		<cfargument name="missingMethodArguments" />

		<cfset var name = "" />

		<cfif left(missingMethodName,3) is "get">

			<cfset name = right(missingMethodName,len(missingMethodName)-3) />
			<cfif structKeyExists(variables,name)>
				<cfreturn variables[name] />
			<cfelse>
				<cfthrow type="Expression_"
					message="Element #name# is undefined in a Java object of type class coldfusion.runtime.TemplateProxy." />
			</cfif>

		<cfelseif left(missingMethodName,3) is "set">

			<cfset name = right(missingMethodName,len(missingMethodName)-3) />
			<cfif structCount(missingMethodArguments) gte 1>
				<cfset variables[name] = missingMethodArguments[1] />
			<cfelse>
				<cfthrow type="Application"
					message="The #uCase(name)# parameter to the get#name# function is required but was not passed in." />
			</cfif>
			
		<cfelse>

			<cfthrow type="Application"
				message="The method #missingMethodName# was not found in component #expandPath('/' & replace(getMetadata(this).name,'.','/','all'))#"
				detail="Ensure that the method is defined, and that it is spelled correctly." />

		</cfif>

	</cffunction>

</cfsilent>