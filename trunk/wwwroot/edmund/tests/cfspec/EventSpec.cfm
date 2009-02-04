
<cfimport taglib="/cfspec" prefix="" />

<describe hint="Edmund's">

	<beforeAll>
		<cfset edmund = createObject( "component", "edmund.Edmund" ).init() />
	</beforeAll>

	<describe hint="Event">
		
		<before>
			<cfset event = createObject( "component", "edmund.framework.Event" ) />
		</before>
		
		<it should="provide itself">
			<cfset $(event).shouldBeAnInstanceOf("edmund.framework.Event") />
		</it>
		
		<it should="be provided by edmund from the new method">
			<cfset event = edmund.new() />
			<cfset $(event).shouldBeAnInstanceOf("edmund.framework.Event") />
		</it>
		
		<it should="be provided by edmund from the newEvent method">	
			<cfset event = edmund.newEvent( "EVENT" ) />
			<cfset $(event).shouldBeAnInstanceOf("edmund.framework.Event") />
		</it>
		
		<it should="set a values">
			<cfset event = createObject( "component", "edmund.framework.Event" ) />
			<cfset event.value("foo", "bar") />
			<cfset value = event.value("foo") />
			<cfset $(value).shouldEqualString("bar") />
		</it>
			
		<it should="set multiple values">
			<cfset event = createObject( "component", "edmund.framework.Event" ) />
			<cfset event.values( foo1="bar1", foo2="bar2" ) />
			<cfset value = event.value("foo2") />
			<cfset $(value).shouldEqualString("bar2") />	
		</it>
		
		<it should="provide a shallow structure of values held within the Event">
			<cfset event.values( foo1="bar1", foo2="bar2") />
			<cfset valueStructure = event.all() />
			<cfset $(valueStructure).shouldContain("foo1", "foo2") />
		</it>
		
		<it should="bubble up settings">
			<cfset $(true).shouldEqualBoolean(false) />
		</it>
		
		<it should="dispatch itself">
			<cfset $(true).shouldEqualBoolean(false) />
		</it>
		
		<it should="be able to check to see if it has a set value">
			<cfset event.values( foo1="bar1", foo2="bar2") />
			<cfset hasValue = event.has( "foo1" ) />
			<cfset $(hasValue).shouldEqualBoolean( true ) />
		</it>
		
		<it should="set its name if the name does not already exist"> 
			<cfset event = event.name( "EVENT" ) />
			<cfset eventName = event.name() />
			<cfset $(eventName).shouldEqualString( "EVENT" ) />
		</it>
		
		<it should="set its request name when setting the name if the name does not already exist"> 
			<cfset event = event.name( "EVENT" ) />
			<cfset requestName = event.requestName() />
			<cfset $(requestName).shouldEqualString( "EVENT" ) />
		</it>
		
		<it should="set its name and return the event">
			<cfset event = event.name( "EVENT" ) />
			<cfset $(event).shouldBeAnInstanceOf("edmund.framework.Event") />
		</it>
		
		<it should="be able to set and get its request name">
			<cfset event.requestName( "EVENT" ) />
			<cfset requestName = event.requestName() />
			<cfset $(requestName).shouldEqualString( "EVENT" ) />
		</it>
		
	</describe>

</describe>