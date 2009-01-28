<cfcomponent name="tester">
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
	
	REST endpoint unit test helper
--->	
	<cfproperty name="data" />
	<cffunction name="init">
		<cfargument name="data" />
		<cfset variables.data = arguments.data />
		<cfreturn this />
	</cffunction>
	<cffunction name="echo" access="remote">
		<cfargument name="arg" />
		<cfreturn arguments.arg />
	</cffunction>
	<cffunction name="getKey" access="remote">
		<cfargument name="key" />
		<cfargument name="arg" />
		<cfreturn arguments.arg[arguments.key] />
	</cffunction>
	<cffunction name="notRemote" access="public">
	</cffunction>
	<cffunction name="getTester1" returntype="com.adobe.hs.test.rest.extra.tester" access="remote">
		<cfset var obj = createObject("component","com.adobe.hs.test.rest.extra.tester").init(13) />
		<cfreturn obj />
	</cffunction>
	<cffunction name="getTester2" returntype="com.adobe.hs.test.rest.extra.tester" access="remote">
		<cfset var obj = createObject("component","com.adobe.hs.test.rest.extra.tester") />
		<cfset obj.data = 42 />
		<cfreturn obj />
	</cffunction>
	<cffunction name="getData">
		<cfreturn variables.data />
	</cffunction>
	<cffunction name="setSomething">
		<cfargument name="something" />
		<cfset variables.something = arguments.something />
	</cffunction>
	<cffunction name="setBadSet">
		<cfthrow message="I'm a bad setter!" />
	</cffunction>
	<cffunction name="getSomething">
		<cfreturn variables.something />
	</cffunction>
	<cffunction name="doSomething" access="remote">
		<cfargument name="obj" />
		<cfreturn arguments.obj.getSomething() />
	</cffunction>
	<cffunction name="doSomethingElse" access="remote">
		<cfargument name="obj" />
		<cfreturn arguments.obj.somethingElse />
	</cffunction>
</cfcomponent>