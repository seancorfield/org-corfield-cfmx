
<cfimport taglib="/cfspec" prefix="" />

<describe hint="Edmund's">

	<beforeAll>
		<cfset edmund = createObject( "component", "edmund.Edmund" ).init() />
	</beforeAll>
	
	<describe hint="id">
	
		<it should="be a string">
			<cfset id = edmund.getId() />
			<cfset $(id).shouldBeSimpleValue() />
		</it>
		
	</describe>
	
	<describe hint="accessors">
		
		<it should="set and get a parent edmund object">
			<cfset edmund.setParent( createObject( "component", "edmund.Edmund" ).init() ) />
			<cfset edmundParent = edmund.getParent() />
			<cfset $(edmundParent).shouldBeAnInstanceOf("edmund.edmund") />
		</it>
		
	</describe>
	
	<describe hint="child">
		
		<it should="be an instance of edmund">
			<cfset newEdmundChild = edmund.newChild() />
			<cfset edmundParent = newEdmundChild.getParent() />
			<cfset $(edmundParent).shouldBeAnInstanceOf("edmund.Edmund") />
		</it>
		
		<it should="add the parent instance of edmund into itself">
			<cfset edmundChild = createObject( "component", "edmund.Edmund" ).init() />
			<cfset edmund.addChild( edmundChild ) />
			
			<cfset parentId = edmund.getId() />
			<cfset edmundChildParentId = edmundChild.getParent().getId() />
			
			<cfset $( edmundChildParentId ).shouldEqualString( parentId ) />
		</it>
		
	</describe>
	
	<describe hint="parent">
		
		<it should="be a instance of edmund">
			<cfset newEdmundParent = edmund.newParent() />
			<cfset edmundParent = edmund.getParent() />
			<cfset $(edmundParent).shouldBeAnInstanceOf("edmund.Edmund") />
		</it>
		
	</describe>
	
</describe>