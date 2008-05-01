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

<cfcomponent hint="I am the main entry point for the framework." output="false">

	<!--- constructor --->
	<cffunction name="init" returntype="any" access="public" output="false" hint="I am the framework constructor.">
		<cfargument name="maximumEventDepth" type="numeric" default="10"
					hint="I am the maximum event nesting depth." />
		<cfargument name="ignoreAsync" type="boolean" default="false"
					hint="I indicate whether async mode should fallback to sync mode on servers that do not support it." />
		<cfargument name="logging" type="string" default="" 
					hint="I indicate if or where to do logging: I can be empty - no logging - or the name of a log file." />
		
		<cfset variables.logger = createObject("component","edmund.framework.Logger").init(arguments.logging) />
		<cfset variables.handler = createObject("component","edmund.framework.EventHandler").init(arguments.maximumEventDepth,arguments.ignoreAsync,variables.logger) />
		<cfset variables.loader = createObject("component","edmund.framework.Loader").init(this,variables.logger) />
		<cfset variables.workflow = createObject("component","edmund.framework.workflow.Factory").init(variables.logger) />
		
		<cfreturn this />
			
	</cffunction>
	
	<!--- XML loaders --->
	<cffunction name="load" returntype="any" access="public" output="false" 
				hint="I load event / listener definitions from an XML file.">
		<cfargument name="file" type="string" required="true" 
					hint="I am the full filesystem path of the XML file to load.">
	
		<cfset variables.loader.load(arguments.file) />
		
		<cfreturn this />
	
	</cffunction>
	
	<cffunction name="loadXML" returntype="any" access="public" output="false" 
				hint="I load event / listener definitions from an XML string or object.">
		<cfargument name="xmlData" type="any" required="true" 
					hint="I am the XML string or object from which to load the definitions.">
	
		<cfset variables.loader.loadXML(arguments.xmlData) />
		
		<cfreturn this />
	
	</cffunction>
	
	<!--- retrieve workflow factory --->
	<cffunction name="getWorkflow" returntype="any" access="public" output="false" hint="I return the workflow factory.">
	
		<cfreturn variables.workflow />
	
	</cffunction>
	
	<!--- convenience method to create new events by name --->
	<cffunction name="new" returntype="any" access="public" output="false" 
				hint="I return a new event.">
		<cfargument name="name" type="string" required="true" 
					hint="I am the name of the new event." />
					
		<cfreturn createObject("component","edmund.framework.Event").init(arguments.name) />

	</cffunction>
	
	<!--- registration point for listeners --->
	<cffunction name="register" returntype="any" access="public" output="false" 
				hint="I register a new event handler.">
		<cfargument name="eventName" type="string" required="true" 
					hint="I am the event to listen for." />
		<cfargument name="listener" type="any" required="true" 
					hint="I am the listener object." />
		<cfargument name="method" type="string" default="handleEvent" 
					hint="I am the method to call on the listener when the event occurs." />
		<cfargument name="async" type="boolean" default="false"
					hint="I specify whether the listener should be invoked asynchronously." />

		<cfset variables.handler.addListener(argumentCollection=arguments) />
		
		<cfreturn this />
		
	</cffunction>
	
	<!--- dispatch event by name --->
	<cffunction name="dispatch" returntype="void" access="public" output="false" 
				hint="I dispatch an event by name, with no values.">
		<cfargument name="eventName" type="string" required="true" 
					hint="I am the name of the event to be handled." />

		<cfset dispatchEvent( new(arguments.eventName) ) />

	</cffunction>
	
	<!--- dispatch event by object --->
	<cffunction name="dispatchEvent" returntype="void" access="public" output="false" 
				hint="I dispatch an event.">
		<cfargument name="event" type="edmund.framework.Event" required="true" 
					hint="I am the event to be handled." />

		<cfset dispatchAliasEvent(arguments.event.getName(),arguments.event) />

	</cffunction>
	
	<!--- dispatch event by name and object --->
	<cffunction name="dispatchAliasEvent" returntype="void" access="public" output="false" 
				hint="I dispatch an event.">
		<cfargument name="eventAlias" type="string" required="true" 
					hint="I am the name of the event to be handled." />
		<cfargument name="event" type="edmund.framework.Event" required="true" 
					hint="I am the event to be handled." />

		<cfset variables.handler.handleEvent(arguments.eventAlias,arguments.event) />

	</cffunction>
	
	<!--- hooks for Application.cfc usage --->
	<cffunction name="onApplicationStart"
				hint="I can be called at the end of onApplicationStart, once all the listeners are registered.">
		
		<cfset dispatchEvent( new("onApplicationStart") ) />
		
	</cffunction>

	<cffunction name="onSessionStart"
				hint="I can be called from onSessionStart.">
		
		<cfset dispatchEvent( new("onSessionStart") ) />
		
	</cffunction>

	<cffunction name="onRequestStart"
				hint="I can be called from onRequestStart.">
		<cfargument name="targetPage" type="string" required="false" 
					hint="I am the targetPage (argument to Application.onRequestStart)." />
					
		<cfset dispatchEvent( new("onRequestStart").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<cffunction name="onRequestEnd"
				hint="I can be called from onRequestEnd.">
		<cfargument name="targetPage" type="string" required="false" 
					hint="I am the targetPage (argument to Application.onRequestEnd)." />
					
		<cfset dispatchEvent( new("onRequestEnd").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<cffunction name="onSessionEnd"
				hint="I can be called from onSessionEnd.">
		<cfargument name="sessionScope" required="false" 
					hint="I am the sessionScope (argument to Application.onSessionEnd)." />
		<cfargument name="applicationScope" required="false" 
					hint="I am the applicationScope (argument to Application.onSessionEnd)." />
					
		<cfset dispatchEvent( new("onSessionEnd").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<cffunction name="onApplicationEnd"
				hint="I can be called from onApplicationEnd.">
		<cfargument name="applicationScope" required="false" 
					hint="I am the applicationScope (argument to Application.onApplicationEnd)." />
					
		<cfset dispatchEvent( new("onApplicationEnd").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<cffunction name="onError"
				hint="I can be called from onError.">
		<cfargument name="exception" required="false" 
					hint="I am the exception (argument to Application.onError)." />
		<cfargument name="eventName" type="string" required="false" 
					hint="I am the eventName (argument to Application.onError)." />
					
		<cfset dispatchEvent( new("onError").values(argumentCollection=arguments) ) />
		
	</cffunction>

	<!--- hooks for bean factory usage --->
	<cffunction name="setBeanFactory" returntype="void" access="public" output="false" 
				hint="I allow a bean factory to be injected.">
		<cfargument name="beanFactory" type="any" required="true" 
					hint="I am a bean factory.">
		
		<cfset variables.beanFactory = arguments.beanFactory />
		
	</cffunction>
	
	<cffunction name="hasBeanFactory" returntype="boolean" access="public" output="false" 
				hint="I return true if a bean factory was injected.">
		
		<cfreturn structKeyExists(variables,"beanFactory") />
		
	</cffunction>
	
	<cffunction name="getBeanFactory" returntype="any" access="public" output="false" 
				hint="I return the bean factory.">
		
		<cfreturn variables.beanFactory />
		
	</cffunction>
	
</cfcomponent>