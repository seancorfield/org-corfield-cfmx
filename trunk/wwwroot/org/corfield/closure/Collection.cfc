<cfcomponent hint="I am a Smalltalk-style collection class.">
	<cfscript>
	/*
	
	  Collection.cfc - Closures for ColdFusion (although this is more broadly applicable)
	 
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
	
	*/
	
		variables.elements = arrayNew(1);
	
		// I initialize the collection, optionally from an array, a struct or a series of items or a closure factory.
		function init() {
			
			variables.elements = arrayNew(1);
	
			if (arrayLen(arguments) eq 1) {
				// closure factory, array, struct or single item
				if (isObject(arguments[1]) and isInstanceOf(arguments[1],"ClosureFactory")) {
					variables.cf = arguments[1];
				} else if (isStruct(arguments[1]) or isArray(arguments[1])) {
					addAll(arguments[1]);
				} else {
					add(arguments[1]);
				}
			} else {
				// multiple arguments (or zero)
				add(argumentCollection=arguments);
			}
			
			return this;
		}	
	
		// I return true iff the collection is empty.
		function isEmpty() {
			
			return arrayLen(variables.elements) eq 0;
			
		}	
	
		// I perform an operation on every element of the collection.
		// Can be called in any of the following ways:
		//		each( "argname", "codeblock" )
		//		each( closureOrFunction )
		//		each( closureOrFunction, closureOrFunction )
		// This is called do in Smalltalk but each in Ruby.
		function each(
				block		// I am the closure/function to execute on each element (or the argname).
				// separatedBy I am an optional closure/function to execute between each element (or the codeblock).
		) {
			var i = iterator();
			var separated = false;
			var hasSeparatedByBlock = arrayLen(arguments) gt 1;
			var blockIsFunction = isCustomFunction(block);
			var separatedByIsFunction = hasSeparatedByBlock and isCustomFunction(arguments[2]);
			var separatedByFunction = 0;
			
			if (hasSeparatedByBlock and isSimpleValue(block) and isSimpleValue(arguments[2])) {
	
				// argname and codeblock
				if (structKeyExists(variables,"cf")) {
					// reuse our closure factory:
					each( variables.cf.new(arguments[2],arguments[1]) );
				} else {
					// not very efficient: create a new closure factory and use that:
					each( createObject("component","ClosureFactory").new(arguments[2],arguments[1]) );
				}
	
			} else {
				
				if (separatedByIsFunction) separatedByFunction = arguments[2];
				while (i.hasNext()) {
					if (separated) {
						if (separatedByIsFunction) {
							separatedByFunction();
						} else {
							arguments[2].call();
						}
					}
					if (blockIsFunction) {
						block(i.next());
					} else {
						block.call(i.next());
					}
					separated = hasSeparatedByBlock;
				}
	
			}
			
			return this;
		}
		
		// I return a collection containing only elements that satisfy the predicate.
		// Can be called in any of the following ways:
		//		select( "argname", "codeblock" )
		//		select( closureOrFunction )
		function select(
				predicate	// I am the predicate closure/function to execute on each element (or the argname). 
				// codeblock   I am the optional codeblock.
		) {
			var i = 0;
			var result = 0;
			var e = 0;
			
			if (arrayLen(arguments) gt 1 and isSimpleValue(predicate) and isSimpleValue(arguments[2])) {
	
				// argname and codeblock
				if (structKeyExists(variables,"cf")) {
					// reuse our closure factory:
					result = select( variables.cf.new( arguments[2], predicate ) );
				} else {
					// not very efficient: create a new closure factory and use that:
					result = select( createObject("component","ClosureFactory").new( arguments[2], predicate ) );
				}
	
			} else {
				
				i = iterator();
				result = createObject("component","Collection").init();
	
				if (isCustomFunction(predicate)) {
					
					while (i.hasNext()) {
						e = i.next();
						if (predicate(e)) {
							result.add(e);
						}
					}
	
				} else {
	
					while (i.hasNext()) {
						e = i.next();
						if (predicate.call(e)) {
							result.add(e);
						}
					}
	
				}
	
			}
			
			return result;
		}
	
		// I return a collection containing only elements that do not satisfy the predicate.
		// Can be called in any of the following ways:
		//		reject( "argname", "codeblock" )
		//		reject( closureOrFunction )
		function reject(
				predicate	// I am the predicate closure/function to execute on each element (or the argname). 
				// codeblock   I am the optional codeblock.
		) {
			var i = 0;
			var result = 0;
			var e = 0;
			
			if (arrayLen(arguments) gt 1 and isSimpleValue(predicate) and isSimpleValue(arguments[2])) {
	
				// argname and codeblock
				if (structKeyExists(variables,"cf")) {
					// reuse our closure factory:
					result = reject( variables.cf.new( arguments[2], predicate ) );
				} else {
					// not very efficient: create a new closure factory and use that:
					result = reject( createObject("component","ClosureFactory").new( arguments[2], predicate ) );
				}
	
			} else {
				
				i = iterator();
				result = createObject("component","Collection").init();
	
				if (isCustomFunction(predicate)) {
					
					while (i.hasNext()) {
						e = i.next();
						if (not predicate(e)) {
							result.add(e);
						}
					}
	
				} else {
	
					while (i.hasNext()) {
						e = i.next();
						if (not predicate.call(e)) {
							result.add(e);
						}
					}
	
				}
	
			}
			
			return result;
		}
	
		// I return a collection containing mapped values of the elements.
		// Can be called in any of the following ways:
		//		collect( "argname", "codeblock" )
		//		collect( closureOrFunction )
		function collect(
				mapping		// I am the mapping closure/function to execute on each element (or argname).
				// codeblock   I am the optional codeblock.
		) {
			var i = 0;
			var result = 0;
			
			if (arrayLen(arguments) gt 1 and isSimpleValue(mapping) and isSimpleValue(arguments[2])) {
	
				// argname and codeblock
				if (structKeyExists(variables,"cf")) {
					// reuse our closure factory:
					result = collect( variables.cf.new( arguments[2], mapping ) );
				} else {
					// not very efficient: create a new closure factory and use that:
					result = collect( createObject("component","ClosureFactory").new( arguments[2], mapping ) );
				}
	
			} else {
				
				i = iterator();
				result = createObject("component","Collection").init();
	
				if (isCustomFunction(mapping)) {
					
					while (i.hasNext()) {
						result.add(mapping(i.next()));
					}
	
				} else {
	
					while (i.hasNext()) {
						result.add(mapping.call(i.next()));
					}
	
				}
	
			}
			
			return result;
		}
		
		// I return the first element that satisfies the predicate.
		// Can be called in any of the following ways:
		//		detect( "argname", "codeblock" )
		//		detect( closureOrFunction, closureOrFunction )
		function detect(
				predicate	// I am the predicate closure/function to execute on each element (or the argname). 
				// codeblock   I am the optional closure/function to execute if there is no match (or the predicate codeblock).
		) {
			var i = 0;
			var e = 0;
			
			if (arrayLen(arguments) gt 1 and isSimpleValue(predicate) and isSimpleValue(arguments[2])) {
	
				// argname and codeblock
				if (structKeyExists(variables,"cf")) {
					// reuse our closure factory:
					return detect( variables.cf.new( arguments[2], predicate ) );
				} else {
					// not very efficient: create a new closure factory and use that:
					return detect( createObject("component","ClosureFactory").new( arguments[2], predicate ) );
				}
	
			} else {
				
				i = iterator();
	
				if (isCustomFunction(predicate)) {
					
					while (i.hasNext()) {
						e = i.next();
						if (predicate(e)) {
							return e;
						}
					}
	
				} else {
	
					while (i.hasNext()) {
						e = i.next();
						if (predicate.call(e)) {
							return e;
						}
					}
	
				}
	
			}
			
			// no match - execute ifNone exceptionBlock if present:
			if (arrayLen(arguments) gt 1) {
				if (isCustomFunction(arguments[2])) {
					e = arguments[2];
					return e();
				} else {
					return arguments[2].call();
				}
			}
			
			// no match and no ifNone exceptionBlock so this is an exception!
			return variables.detect.noMatchingElement;	// Element DETECT.NOMATCHINGELEMENT is undefined in VARIABLES.
		}
	
		// I return a binary injection of the values of the elements.
		// Can be called in any of the following ways:
		//		inject( initialValue, "arg1,arg2", "codeblock" )
		//		inject( initialValue, closureOrFunction )
		function inject(
				initialValue,	// I am the initial value to kick off the injection.
				binaryBlock		// I am a closure/function that takes two arguments (or the argnames).
				// codeBlock	   I am the optional code block.
		) {
			var i = 0;
			var result = 0;
			
			if (arrayLen(arguments) gt 2 and isSimpleValue(binaryBlock) and isSimpleValue(arguments[3])) {
	
				// argnames and codeblock
				if (structKeyExists(variables,"cf")) {
					// reuse our closure factory:
					result = inject( initialValue, variables.cf.new( arguments[3], binaryBlock ) );
				} else {
					// not very efficient: create a new closure factory and use that:
					result = inject( initialValue, createObject("component","ClosureFactory").new( arguments[3], binaryBlock ) );
				}
	
			} else {
	
				i = iterator();
				result = initialValue;
				
				if (isCustomFunction(binaryBlock)) {
					
					while (i.hasNext()) {
						result = binaryBlock(result,i.next());
					}
		
				} else {
		
					while (i.hasNext()) {
						result = binaryBlock.call(result,i.next());
					}
		
				}
	
			}
	
			return result;
		}
		
		// I return a collection containing only elements that satisfy the predicate after mapping.
		// Can be called in any of the following ways:
		//		collectSelect( "argname", "codeblock", "argname", "codeblock" )
		//		collectSelect( "argname", "codeblock", closureOrFunction )
		//		collectSelect( closureOrFunction, "argname", "codeblock" )
		//		collectSelect( closureOrFunction, closureOrFunction )
		function collectSelect(
				mapping,	// I am the mapping closure/function to execute on each element (or the argname). 
				predicate	// I am the predicate closure/function to execute on each mapped element (or the first codeblock or the second argname). 
				// ...		   I am other arguments...
		) {
			var i = 0;
			var result = 0;
			var e = 0;
			var n = arrayLen(arguments);
			
			if (n gt 2 and isSimpleValue(mapping) and isSimpleValue(predicate)) {
	
				// argname and codeblock
				if (structKeyExists(variables,"cf")) {
					// reuse our closure factory:
					if (n gt 3) {
						result = collectSelect( variables.cf.new( predicate, mapping ), arguments[3], arguments[4] );
					} else {
						result = collectSelect( variables.cf.new( predicate, mapping ), arguments[3] );
					}
				} else {
					// not very efficient: create a new closure factory and use that:
					if (n gt 3) {
						result = collectSelect( createObject("component","ClosureFactory").new( predicate, mapping ), arguments[3], arguments[4] );
					} else {
						result = collectSelect( createObject("component","ClosureFactory").new( predicate, mapping ), arguments[3] );
					}
				}
	
			} else if (n gt 2 and isSimpleValue(predicate) and isSimpleValue(arguments[3])) {
	
				// argname and codeblock
				if (structKeyExists(variables,"cf")) {
					// reuse our closure factory:
					result = collectSelect( mapping, variables.cf.new( arguments[3], predicate ) );
				} else {
					// not very efficient: create a new closure factory and use that:
					result = collectSelect( mapping, createObject("component","ClosureFactory").new( arguments[3], predicate ) );
				}

			} else {
				
				i = iterator();
				result = createObject("component","Collection").init();
	
				if (isCustomFunction(predicate)) {
					
					if (isCustomFunction(mapping)) {
						
						while (i.hasNext()) {
							e = mapping(i.next());
							if (predicate(e)) {
								result.add(e);
							}
						}
		
					} else {
						
						while (i.hasNext()) {
							e = mapping.call(i.next());
							if (predicate(e)) {
								result.add(e);
							}
						}
		
					}

				} else {
	
					if (isCustomFunction(mapping)) {
						
						while (i.hasNext()) {
							e = mapping(i.next());
							if (predicate.call(e)) {
								result.add(e);
							}
						}
		
					} else {
						
						while (i.hasNext()) {
							e = mapping.call(i.next());
							if (predicate.call(e)) {
								result.add(e);
							}
						}
		
					}

				}
	
			}
			
			return result;
		}
	
		// I return a collection containing only mapped elements that satisfy the predicate.
		// Can be called in any of the following ways:
		//		selectCollect( "argname", "codeblock", "argname", "codeblock" )
		//		selectCollect( "argname", "codeblock", closureOrFunction )
		//		selectCollect( closureOrFunction, "argname", "codeblock" )
		//		selectCollect( closureOrFunction, closureOrFunction )
		function selectCollect(
				predicate,	// I am the predicate closure/function to execute on each element (or the argname). 
				mapping		// I am the mapping closure/function to execute on each selected element (or the first codeblock or the second argname). 
				// ...		   I am other arguments...
		) {
			var i = 0;
			var result = 0;
			var e = 0;
			var n = arrayLen(arguments);
			
			if (n gt 2 and isSimpleValue(predicate) and isSimpleValue(mapping)) {
	
				// argname and codeblock
				if (structKeyExists(variables,"cf")) {
					// reuse our closure factory:
					if (n gt 3) {
						result = selectCollect( variables.cf.new( mapping, predicate ), arguments[3], arguments[4] );
					} else {
						result = selectCollect( variables.cf.new( mapping, predicate ), arguments[3] );
					}
				} else {
					// not very efficient: create a new closure factory and use that:
					if (n gt 3) {
						result = selectCollect( createObject("component","ClosureFactory").new( mapping, predicate ), arguments[3], arguments[4] );
					} else {
						result = selectCollect( createObject("component","ClosureFactory").new( mapping, predicate ), arguments[3] );
					}
				}
	
			} else if (n gt 2 and isSimpleValue(mapping) and isSimpleValue(arguments[3])) {
	
				// argname and codeblock
				if (structKeyExists(variables,"cf")) {
					// reuse our closure factory:
					result = selectCollect( predicate, variables.cf.new( arguments[3], mapping ) );
				} else {
					// not very efficient: create a new closure factory and use that:
					result = selectCollect( predicate, createObject("component","ClosureFactory").new( arguments[3], mapping ) );
				}

			} else {
				
				i = iterator();
				result = createObject("component","Collection").init();
	
				if (isCustomFunction(predicate)) {
					
					if (isCustomFunction(mapping)) {
						
						while (i.hasNext()) {
							e = i.next();
							if (predicate(e)) {
								result.add(mapping(e));
							}
						}
		
					} else {
						
						while (i.hasNext()) {
							e = i.next();
							if (predicate(e)) {
								result.add(mapping.call(e));
							}
						}
		
					}

				} else {
	
					if (isCustomFunction(mapping)) {
						
						while (i.hasNext()) {
							e = i.next();
							if (predicate.call(e)) {
								result.add(mapping(e));
							}
						}
		
					} else {
						
						while (i.hasNext()) {
							e = i.next();
							if (predicate.call(e)) {
								result.add(mapping.call(e));
							}
						}
		
					}

				}
	
			}
			
			return result;
		}
	
		// I return the number of elements that satisfy the predicate.
		// Can be called in any of the following ways:
		//		count( "argname", "codeblock" )
		//		count( closureOrFunction )
		function count(
				predicate	// I am the predicate closure/function to execute on each element (or the argname). 
				// codeblock   I am the optional codeblock.
		) {
			var i = 0;
			var result = 0;
			
			if (arrayLen(arguments) gt 1 and isSimpleValue(predicate) and isSimpleValue(arguments[2])) {
	
				// argname and codeblock
				if (structKeyExists(variables,"cf")) {
					// reuse our closure factory:
					result = count( variables.cf.new( arguments[2], predicate ) );
				} else {
					// not very efficient: create a new closure factory and use that:
					result = count( createObject("component","ClosureFactory").new( arguments[2], predicate ) );
				}
	
			} else {
				
				i = iterator();
	
				if (isCustomFunction(predicate)) {
					
					while (i.hasNext()) {
						if (predicate(i.next())) {
							result = result + 1;
						}
					}
	
				} else {
	
					while (i.hasNext()) {
						if (predicate.call(i.next())) {
							result = result + 1;
						}
					}
	
				}
	
			}
			
			return result;
		}
	
		// I return an iterator for this collection.
		function iterator() {
			
			return variables.elements.iterator();
		
		}
		
		// I return the underlying collection as an array.
		// Warning: this copies the array (but not deeply).
		function asArray() {
		
			return variables.elements;
			
		}
		
		// I return the underlying collection as a struct.
		// Warning: this will fail if the elements are not key/value pairs.
		// Warning: this is also a lossy mapping if you have multiple identical keys.
		function asStruct() {
			
			var i = iterator();
			var result = structNew();
			var e = 0;
			
			while (i.hasNext()) {
				e = i.next();
				result[e.key] = e.value;
			}
		
			return result;
			
		}
		
		// I add a series of elements to the collection.
		// add(element1,element2,element3,...)
		function add() {
			
			var i = 0;
			var n = arrayLen(arguments);
	
			for (i = 1; i lte n; i = i + 1) {
				arrayAppend(variables.elements,arguments[i]);
			}
			
			return this;
		}
		
		// I add a collection or an array or a struct to the collection.
		function addAll(
				elements	// I am the new elements to add.
		) {
			if (isArray(elements) or
					( isObject(elements) and isInstanceOf(elements,"Collection") ) ) {
				addByIterator(elements.iterator());
			} else if (isStruct(arguments[1])) {
				addByMapIterator(elements.entrySet().iterator());
			} else {
				// no idea what it is, but if it has an iterator, we'll add its contents
				addByIterator(elements.iterator());
			}
			
			return this;
		}
	
		// I add all elements of a collection as simple values.
		function addByIterator(
				iter		// I am an iterator over simple values.
		) {
			while (iter.hasNext()) {
				arrayAppend(variables.elements,iter.next());
			}
			
			return this;
		}
	
		// I add all elements of a collection as simple values.
		function addByMapIterator(
				iter		// I am an iterator over key/value pairs.
		) {
			var e = 0;
			var i = 0;
			
			while (iter.hasNext()) {
				i = iter.next();
				e = structNew();
				e.key = i.getKey();
				e.value = i.getValue();
				arrayAppend(variables.elements,e);
			}
			
			return this;
		}
	
	</cfscript>
</cfcomponent>