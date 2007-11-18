<cfcomponent output="false">
	
	<cffunction name="init">
		<cflog application="true" log="Application" text="init() called" type="information" />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="msgSubscriber">
		<cflog application="true" log="Application" text="msgSubscriber() called" type="information" />
	</cffunction>
	
	<cffunction name="msgListener">
		<cflog application="true" log="Application" text="msgListener() called" type="information" />
	</cffunction>
	
	<cffunction name="directCall">
		<cflog application="true" log="Application" text="directCall() called" type="information" />
	</cffunction>

</cfcomponent>