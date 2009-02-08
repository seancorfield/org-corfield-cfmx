
<cfimport taglib="/cfspec" prefix="" />

<describe hint="Edmund's">

	<beforeAll>
		<cfset edmund = createObject( "component", "edmund.Edmund" ).init() />
	</beforeAll>
	
	<describe hint="base object">
		
		<it should="have no parent">
			<cfset $(edmund).getParent().shouldEqual(0) />
		</it>
		
		<it should="have no bean factory">
			<cfset $(edmund).hasBeanFactory().shouldBeFalse() />
		</it>
		
		<it should="be unique">
			<cfset anotherEdmund = createObject( "component", "edmund.Edmund" ).init() />
			<cfset $(edmund).getId().shouldNotEqual( anotherEdmund.getId() ) />
		</it>
		
	</describe>
	
	<describe hint="new child">
		
		<it should="be an instance of edmund">
			<cfset $(edmund).newChild().shouldBeAnInstanceOf("edmund.Edmund") />
		</it>
		
		<it should="have the base object as its parent">
			<cfset child = edmund.newChild() />
			<cfset $(child).getParent().getId().shouldEqual( edmund.getId() ) />
		</it>
		
	</describe>
	
	<describe hint="added children">
		
		<it should="have the base object as their parent">
			<cfset childA = createObject( "component", "edmund.Edmund" ).init() />
			<cfset childB = createObject( "component", "edmund.Edmund" ).init() />
			<cfset edmund.addChild( childA ) />
			<cfset edmund.addChild( childB ) />
			<cfset $(childA).getParent().getId().shouldEqual( edmund.getId() ) />
			<cfset $(childB).getParent().getId().shouldEqual( edmund.getId() ) />
		</it>
		
	</describe>
	
	<describe hint="new parent">
		
		<it should="be a instance of edmund">
			<cfset $(edmund).newParent().shouldBeAnInstanceOf("edmund.Edmund") />
		</it>
		
		<it should="be the base object's parent">
			<cfset parent = edmund.newParent() />
			<cfset $(edmund).getParent().getId().shouldEqual( parent.getId() ) />
		</it>
		
	</describe>
	
	<describe hint="added parent">
		
		<it should="be the base object's parent">
			<cfset parent = createObject( "component", "edmund.Edmund" ).init() />
			<cfset edmund.setParent( parent ) />
			<cfset $(edmund).getParent().getId().shouldEqual( parent.getId() ) />
		</it>
		
	</describe>
	
	<describe hint="initialized parent">
		
		<it should="be the new object's parent">
			<cfset child = createObject( "component", "edmund.Edmund" ).init( parent=edmund ) />
			<cfset $(child).getParent().getId().shouldEqual( edmund.getId() ) />
		</it>
		
	</describe>
	
	<describe hint="new event">
		
		<it should="be an instance of event">
			<cfset $(edmund).new().shouldBeAnInstanceOf( "edmund.framework.Event" ) />
		</it>
		
		<it should="be called event">
			<cfset $(edmund).new().name().shouldEqual( "Event" ) />
		</it>

	</describe>
	
	<describe hint="new named event">
		
		<it should="be an instance of event">
			<cfset $(edmund).newEvent( "namedEvent" ).shouldBeAnInstanceOf( "edmund.framework.Event" ) />
		</it>
		
		<it should="be called namedEvent">
			<cfset $(edmund).newEvent( "namedEvent" ).name().shouldEqual( "namedEvent" ) />
		</it>

	</describe>
	
	<describe hint="new typed event">
		
		<it should="be an instance of typed event">
			<cfset $(edmund).new( "edmund.tests.cfspec.cfcs.TypedEvent" ).shouldBeAnInstanceOf( "edmund.tests.cfspec.cfcs.TypedEvent" ) />
		</it>
		
		<it should="also be an instance of event">
			<cfset $(edmund).new( "edmund.tests.cfspec.cfcs.TypedEvent" ).shouldBeAnInstanceOf( "edmund.framework.Event" ) />
		</it>
		
		<it should="be called TypedEvent">
			<cfset $(edmund).new( "edmund.tests.cfspec.cfcs.TypedEvent" ).name().shouldEqual( "TypedEvent" ) />
		</it>

	</describe>
	
	<describe hint="loader">
		
		<it should="throw an exception for a non-existant file">
			<cfset $(edmund).load("/i/am/a/non/existant/file.xml").shouldThrow( "application", 
				"An error occurred when performing a file operation read on file /i/am/a/non/existant/file.xml." ) />
		</it>
		
		<it should="throw an exception for ill-formed XML">
			<cfset $(edmund).loadXML("I am not XML").shouldThrow( "expression", 
				"An error occured while Parsing an XML document." ) />
		</it>
		
	</describe>
	
	<describe hint="workflow">
		
		<it should="be an instance of workflow factory">
			<cfset $(edmund).getWorkflow().shouldBeAnInstanceOf( "edmund.framework.workflow.Factory" ) />
		</it>
		
	</describe>
	
</describe>