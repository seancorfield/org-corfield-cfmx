<!---

  collection_test.cfm - Closures for ColdFusion
 
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
	to use the Closures for ColdFusion Collection class.
	
	The Collection class is modeled closely on Smalltalk's basic Collection class and it
	provides a number of methods that take either a closure, a function or a Ruby-style block
	specification (an argument list and a code block - the same arguments that you would
	provide to the ClosureFactory when creating a new closure, albeit it code first, arguments
	second). See the examples below.
	
	Collection.init(closureFactory)
		initializes an empty collection with an existing closure factory to support
		Ruby-style code blocks (where the Collection needs to create closures directly)
	Collection.init(anArray)
		initializes a collection with the elements of the specified array - if you are
		using a closure factory, use the addAll() method to add the elements of the array
	Collection.init(aStruct)
		initializes a collection with the elements of the specified struct added as
		key/value pairs, e.g.,
			{ a=1, b=2, c=3 } effectively becomes:
			[ { key="a", value=1 }, { key="b", value=2 }, { key="c", value=3  ]
		as with arrays, if you need a closure factory, use addAll() to add the elements of
		the struct after initialization:
			c = createObject("component","Collection").init(factory).addAll(aStruct);
	Collection.init(elem1,elem2,elem3,...)
		initializes a collection with the specified elements - if you need a closure
		factory, use add() (not addAll() in this case)
	
	Collection.isEmpty()
		returns true if the collection has no elements
		
	Collection.each(closure)
		applies the closure to each element of the collection - the results are ignored
	Collection.each(someUDF)
		applies the UDF to each element of the collection - the results are ignored
	Collection.each(arg,codeBlock)
		makes a closure from the codeBlock with the specified argument and applies it
		to each element of the collection - the results are ignored
	Collection.each() can take an optional additional argument in each case that
		specifies a closure or UDF that is executed (with no arguments) between the 
		processing of each element of the collection
		
	Collection.select(closure)
		returns a collection consisting of any elements of the current collection for
		which the closure evaluates to true
	Collection.select(someUDF)
		returns a collection consisting of any elements of the current collection for
		which the UDF evaluates to true
	Collection.select(arg,codeBlock)
		makes a closure from the codeBlock with the specified argument and then behaves
		as for the first version of select() above
		
	Collection.reject(closure)
		returns a collection consisting of any elements of the current collection for
		which the closure evaluates to false
	Collection.reject(someUDF)
		returns a collection consisting of any elements of the current collection for
		which the UDF evaluates to false
	Collection.reject(arg,codeBlock)
		makes a closure from the codeBlock with the specified argument and then behaves
		as for the first version of reject() above
		
	Collection.collect(closure)
		returns a collection containing the result of applying the closure to each
		element in the current collection
	Collection.collect(someUDF)
		returns a collection containing the result of applying the UDF to each
		element in the current collection
	Collection.collect(arg,codeBlock)
		makes a closure from the codeBlock with the specified argument and then behaves
		as for the first version of collect() above
		
	Collection.detect(closure)
		returns the first element of the current collection for which the closure 
		evaluates to true (see note below about the behave if no element matches)
	Collection.detect(someUDF)
		returns the first element of the current collection for which the UDF 
		evaluates to true (see note below about the behave if no element matches)
	Collection.detect(arg,codeBlock)
		makes a closure from the codeBlock with the specified argument and then behaves
		as for the first version of detect() above
	Collection.detect() can take an optional additional argument in each case that
		specifies a closure or UDF that is executed (with no arguments) if no element
		matches and the result of that execution is returned from detect() - if this
		optional argument is not provided and no element matches, you will get an
		exception (that Element DETECT.NOMATCHINGELEMENT is undefined in VARIABLES.)
		
--->

<!---
	select() method to support structs-as-collections and closures.
	See below for examples of how to do this using the new Collection class.
--->
<cfscript>
function select(collection,closure) {
	var result = structNew();
	var e = 0;
	for (e in collection) {
		if (closure.test(collection[e])) {
			result[e] = collection[e];
		}
	}
	return result;
}
</cfscript>
<cfset emps = structNew() />
<cfset e = structNew() />
<cfset e.name = "Sean" />
<cfset e.empStatus = "MANAGER" />
<cfset emps[e.name] = e />
<cfset e = structNew() />
<cfset e.name = "Matias" />
<cfset e.empStatus = "CONTRIBUTOR" />
<cfset emps[e.name] = e />
<cfset e = structNew() />
<cfset e.name = "Paul" />
<cfset e.empStatus = "CONTRIBUTOR" />
<cfset emps[e.name] = e />
<cfset testStatus = cf.new("e.empStatus eq statValue","e").name("test") />
<cfset mgrs = select(emps,testStatus.bind(statValue="MANAGER")) />
<cfdump label="mgrs" var="#mgrs#"/>
<cfset contribs = select(emps,testStatus.bind(statValue="CONTRIBUTOR")) />
<cfdump label="contribs" var="#contribs#"/>

<!--- a better way to do this using the Collection class --->
<cfset empCollection = createObject("component","Collection").init(cf).addAll(emps) />
<cfset testStatus = cf.new("e.value.empStatus eq statValue","e").name("test") />
<cfset mgrs = empCollection.select( testStatus.bind(statValue="MANAGER") ) />
<!--- since we built the collection from a struct, we can get either an array or a struct back --->
<cfdump label="mgrs.asArray()" var="#mgrs.asArray()#" />
<cfset contribs = empCollection.select( testStatus.bind(statValue="CONTRIBUTOR") ) />
<cfdump label="contribs.asStruct()" var="#contribs.asStruct()#" />

<!--- more examples of using the Collection class --->
<cfsetting enablecfoutputonly="true"/>
<cfscript>
	
	a = [ 1, 2, 3, 4 ];
	s = { x=1, y=2, z=3 };
	
	empty = createObject("component","Collection").init(cf);
	four = createObject("component","Collection").init(cf).addAll(a);
	three = createObject("component","Collection").init(cf).addAll(s);
	two = createObject("component","Collection").init(cf).add("one","two");
	
	adder = cf.new("sum = sum + x;","x");
	adder = adder.bind(sum=0);
	empty.each(adder);
	writeOutput("sum = " & adder.bound("sum") & "<br />");
	adder = adder.bind(sum=0);
	four.each(adder);
	writeOutput("sum = " & adder.bound("sum") & "<br />");
	adder = adder.bind(sum=0);
	four.each(adder);
	writeOutput("sum = " & adder.bound("sum") & "<br />");
	adder = cf.new("sum = sum + x.value;","x");
	adder = adder.bind(sum=0);
	three.each(adder);
	writeOutput("sum = " & adder.bound("sum") & "<br />");
	
	even = four.select( cf.new("n mod 2 eq 0","n") );
	writeOutput("|");
	even.each( cf.new("writeOutput(n);","n"), cf.new("writeOutput(',');") );
	writeOutput("|<br />");
	even = four.select( "n", "n mod 2 eq 0" );
	writeOutput("|");
	even.each( cf.new("writeOutput(n);","n"), cf.new("writeOutput(',');") );
	writeOutput("|<br />");
	double = three.collect( cf.new("x.value * 2","x") );
	writeOutput("|");
	double.each( cf.new("writeOutput(n);","n"), cf.new("writeOutput(',');") );
	writeOutput("|<br />");
	double = three.collect( "x", "x.value * 2" );
	writeOutput("|");
	double.each( cf.new("writeOutput(n);","n"), cf.new("writeOutput(',');") );
	writeOutput("|<br />");
	
	empty.addAll( four );
	writeOutput("|");
	empty.each( cf.new("writeOutput(n);","n"), cf.new("writeOutput(',');") );
	writeOutput("|<br />");
	
	function put(x) { writeOutput(x); }
	function comma1() { put(","); }
	function comma2() { writeOutput(","); }

	writeOutput("|");
	empty.each( put, cf.new(comma1).bind(put=put) );
	writeOutput("|<br />");
	writeOutput("|");
	empty.each( put, comma2 );
	writeOutput("|<br />");
	writeOutput("|");
	empty.each( "n", "writeOutput(n);" );
	writeOutput("|<br />");

	odd = four.reject( "n", "n mod 2 eq 0" );
	writeOutput("|");
	odd.each( put, comma2 );
	writeOutput("|<br />");
	
	writeOutput("first even = " & four.detect( "n", "n mod 2 eq 0" ) & "<br />");

	try {
		four.detect( "n", "n eq 42" );
	} catch (any e) {
		if (e.message is "Element DETECT.NOMATCHINGELEMENT is undefined in VARIABLES.") {
			writeOutput("1,2,3,4 does not contain 42<br />");
		} else {
			writeOutput("Unexpected exception from detect(): " & e.message & "<br />");
		}
	}
	
	writeOutput( "Detect 42? " & four.detect( cf.new("n eq 42","n"), cf.new("'no such element'") ) & "<br />" );
	
	writeOutput( "sum = " & four.inject( 0, cf.new("sum + x","sum,x") ) & "<br />" );

	writeOutput( "sum = " & four.inject( 0, "sum,x", "sum + x" ) & "<br />" );
	
	four.add(5,6,7,8);
	writeOutput("|");
	four.each( put, comma2 );
	writeOutput("|<br />");
	four.init(5,6,7,8);
	writeOutput("|");
	four.each( put, comma2 );
	writeOutput("|<br />");
	four.addAll(a);
	writeOutput("|");
	four.each( put, comma2 );
	writeOutput("|<br />");
	writeOutput( "##odd = " & four.count( "n", "n mod 2 eq 0" ) & "<br />" );
	writeOutput( "##three = " & four.count( "n", "n mod 3 eq 0" ) & "<br />" );
	stuff = four.collectSelect( "n", "n * 3", "n", "n mod 2 eq 0" );
	writeOutput("|");
	stuff.each( put, comma2 );
	writeOutput("|<br />");
	stuff = four.selectCollect( "n", "n mod 2 eq 0", "n", "n / 2" );
	writeOutput("|");
	stuff.each( put, comma2 );
	writeOutput("|<br />");
	
	s = structNew();
	s.buffer = "";
	four.each( cf.new( "data.buffer &= n;", "n").bind(data=s), cf.new( "list.buffer &= '-';").bind(list=s) );
	writeOutput("s.buffer = |#s.buffer#|<br />");
	writeOutput("s.buffer = |" & four.inject( "", "s,n", "listAppend(s,n,'-')" ) & "|<br />");

</cfscript>

<cfdump label="three.asArray()" var="#three.asArray()#" />
<cfdump label="four.asArray()" var="#four.asArray()#" />
