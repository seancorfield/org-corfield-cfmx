<cfcomponent hint="I am the XML file loader." output="false">

	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="edmund" type="edmund.Edmund" required="true" 
					hint="I am the framework entry point.">
		
		<cfset variables.edmund = arguments.edmund />
		<cfset variables.listeners = structNew() />
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="load" returntype="void" access="public" output="false" hint="I load and parse the XML file.">
		<cfargument name="file" type="string" required="true" 
					hint="I am the full filesystem path of the XML file to load.">

		<cfset var rawXML = 0 />
		<cfset var parsedXML = 0 />
		
		<cfset variables.file = arguments.file />
		
		<cffile action="read" file="#arguments.file#" variable="rawXML" />
		
		<cfset parsedXML = xmlParse(rawXML) />

		<cfset loadListeners(parsedXML) />
		<cfset loadSubscribers(parsedXML) />
		<cfset loadControllers(parsedXML) />
		<cfset loadEventHandlers(parsedXML) />
		
	</cffunction>

	<cffunction name="loadListeners" returntype="void" access="private" output="false" 
				hint="I load listener declarations from the XML.">
		<cfargument name="parsedXML" type="any" required="true" 
					hint="I am the parsed XML object." />

		<cfset var items = xmlSearch(arguments.parsedXML,"//listeners/listener") />
		<cfset var item = 0 />
		<cfset var obj = 0 />
		<cfset var n = arrayLen(items) />
		<cfset var i = 0 />
		
		<cfloop index="i" from="1" to="#n#">
			<cfset item = items[i] />
			<!--- name, type|bean --->
			<cfif not structKeyExists(item.xmlAttributes,"name")>
				<cfthrow type="edmund.missingAttribute" 
						message="'name' is required on 'listener' declaration" 
						detail="#parsedXML.xmlRoot.xmlName#>listeners>listener missing 'name' attribute in '#variables.file#'" />
			</cfif>
			<cfif structKeyExists(item.xmlAttributes,"type")>
				<cfif structKeyExists(item.xmlAttributes,"bean")>
					<cfthrow type="edmund.conflictingAttributes" 
							message="'listener' declaration cannot have both 'type' and 'bean'" 
							detail="#parsedXML.xmlRoot.xmlName#>listeners>listener '#item.xmlAttributes.name#' has both 'type' and 'bean' attributes in '#variables.file#'" />
				<cfelse>
					<cfset obj = createObject("component",item.xmlAttributes.type) />
					<cfif structKeyExists(obj,"init") and isCustomFunction(obj.init)>
						<cfset obj.init() />
					</cfif>
					<cfset variables.listeners[item.xmlAttributes.name] = obj />
				</cfif>
			<cfelseif structKeyExists(item.xmlAttributes,"bean")>
				<cfif not variables.edmund.hasBeanFactory()>
					<cfthrow type="edmund.badAttribute" 
							message="'bean' attribute requires bean factory support" 
							detail="#parsedXML.xmlRoot.xmlName#>listeners>listener '#item.xmlAttributes.name#' has 'bean' attribute but Edmund has no bean factory in '#variables.file#'" />
				<cfelse>
					<cfset variables.listeners[item.xmlAttributes.name] = variables.edmund.getBeanFactory().getBean(item.xmlAttributes.bean) />
				</cfif>
			<cfelse>
				<cfthrow type="edmund.missingAttribute" 
						message="'type' or 'bean' is required on 'listener' declaration" 
						detail="#parsedXML.xmlRoot.xmlName#>listeners>listener '#item.xmlAttributes.name#' missing 'type' or 'bean' attribute in '#variables.file#'" />
			</cfif>
		</cfloop>

	</cffunction>

	<cffunction name="loadSubscribers" returntype="void" access="private" output="false" 
				hint="I load subscriber declarations from the XML.">
		<cfargument name="parsedXML" type="any" required="true" 
					hint="I am the parsed XML object." />

		<cfset var items = xmlSearch(arguments.parsedXML,"//message-subscribers/message") />
		<cfset var item = 0 />
		<cfset var obj = 0 />
		<cfset var n = arrayLen(items) />
		<cfset var i = 0 />
		
		<cfloop index="i" from="1" to="#n#">
			<cfset item = items[i] />
			<!--- name, multithreaded (optional: false) --->
			<cfif not structKeyExists(item.xmlAttributes,"name")>
				<cfthrow type="edmund.missingAttribute" 
						message="'name' is required on 'message' declaration" 
						detail="#parsedXML.xmlRoot.xmlName#>message-subscribers>message missing 'name' attribute in '#variables.file#'" />
			</cfif>
			<!--- children(subscribe): listener, method --->
		</cfloop>

	</cffunction>

	<cffunction name="loadControllers" returntype="void" access="private" output="false" 
				hint="I load controller declarations from the XML.">
		<cfargument name="parsedXML" type="any" required="true" 
					hint="I am the parsed XML object." />

		<cfset var items = xmlSearch(arguments.parsedXML,"//controllers/controller") />
		<cfset var item = 0 />
		<cfset var obj = 0 />
		<cfset var n = arrayLen(items) />
		<cfset var i = 0 />
		
		<cfloop index="i" from="1" to="#n#">
			<cfset item = items[i] />
			<!--- name, type|bean --->
			<cfif not structKeyExists(item.xmlAttributes,"name")>
				<cfthrow type="edmund.missingAttribute" 
						message="'name' is required on 'controller' declaration" 
						detail="#parsedXML.xmlRoot.xmlName#>controllers>controller missing 'name' attribute in '#variables.file#'" />
			</cfif>
			<cfif structKeyExists(item.xmlAttributes,"type")>
				<cfif structKeyExists(item.xmlAttributes,"bean")>
					<cfthrow type="edmund.conflictingAttributes" 
							message="'controller' declaration cannot have both 'type' and 'bean'" 
							detail="#parsedXML.xmlRoot.xmlName#>controllers>controller '#item.xmlAttributes.name#' has both 'type' and 'bean' attributes in '#variables.file#'" />
				<cfelse>
					<cfset obj = createObject("component",item.xmlAttributes.type) />
					<cfif structKeyExists(obj,"init") and isCustomFunction(obj.init)>
						<cfset obj.init() />
					</cfif>
					<cfset variables.listeners[item.xmlAttributes.name] = obj />
				</cfif>
			<cfelseif structKeyExists(item.xmlAttributes,"bean")>
				<cfif not variables.edmund.hasBeanFactory()>
					<cfthrow type="edmund.badAttribute" 
							message="'bean' attribute requires bean factory support" 
							detail="#parsedXML.xmlRoot.xmlName#>controllers>controllers '#item.xmlAttributes.name#' has 'bean' attribute but Edmund has no bean factory in '#variables.file#'" />
				<cfelse>
					<cfset variables.listeners[item.xmlAttributes.name] = variables.edmund.getBeanFactory().getBean(item.xmlAttributes.bean) />
				</cfif>
			<cfelse>
				<cfthrow type="edmund.missingAttribute" 
						message="'type' or 'bean' is required on 'controller' declaration" 
						detail="#parsedXML.xmlRoot.xmlName#>controllers>controller '#item.xmlAttributes.name#' missing 'type' or 'bean' attribute in '#variables.file#'" />
			</cfif>
			<!--- children(message-listener): message, function --->
		</cfloop>

	</cffunction>

	<cffunction name="loadEventHandlers" returntype="void" access="private" output="false" 
				hint="I load listener declarations from the XML.">
		<cfargument name="parsedXML" type="any" required="true" 
					hint="I am the parsed XML object." />

		<cfset var items = xmlSearch(arguments.parsedXML,"//event-handlers/event-handler") />
		<cfset var item = 0 />
		<cfset var obj = 0 />
		<cfset var n = arrayLen(items) />
		<cfset var i = 0 />
		
		<cfloop index="i" from="1" to="#n#">
			<cfset item = items[i] />
			<!--- name|event --->
			<cfif structKeyExists(item.xmlAttributes,"name")>
			<cfelseif structKeyExists(item.xmlAttributes,"event")>
			<cfelse>
				<cfthrow type="edmund.missingAttribute" 
						message="'name' or 'event is required on 'event-handler' declaration" 
						detail="#parsedXML.xmlRoot.xmlName#>event-handlers>event-handler missing 'name' or 'event' attribute in '#variables.file#'" />
			</cfif>
			<!---
				children:
					notify: listener, method
					publish: message
					broadcasts:
						children(message): name
			--->
		</cfloop>

	</cffunction>

</cfcomponent>