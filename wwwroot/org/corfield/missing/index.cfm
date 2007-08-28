<cfscript>
	o = createObject("component","Test");
	t = createObject("component","Transaction").init(o);
	o.doSomething();
	t.doSomething();
	t.doSomethingWithTransaction();
</cfscript>