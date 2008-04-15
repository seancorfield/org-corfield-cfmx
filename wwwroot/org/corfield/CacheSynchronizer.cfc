<cfcomponent output="false">
<!---

  CacheSynchronizer.cfc - JMS-based cache synchronization utility for Transfer ORM
 
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

  Assumes:

	ActiveMQ 4.1.0 running on each server in the cluster
	
	CacheSync event gateway on each server configured as follows:
	
		# Outbound JMS gateway configuration for Transfer cache synchronization:
		# Each server instance broadcasts to its local JMS server when an object is updated.
		
		outboundOnly=yes
		debug=yes
		
		providerURL=tcp://localhost:61616
		initialContextFactory=org.apache.activemq.jndi.ActiveMQInitialContextFactory
		connectionFactory=ConnectionFactory
		
		destinationName=dynamicTopics/transfer.cache

	CacheSyncXYZ event gateway on each server for each of the other servers in the cluster,
	configured as follows:
		
		# Inbound JMS gateway configuration for Transfer cache synchronization:
		# Each server instance receives messages from a remote JMS server when an object is updated.
		
		outboundOnly=no
		debug=yes
		
		# Put the remote server IP address here:
		providerURL=tcp://{IP.of.remote.server}:61616
		initialContextFactory=org.apache.activemq.jndi.ActiveMQInitialContextFactory
		connectionFactory=ConnectionFactory
		
		destinationName=dynamicTopics/transfer.cache

	ColdSpring configuration:
	
		transferConfiguration / transferFactory and transfer beans
		
		<bean id="cacheSynchronizer" class="bc.common.model.service.CacheSynchronizer">
			<constructor-arg name="transfer"><ref bean="transfer" /></constructor-arg>
		</bean>
	
	Initialization:
	
		Either make the cacheSynchronizer bean lazy-init="false" or after creating the ColdSpring
		factory, do the following to force initialization and registration:
		
			<cfset bf.getBean("cacheSynchronizer") />	

--->
	
	<!--- constructor - not called when invoked via event gateway! --->
	<cffunction name="init" access="public" returntype="any" hint="I am the constructor.">
		<cfargument name="transfer" type="transfer.com.Transfer" required="true" />

		<!--- auto-register ourself as the after update / delete event listener --->
		<cfset arguments.transfer.addAfterUpdateObserver(this) />
		<cfset arguments.transfer.addDeleteUpdateObserver(this) />

		<cfreturn this />

	</cffunction>
	
	<!--- Transfer event handlers --->
	<cffunction name="actionAfterDeleteTransferEvent" returntype="void" access="public" output="false" 
				hint="I am called after a Transfer object has been deleted from the database.">
		<cfargument name="event" type="transfer.com.events.TransferEvent" hint="The event object" required="true" />
		
		<cfset sendSynchronizationMessage(arguments.event.getTransferObject()) />
		
	</cffunction>

	<cffunction name="actionAfterUpdateTransferEvent" returntype="void" access="public" output="false" 
				hint="I am called after a Transfer object has been updated in the database.">
		<cfargument name="event" type="transfer.com.events.TransferEvent" hint="The event object" required="true" />
		
		<cfset sendSynchronizationMessage(arguments.event.getTransferObject()) />
		
	</cffunction>

	<!--- event gateway handler --->
	<cffunction name="onIncomingMessage" returntype="struct" access="public" output="false" 
				hint="I am called by the event gateway to process a cache synchronization message.">
		<cfargument name="event" type="struct" required="true"/>
		
		<cfset var result = { status = "OK" } />
		<!--- when invoked via the gateway, no autowiring will have taken place --->
		<cfset var transfer = application.beanFactory.getBean("transfer") />
		<cfset var msg = arguments.event.data.msg />

		<!--- only take action on updates from other servers --->		
		<cfif msg.host is not getLocalHostname()>
			<cflog application="true" log="console" text="Cache update from '#msg.host#' to discard '#msg.class#:#msg.id#'" type="information" />
			<cfset transfer.discardByClassAndKey(msg.class,msg.id)>
		<cfelse>
			<cflog application="true" log="console" text="Ignored cache update from myself to discard '#msg.class#:#msg.id#'" type="information" />
		</cfif>
		
		<cfreturn result />
	
	</cffunction>
	
	<!--- private utility methods --->
	<cffunction name="getLocalHostname" returntype="string" access="private" output="false" hint="I return the actual server hostname / IP">
	
		<!--- figure out the localhost server name --->
		<cfset var inet = createObject("java","java.net.InetAddress") />
		
		<!--- this is servername/ipaddress: --->
		<cfreturn inet.getLocalHost() />

	</cffunction>
	
	<cffunction name="sendSynchronizationMessage" returntype="void" access="public" output="false" 
				hint="I send the cache synchronization message.">
		<cfargument name="transferObject" type="any" required="true" />
		
		<cfset var eventData = 0 />
		<cfset var message = 0 />

		<!--- TODO: once the caching status is available via Transfer metadata, check that too --->
		<cfif structKeyExists(arguments.transferObject,"getId")>
			<cfset message = {
						host = getLocalHostname(), 
						class = arguments.transferObject.getClassName(), 
						id = arguments.transferObject.getId()
					} />
			<cfset eventData = { status = "SEND", topic = "dynamicTopics/transfer.cache", message = message } />
			<cfset sendGatewayMessage("CacheSync",eventData) />
		</cfif>
		
	</cffunction>

</cfcomponent>