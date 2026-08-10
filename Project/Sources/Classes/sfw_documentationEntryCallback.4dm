property callbacks : Collection

shared singleton Class constructor
	
	var $callback : Object
	
	This:C1470.callbacks:=New shared collection:C1527
	
	$callback:=New object:C1471
	$callback.title:="entryDefinition"
	$callback.syntax:="local Function entryDefinition()->$entry : cs.sfw_definitionEntry"
	$callback.comment:="In this function you define the entry."
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	
	$callback:=New object:C1471
	$callback.title:="closeBoxMainForm"
	$callback.syntax:="local Function closeBoxMainForm()"
	$callback.comment:="With this callback you close the BoxMain form"
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	
	This:C1470.callbacks:=This:C1470.callbacks.orderBy("title")
	
	
	
	
	
	//local Function closeBoxMainForm()