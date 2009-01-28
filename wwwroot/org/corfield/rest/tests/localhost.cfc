<cfcomponent extends="org.cfcunit.framework.TestCase">
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
	
	REST endpoint unit test suite
--->	

	<cffunction name="setUp" returntype="void" access="public">
		<cfset variables.host = CGI.SERVER_NAME />
		<cfset variables.port = getPageContext().getRequest().getServerPort() />
		<cfset variables.contextPath = getPageContext().getRequest().getContextPath() />
		<cfset variables.key = "unknown" />
		<cfset variables.value = "unknown" />
		<cfset variables.prolog = '<?xml version="1.0" encoding="UTF-8"?>' & chr(10) />
		<cfset variables.restEndPoint = "http://#variables.host#:#variables.port##variables.contextPath#/org/corfield/rest/wwwroot/endpoint.cfm" />
		<cfset variables.testerPath = "org.corfield.rest.tests.extra.tester" />
	</cffunction>
	
	<cffunction name="testRest1" returntype="void" access="public">
		<cfset var packet = "<boguscomponent operation=""run""></boguscomponent>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>Component name invalid</message>" &
				"<detail>Application : Could not find the ColdFusion Component boguscomponent.</detail>" &
				"<extendedinfo>Please check that the given name is correct and that the component exists. :  : boguscomponent</extendedinfo></fault>",
				REReplace(REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),'/[Ii]nterface','','all'),
				"cfhttp(boguscomponent)") />
	</cffunction>
	
	<cffunction name="testRest2" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""bogusoperation""></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cflog text="#rest.fileContent#"/>
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>Operation name invalid</message>" &
				"<detail>The component #variables.testerPath# does not have a remote method bogusoperation</detail>" &
				"<extendedinfo></extendedinfo></fault>",
				REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),
				"cfhttp(bogusoperation)") />
	</cffunction>
	
	<cffunction name="testRest2a" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""notRemote""></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>Operation name invalid</message>" &
				"<detail>The component #variables.testerPath# does not have a remote method notRemote</detail>" &
				"<extendedinfo></extendedinfo></fault>",
				REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),
				"cfhttp(bogusoperation)") />
	</cffunction>
	
	<cffunction name="testRest3" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""echo""><arg><value>42</value></arg></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<result><value>42</value></result>",
				REReplace(rest.fileContent,'.*(<result>.*</result>).*','\1'),
				"cfhttp(echo:simpleValue)") />
	</cffunction>
	
	<cffunction name="testRest3b" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""echo""><arg><value>42</value></arg></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="body" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<result><value>42</value></result>",
				REReplace(rest.fileContent,'.*(<result>.*</result>).*','\1'),
				"cfhttp(echo:simpleValue)") />
	</cffunction>
	
	<cffunction name="testRest3a" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""echo""><value>42</value></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>Argument invalid</message>" &
				"<detail>The argument value does not have a single child value</detail>" &
				"<extendedinfo></extendedinfo></fault>",
				REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),
				"cfhttp(echo:bogusValue)") />
	</cffunction>
	
	<cffunction name="testRest4" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""getKey""><key><value>foo</value></key><arg><map><entry key=""foo""><value>13</value></entry></map></arg></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<result><value>13</value></result>",
				REReplace(rest.fileContent,'.*(<result>.*</result>).*','\1'),
				"cfhttp(getKey:map)") />
	</cffunction>
	
	<cffunction name="testRest4a" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""getKey""><key><value>foo</value></key><arg><map><bogus key=""foo""><value>13</value></bogus></map></arg></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>Invalid map element</message>" &
				"<detail>Argument arg map contains illegal entry bogus</detail>" &
				"<extendedinfo></extendedinfo></fault>",
				REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),
				"cfhttp(getKey:invalidEntry)") />
	</cffunction>
	
	<cffunction name="testRest4b" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""getKey""><key><value>foo</value></key><arg><map><entry bogus=""foo""><value>13</value></entry></map></arg></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>Invalid map element</message>" &
				"<detail>Argument arg map contains an entry with no key</detail>" &
				"<extendedinfo></extendedinfo></fault>",
				REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),
				"cfhttp(getKey:invalidKey)") />
	</cffunction>
	
	<cffunction name="testRest4c" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""getKey""><key><value>foo</value></key><arg><map><entry key=""foo""><value>13</value><value>13</value></entry></map></arg></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>Invalid map element</message>" &
				"<detail>Argument arg map contains an entry foo that does not have a single child value</detail>" &
				"<extendedinfo></extendedinfo></fault>",
				REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),
				"cfhttp(getKey:badValue)") />
	</cffunction>
	
	<cffunction name="testRest5" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""getKey""><key><value>2</value></key><arg><list><value>13</value><value>26</value><value>39</value></list></arg></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<result><value>26</value></result>",
				REReplace(rest.fileContent,'.*(<result>.*</result>).*','\1'),
				"cfhttp(getKey:list)") />
	</cffunction>
	
	<cffunction name="testRest6a" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""getTester1""></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<result><bean classpath=""#variables.testerPath#""><property name=""data""><value>13</value></property></bean></result>",
				REReplace(rest.fileContent,'.*(<result>.*</result>).*','\1'),
				"cfhttp(getTester1:bean/get)") />
	</cffunction>
		
	<cffunction name="testRest6b" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""getTester2""></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<result><bean classpath=""#variables.testerPath#""><property name=""data""><value>42</value></property></bean></result>",
				REReplace(rest.fileContent,'.*(<result>.*</result>).*','\1'),
				"cfhttp(getTester2:bean/property)") />
	</cffunction>
		
	<cffunction name="testRest7a" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""doSomething""><obj><bean classpath=""#variables.testerPath#""><property name=""something""><value>123</value></property></bean></obj></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<result><value>123</value></result>",
				REReplace(rest.fileContent,'.*(<result>.*</result>).*','\1'),
				"cfhttp(doSomething:bean/set)") />
	</cffunction>
		
	<cffunction name="testRest7b" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""doSomethingElse""><obj><bean classpath=""#variables.testerPath#""><property name=""somethingElse""><value>456</value></property></bean></obj></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<result><value>456</value></result>",
				REReplace(rest.fileContent,'.*(<result>.*</result>).*','\1'),
				"cfhttp(doSomethingElse:bean/property)") />
	</cffunction>
		
	<cffunction name="testRest7c" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""doSomethingElse""><obj><bean classpath=""#variables.testerPath#""><unexpected name=""somethingElse""><value>456</value></unexpected></bean></obj></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>Unexpected tag in bean</message>" &
				"<detail>Argument obj bean contains a tag 'unexpected' where the 'property' tag was expected</detail>" &
				"<extendedinfo></extendedinfo></fault>",
				REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),
				"cfhttp(bean:badtag)") />
	</cffunction>
		
	<cffunction name="testRest7d" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""doSomethingElse""><obj><bean classpath=""#variables.testerPath#""><property><value>456</value></property></bean></obj></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>Unnamed property in bean</message>" &
				"<detail>Argument obj bean contains a property that has no name attribute</detail>" &
				"<extendedinfo></extendedinfo></fault>",
				REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),
				"cfhttp(bean:unnamed)") />
	</cffunction>
		
	<cffunction name="testRest7e" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""doSomethingElse""><obj><bean classpath=""#variables.testerPath#""><property name=""badset""><value>456</value></property></bean></obj></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>Unable to set property</message>" &
				"<detail>Argument obj bean contains a property badset for which the setter method cannot be called</detail>" &
				"<extendedinfo>I'm a bad setter! :  : </extendedinfo></fault>",
				REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),
				"cfhttp(bean:badset)") />
	</cffunction>
		
	<cffunction name="testRest7f" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""doSomethingElse""><obj><bean classpath=""#variables.testerPath#""><property name=""somethingElse""></property></bean></obj></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>Invalid bean property element</message>" &
				"<detail>Argument obj bean contains a property somethingElse that does not have a single child value</detail>" &
				"<extendedinfo></extendedinfo></fault>",
				REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),
				"cfhttp(bean:nochild)") />
	</cffunction>
		
	<cffunction name="testRest7g" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""doSomethingElse""><obj><bean classpath=""#variables.testerPath#""><property name=""somethingElse""><value>1</value><value>2</value></property></bean></obj></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>Invalid bean property element</message>" &
				"<detail>Argument obj bean contains a property somethingElse that does not have a single child value</detail>" &
				"<extendedinfo></extendedinfo></fault>",
				REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),
				"cfhttp(bean:twochildren)") />
	</cffunction>
		
	<cffunction name="testRest7h" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""doSomethingElse""><obj><bean classpath=""boguscomponent""><property name=""somethingElse""><value>1</value></property></bean></obj></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>Invalid classpath for bean</message>" &
				"<detail>Argument obj is a bean with an invalid classpath boguscomponent</detail>" &
				"<extendedinfo>Could not find the ColdFusion Component boguscomponent. : Please check that the given name is correct and that the component exists. : </extendedinfo></fault>",
				REReplace(REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),'/[Ii]nterface','','all'),
				"cfhttp(bean:boguscomponent)") />
	</cffunction>
		
	<cffunction name="testRest7i" returntype="void" access="public">
		<cfset var packet = "<#variables.testerPath# operation=""doSomethingElse""><obj><bean><property name=""somethingElse""><value>1</value></property></bean></obj></#variables.testerPath#>" />
		<cfset var rest = 0 />
		<cftry>
			<cfhttp url="#variables.restEndPoint#" method="post" result="rest" throwonerror="true">
				<cfhttpparam type="formfield" name="payload" encoded="true" value="#packet#" />
			</cfhttp>
		<cfcatch type="any">
			<cfset fail("#cfcatch.Type#:#cfcatch.Message#:#cfcatch.Detail#:#cfcatch.ExtendedInfo#") />
		</cfcatch>
		</cftry>
		<cfset assertEqualsString("200 OK",rest.statusCode,"cfhttp") />
		<cfset assertEqualsString(
				"<fault><type>REST</type><message>No classpath for bean</message>" &
				"<detail>Argument obj is a bean with no classpath</detail>" &
				"<extendedinfo></extendedinfo></fault>",
				REReplace(rest.fileContent,'.*(<fault>.*</fault>).*','\1'),
				"cfhttp(bean:noclasspath)") />
	</cffunction>
	
</cfcomponent>