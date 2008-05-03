<cfscript>
	logCommand = createObject("component","logger").init();
	
	logs = arrayNew(1);
	logs[1] = logCommand;
	logs[2] = logCommand;
	
	log2 = application.edmund.getWorkflow().seq(logs);
	log2.handleEvent( application.edmund.new() );
	
	data = arrayNew(1);
	for (i = 1; i lte 10; i = i + 1) data[i] = i;
	
	log2 = application.edmund.getWorkflow().foreach("iter","x",logCommand);
	log2.handleEvent( application.edmund.new().values(iter=data.iterator()) );
</cfscript>