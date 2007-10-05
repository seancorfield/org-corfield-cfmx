<!---

  closure_test.cfm - Closures for ColdFusion
 
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

--->

<!---
	This file is both the unit test suite and a set of examples of how
	to use the Closures for ColdFusion library.
	
	What is a closure? It's a capsule of code and some variables bound to that code. Sounds
	like an object? Well, it's similar, yes, but in most languages that have native support
	for closures, you can take just a block of code and bind some variables into it and then
	execute it in another context (where any unbound variables are evaluated).
	
	This library allows you to take a function from one context, bind some of the variables
	in the function and then use the function (as part of an object) in another context. You
	can also take a textual code block and have the library create a function from it.
	
	ClosureFactory.new(someUDF)
		this creates a closure based on the UDF (or CFC method); you can (re-)name the method
		but you will always have to use named arguments to run call() or the named method
	ClosureFactory.new(tagCodeBlockString)
		this creates a closure from the tags specified in the code block; you can (re-)name
		the generated method - but the call will require named arguments
	ClosureFactory.new(scriptCodeBlockString)
		this creates a closure from the cfscript code specified in the code block; the necessary
		<cfscript> tags are added around the code automatically; you can (re-)name the generated
		method - but the call will require named arguments
	ClosureFactory.new(tagCodeBlockString,argumentSpecification)
		this creates a closure from the tags specified in the code block with the specified named
		argument specifications; you can still (re-)name the generated method if you wish
	ClosureFactory.new(scriptCodeBlockString,argumentSpecification)
		this creates a closure from the cfscript code specified in the code block with the
		specified named argument specifications; you can still (re-)name the generated method
		if you wish

	argumentSpecification:
		a list of argument names to add to the code block; you can optionally specify types for
		the named arguments using ':' and the argument type:
			a,b,c
			a:string,b:numeric,c:thingcfc

	Closure.init(method)
		used by ClosureFactory to create the closure object
	Closure.bind(namedVariables)
		binds the named variables into the context of the closure, e.g.,
			myClosure.bind(one=1,two="two",three="many")
		this creates a new closure instance with the specified variables bound into the context
	Closure.call(namedArguments)
		calls the method in the closure, passing in the named arguments - you can use positional
		arguments only if you provide an argumentSpecification when you create the closure
	Closure.name(methodName)
		provides a name for the bound method as an alternative to the call() method
	Closure.bound(variableName)
		retrieves the current value of the specified bound variable
		
--->

<!--- you would typically put this in application scope: --->
<cfset cf = createObject("component","ClosureFactory") />

<!--- if you specify argument names, you can use unqualified names in the closure source text --->
<!--- multiplier is unbound here, n is specified as an argument: --->
<cfset a = getTickCount() />
<cfset calc = cf.new("multiplier * n","n") />
<cfset b = getTickCount() />
<!--- prove that requesting the same textual closure multiple times returns a cached version: --->
<cfset calc = cf.new("multiplier * n","n") />
<cfset c = getTickCount() />
<cfoutput>
	<p>first closure took #b-a#ms, second closure took #c-b#ms.</p>
</cfoutput>

<!--- this does not specify argument names so positional arguments will work when you call it: --->
<cfset doublerP = cf.new("return multiplier * arguments[1];").bind(multiplier=2) />
<!--- this does not specify argument names so named arguments will work when you call it: --->
<cfset doublerN = cf.new("return multiplier * arguments.n;").bind(multiplier=2) />

<!--- set the name on the closure so it propagates: --->
<cfset calc.name("do") />
<!--- create two separate instances with multiplier bound to different values: --->
<cfset triple = calc.bind(multiplier=3) />
<cfset order = calc.bind(multiplier=10) />
<!--- override the name for this closure: --->
<cfset four = calc.bind(multiplier=4).name("quad") />

<cfoutput>
	<p>all the answers should be 42!</p>
	<p>doublerP.call(21) = #doublerP.call(21)#</p>
	<p>doublerN.call(n=21) = #doublerN.call(n=21)#</p>
	<p>triple.do(14) = #triple.do(14)#</p>
	<p>order.do(4.2) = #order.do(4.2)#</p>
	<p>four.quad(10.5) = #four.quad(10.5)#</p>
</cfoutput>

<!--- you can also use tag syntax if you want: --->
<cfset adder = cf.new("<cfreturn step + n />","n") />
<cfset increment = adder.bind(step=1).name("do") />
<cfoutput>
	<p>increment.do(41) = #increment.do(41)#</p>
</cfoutput>

<cfscript>
function greet(who) {
	return greeting & " " & who & "!";
}
</cfscript>

<!--- make closures from UDFs - call() always requires named arguments: --->
<cfset hello = cf.new(greet).bind(greeting="Hello") />
<cfset goodbye = cf.new(greet).bind(greeting="Goodbye") />
<cfoutput>
	<p>hello world? #hello.call("world")#</p>
	<p>goodbye cruel world? #goodbye.call("cruel world")#</p>
</cfoutput>

<!---
	now we name the method and we can use unnamed arguments (because this
	essentially exposes the original function, which had arguments specified): 
--->
<cfset hello.name("say") />
<cfset goodbye.name("say") />
<cfoutput>
	<p>say hello world? #hello.say("world")#</p>
	<p>say goodbye cruel world? #goodbye.say("cruel world")#</p>
</cfoutput>

<!--- the select example is now part of the collection_test.cfm file --->
