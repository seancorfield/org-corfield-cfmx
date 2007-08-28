<cfcomponent extends="MachII.framework.Listener" output="false">

	<!---
		Declaration of broadcast listener:
		
		<listener name="broadcast" type="org.corfield.mach-ii.controller.MessageListener">
			<parameters>
				<parameter name="some.message" value="listenerA.method1,listenerB.method2" />
				<parameter name="another.message" value="listenerA.method3" />
			</parameters>
		</listener>
		
		Use of broadcast listener:
		
		<notify listener="broadcast" method="some.message" />
	---->	
	
	<cffunction name="onMissingMethod" returntype="void" access="public" output="false">
		<cfargument name="missingMethodName" />
		<cfargument name="missingMethodArguments" />

		<cfset var listenerList = getParameter(arguments.missingMethodName) />
		<cfset var listenerManager = getAppManager().getListenerManager() />
		<cfset var listener = 0 />
		<cfset var event = 0 />
		
		<cfif structKeyExists(arguments.missingMethodArguments,"event")>
			<cfset event = arguments.missingMethodArguments.event />
		<cfelse>
			<cfset event = arguments.missingMethodArguments[1] />
		</cfif>
		
		<cfloop index="listener" list="#listenerList#">
			<cfinvoke component="#listenerManager.getListener(listFirst(listener,"."))#" 
						method="#listLast(listener,'.')#"
						returnvariable="result"
						event="#event#" />
		</cfloop>

	</cffunction>
	
</cfcomponent>