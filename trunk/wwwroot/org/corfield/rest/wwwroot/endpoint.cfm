<cfsilent>
<!---
/*************************************************************************
*
* Adobe Systems Incorporated Source Code License Agreement
* Copyright (c) 2005-2006 Adobe Systems Incorporated. All rights reserved.
* 
* Please read this Source Code License Agreement carefully before using
* the source code.
* 
* Adobe Systems Incorporated grants to you a perpetual, worldwide,
* non-exclusive, no-charge, royalty-free, irrevocable copyright license,
* to reproduce, prepare derivative works of, publicly display, publicly
* perform, and distribute this source code and such derivative works in
* source or object code form without any attribution requirements.
* 
* The name "Adobe Systems Incorporated" must not be used to endorse or
* promote products derived from the source code without prior written
* permission.
* 
* You agree to indemnify, hold harmless and defend Adobe Systems
* Incorporated from and against any loss, damage, claims or lawsuits,
* including attorney's fees that arise or result from your use or
* distribution of the source code.
* 
* THIS SOURCE CODE IS PROVIDED "AS IS" AND "WITH ALL FAULTS", WITHOUT ANY
* TECHNICAL SUPPORT OR ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT
* NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
* FOR A PARTICULAR PURPOSE ARE DISCLAIMED. ALSO, THERE IS NO WARRANTY OF
* NON-INFRINGEMENT, TITLE OR QUIET ENJOYMENT. IN NO EVENT SHALL ADOBE OR
* ITS SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOURCE CODE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
*
**************************************************************************/
	
	REST endpoint for all remote services
	
	How this works:
		POST an XML packet to http://server/path/endpoint.cfc?method=rest
	The packet can be passed as either the payload= HTTP parameter or as
	the content of a raw HTTP POST.
	
	The packet specifies the CFC and method to invoke as well as the
	arguments to deserialize and pass to that method:
		<componentname operation="methodname">
			<arg1name>somevalue</arg1name>
			<arg2name>somevalue</arg2name>
			<arg3name>somevalue</arg3name>
		</component>
	
	The result has one of two formats:
		<result> somevalue </result>
	or:
		<fault>
			<type> exceptiontype </type>
			<message> exceptionmessage </message>
			<detail> exceptiondetail </detail>
			<extendedinfo> exceptionextendedinfo </extendedinfo>
		</fault>
	
	The component name is specified as a fully-qualified dot-separated path,
	e.g., trialthrottleservice.trialthrottlefacade
	Any component can be used as long as it has remote methods (since it
	would be callable via Flash Remoting and/or Web Services already).
		
	The format of serialized data is as follows (taken, essentially, from
	the ColdSpring/Spring approach for bean values):
	
	simple value:
		<value>thevalue</value>
	array of values:
		<list> somevalue somevalue somevalue </list>
	struct of values:
		<map>
			<entry key="somekey"> somevalue </entry>
		</map>
	component value:
		<bean class="dot.separated.cfc.name">
			<property name="somekey"> somevalue </property>
		</bean>
--->

	<cffunction name="rest" returntype="xml" access="remote" output="false"
				hint="I provide a simple REST adapter for any remote components.">
		<cfargument name="payload" 
					hint="I am the optional XML payload argument that defines the operation to be performed. I can be passed explicitly as a POST form field or as a GET query argument, or implicitly as raw POST data" />
		
		<cfset var result = "" />
		<cfset var xmlPayload = 0 />
		<cfset var args = 0 />
		<cfset var i = 0 />
		<cfset var n = 0 />
		<cfset var argCollection = structNew() />
		<cfset var component = "" />
		<cfset var method = "" />
		<cfset var obj = 0 />
		<cfset var methodFound = false />
		<cfset var md = 0 />
		<cfset var fn = 0 />
		
		<cftry>
		
			<cftry>
				<cfset xmlPayload = xmlParse(arguments.payload) />
			<cfcatch type="any">
				<cfthrow type="REST" message="XML payload invalid" 
						detail="#cfcatch.type# : #cfcatch.message#" 
						extendedinfo="#cfcatch.detail# : #cfcatch.extendedinfo# : #arguments.payload#" />
			</cfcatch>
			</cftry>
			
			<cfset component = xmlPayload.xmlRoot.xmlName />

			<cfif structKeyExists(xmlPayload.xmlRoot.xmlAttributes,"operation")>
				<cfset method = xmlPayload.xmlRoot.xmlAttributes.operation />
			<cfelse>
				<cfthrow type="REST" message="operation not specified" 
						detail="The operation attribute is required on the root element of the payload."
						extendedinfo="#arguments.payload#" />
			</cfif>

			<cfset args = xmlPayload.xmlRoot.xmlChildren />
			<cfset n = arrayLen(args) />
			<cfloop from="1" to="#n#" index="i">
				<cfif arrayLen(args[i].xmlChildren) eq 1>
					<cfset argCollection[args[i].xmlName] = deserialize(args[i].xmlName,args[i].xmlChildren[1]) />
				<cfelse>
					<cfthrow type="REST" message="Argument invalid"
							detail="The argument #args[i].xmlName# does not have a single child value" />
				</cfif>
			</cfloop>

			<cftry>
				<cfset obj = createObject("component",component) />
			<cfcatch type="any">
				<cfthrow type="REST" message="Component name invalid" 
						detail="#cfcatch.type# : #cfcatch.message#" 
						extendedinfo="#cfcatch.detail# : #cfcatch.extendedinfo# : #component#" />
			</cfcatch>
			</cftry>

			<cfif structKeyExists(obj,method)>
				<cfset md = getMetadata(obj) />
				<cfif structKeyExists(md,"functions")>
					<cfset count = arrayLen(md.functions) />
					<cfloop from="1" to="#count#" index="i">

						<cfif method is md.functions[i].name>
							<cfif structKeyExists(md.functions[i],"access") and
									md.functions[i].access is "remote">
								<cfset methodFound = true />
							</cfif>
							<cfbreak />
						</cfif>

					</cfloop>
				</cfif>
				<cfif not methodFound>
					<cfthrow type="REST" message="Operation name invalid"
							detail="The component #component# does not have a remote method #method#" />
				</cfif>

				<cfinvoke component="#obj#" method="#method#" argumentcollection="#argCollection#" returnvariable="result" />

			<cfelse>
				<cfthrow type="REST" message="Operation name invalid"
						detail="The component #component# does not have a remote method #method#" />
			</cfif>

			<cfset result = "<result>#serialize(result)#</result>" />

		<cfcatch type="any">
			<cfset result = makeFaultXml(cfcatch) />
		</cfcatch>
		</cftry>
		
		<cfreturn result />
		
	</cffunction>
	
	<cffunction name="serialize" access="private" output="false" 
				hint="I serialize a ColdFusion value to a simple XML format.">
		<cfargument name="value" hint="I am the value to be serialized." />
		
		<cfset var result = "" />
		<cfset var key = "" />
		<cfset var count = 0 />
		<cfset var i = 0 />
		<cfset var md = 0 />
		<cfset var intermediate = 0 />
		
		<cfif isSimpleValue(arguments.value)>
			<cfset result = "<value>#arguments.value#</value>" />

		<cfelseif isObject(arguments.value)>
			<cfset md = getMetadata(arguments.value) />
			<cfif structKeyExists(md,"properties")>
				<cfset count = arrayLen(md.properties) />
				<cfloop from="1" to="#count#" index="i">
					<cfif structKeyExists(arguments.value,md.properties[i].name)>
						<cfset result = result & "<property name=""#md.properties[i].name#"">#serialize(arguments.value[md.properties[i].name])#</property>" />
					<cfelseif structKeyExists(arguments.value,"get#md.properties[i].name#") and
								isCustomFunction(arguments.value["get#md.properties[i].name#"])>
						<cftry>
							<cfinvoke component="#arguments.value#" method="get#md.properties[i].name#" returnvariable="intermediate" />
						<cfcatch type="any">
							<cfthrow type="REST" message="Cannot get property value" 
									detail="Unable to call get#md.properties[i].name#() on result value"
									extendedinfo="Result type is #getMetadata(arguments.value).name#" />						
						</cfcatch>
						</cftry>
						<cfset result = result & "<property name=""#md.properties[i].name#"">#serialize(intermediate)#</property>" />
					</cfif>
				</cfloop>
			</cfif>
			<cfset result = "<bean classpath=""#md.name#"">#result#</bean>" />

		<cfelseif isStruct(arguments.value)>
			<cfloop collection="#arguments.value#" item="key">
				<cfset result = result & "<entry key=""#key#"">#serialize(arguments.value[key])#</entry>" />
			</cfloop>
			<cfset result = "<map>#result#</map>" />

		<cfelseif isArray(arguments.value)>
			<cfset count = arrayLen(arguments.value) />
			<cfloop from="1" to="#count#" index="i">
				<cfset result = result & serialize(arguments.value[i]) />
			</cfloop>
			<cfset result = "<list>#result#</list>" />

		<cfelse>
			<cfthrow type="REST" message="No serializer for type" 
					detail="Value is not simple value, struct, array or value object"
					extendedinfo="Result type is #getMetadata(arguments.value).name#" />
		</cfif>
		
		<cfreturn result />
		
	</cffunction>
	
	<cffunction name="deserialize" access="private" output="false" 
				hint="I deserialize a simple XML format back to native ColdFusion values.">
		<cfargument name="argName" 
					hint="I am the name of the argument being deserialized (for error reporting purposes)." />
		<cfargument name="value" 
					hint="I am the XML object to be deserialized." />
		
		<cfset var result = 0 />
		<cfset var count = 0 />
		<cfset var i = 0 />
		<cfset var args = 0 />
		
		<cfswitch expression="#arguments.value.xmlName#">

		<cfcase value="value">
			<cfset result = trim(arguments.value.xmlText) />
		</cfcase>

		<cfcase value="map">
			<cfset result = structNew() />
			<cfset count = arrayLen(arguments.value.xmlChildren) />
			<cfloop from="1" to="#count#" index="i">
				<cfif arguments.value.xmlChildren[i].xmlName is not "entry">
					<cfthrow type="REST" message="Invalid map element" 
							detail="Argument #arguments.argName# map contains illegal entry #arguments.value.xmlChildren[i].xmlName#" />
				</cfif>
				<cfif not structKeyExists(arguments.value.xmlChildren[i].xmlAttributes,"key")>
					<cfthrow type="REST" message="Invalid map element" 
							detail="Argument #arguments.argName# map contains an entry with no key" />
				</cfif>
				<cfif arrayLen(arguments.value.xmlChildren[i].xmlChildren) neq 1>
					<cfthrow type="REST" message="Invalid map element" 
							detail="Argument #arguments.argName# map contains an entry #arguments.value.xmlChildren[i].xmlAttributes.key# that does not have a single child value" />
				</cfif>
				<cfset result[arguments.value.xmlChildren[i].xmlAttributes.key] = 
						deserialize(arguments.argName,arguments.value.xmlChildren[i].xmlChildren[1]) />
			</cfloop>
		</cfcase>

		<cfcase value="list">
			<cfset result = arrayNew(1) />
			<cfset count = arrayLen(arguments.value.xmlChildren) />
			<cfloop from="1" to="#count#" index="i">
				<cfset result[i] = deserialize(arguments.argName,arguments.value.xmlChildren[i]) />
			</cfloop>
		</cfcase>

		<cfcase value="bean">
			<!--- bean classpath="path.to.cfc" --->
			<cfif not structKeyExists(arguments.value.xmlAttributes,"classpath")>
				<cfthrow type="REST" message="No classpath for bean"
						detail="Argument #arguments.argName# is a bean with no classpath" />
			</cfif>
			<cftry>
				<cfset result = createObject("component",arguments.value.xmlAttributes.classpath) />
			<cfcatch type="any">
				<cfthrow type="REST" message="Invalid classpath for bean" 
						detail="Argument #arguments.argName# is a bean with an invalid classpath #arguments.value.xmlAttributes.classpath#" 
						extendedinfo="#cfcatch.message# : #cfcatch.detail# : #cfcatch.extendedinfo#" />
			</cfcatch>
			</cftry>
			<!--- may have <property> tags inside --->
			<cfset count = arrayLen(arguments.value.xmlChildren) />
			<cfloop from="1" to="#count#" index="i">
				<!--- should call setXxx() if present for each, else store in the public scope --->
				<cfif arguments.value.xmlChildren[i].xmlName is "property">
					<cfif structKeyExists(arguments.value.xmlChildren[i].xmlAttributes,"name")>
						<cfif arrayLen(arguments.value.xmlChildren[i].xmlChildren) neq 1>
							<cfthrow type="REST" message="Invalid bean property element" 
									detail="Argument #arguments.argName# bean contains a property #arguments.value.xmlChildren[i].xmlAttributes.name# that does not have a single child value" />
						</cfif>
						<cfif structKeyExists(result,"set#arguments.value.xmlChildren[i].xmlAttributes.name#")>
							<cfset args = structNew() />
							<cfset args[arguments.value.xmlChildren[i].xmlAttributes.name] = deserialize(arguments.argName,arguments.value.xmlChildren[i].xmlChildren[1]) />
							<cftry>
								<cfinvoke component="#result#" method="set#arguments.value.xmlChildren[i].xmlAttributes.name#" argumentcollection="#args#" />
							<cfcatch type="any">
								<cfthrow type="REST" message="Unable to set property" 
										detail="Argument #arguments.argName# bean contains a property #arguments.value.xmlChildren[i].xmlAttributes.name# for which the setter method cannot be called"
										extendedinfo="#cfcatch.message# : #cfcatch.detail# : #cfcatch.extendedinfo#" />
							</cfcatch>
							</cftry>
						<cfelse>
							<cfset result[arguments.value.xmlChildren[i].xmlAttributes.name] = deserialize(arguments.argName,arguments.value.xmlChildren[i].xmlChildren[1]) />
						</cfif>
					<cfelse>
						<cfthrow type="REST" message="Unnamed property in bean" 
								detail="Argument #arguments.argName# bean contains a property that has no name attribute" />
					</cfif>
				<cfelse>
					<cfthrow type="REST" message="Unexpected tag in bean" 
							detail="Argument #arguments.argName# bean contains a tag '#arguments.value.xmlChildren[i].xmlName#' where the 'property' tag was expected" />
				</cfif>
			</cfloop>
		</cfcase>

		<cfdefaultcase>
			<cfthrow type="REST" message="No deserializer for type" 
					detail="Argument #arguments.argName# value #arguments.value.xmlName# is not value, map, list or bean" />
		</cfdefaultcase>

		</cfswitch>
		
		<cfreturn result />
		
	</cffunction>
	
	<cffunction name="makeFaultXml" access="private" output="false" 
				hint="I serialize an exception into a simple XML format.">
		<cfargument name="exception" 
					hint="I am the exception (cfcatch structure) to be serialized." />
		
		<cfreturn "<fault><type>#arguments.exception.type#</type>" &
			"<message>#arguments.exception.message#</message>" &
			"<detail>#arguments.exception.detail#</detail>" &
			"<extendedinfo>#arguments.exception.extendedinfo#</extendedinfo></fault>" />
		
	</cffunction>

<!--- payload via the URL? --->
<cfif structKeyExists(URL,"payload")>
	<cfset payload = URL.payload />
<!--- payload via form field? --->
<cfelseif structKeyExists(form,"payload")>
	<cfset payload = form.payload />
<!--- payload via raw POST? --->
<cfelse>
	<cfset payload = getHttpRequestData().content />
	<cfif isBinary(payload)>
		<cfset payload = toString(payload) />
	</cfif>
</cfif>

<cfsetting showdebugoutput="false" />
</cfsilent><cfoutput>#rest(payload)#</cfoutput>