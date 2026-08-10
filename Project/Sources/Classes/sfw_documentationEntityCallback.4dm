property callbacks : Collection

shared singleton Class constructor
	var $callback : Object
	
	This:C1470.callbacks:=New shared collection:C1527
	
	
	$callback:=New object:C1471
	$callback.title:="get nameInWindowTitle"
	$callback.syntax:="local Function get nameInWindowTitle()->$nameInWindowTitle : Text\r\r$nameInWindowTitle:=This.name"
	$callback.comment:="With this callback you return the name to displayed in the title of the window for the current item"
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	$callback:=New object:C1471
	$callback.title:="itemLoad"
	$callback.syntax:="local Function itemLoad()"
	$callback.comment:="This callback is called when the item is selected in the itemList"
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	
	$callback:=New object:C1471
	$callback.title:="beforeSave"
	$callback.syntax:="local Function beforeSave()"
	$callback.comment:="This callback is called before saving the current item"
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	
	$callback:=New object:C1471
	$callback.title:="afterSave"
	$callback.syntax:="local Function afterSave()"
	$callback.comment:="This callback is called after saving the current item"
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	
	$callback:=New object:C1471
	$callback.title:="itemReload"
	$callback.syntax:="local Function itemReload()"
	$callback.comment:="This callback is executed when the current_item is reloaded. (click on buttons reload, cancel and save or after changing the mode)"
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	$callback:=New object:C1471
	$callback.title:="afterCreation"
	$callback.syntax:="local Function afterCreation()"
	$callback.comment:="This callback is called after saving the new item"
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	
	$callback:=New object:C1471
	$callback.title:="beforeSaveCreation"
	$callback.syntax:="local Function beforeSaveCreation()"
	$callback.comment:="This callback is called before saving the new item"
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	$callback:=New object:C1471
	$callback.title:="loadAfterCreation"
	$callback.syntax:="local Function loadAfterCreation()"
	$callback.comment:="This callback is called after creating the new item but before displaying the panel."
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	
	$callback:=New object:C1471
	$callback.title:="panelUnload"
	$callback.syntax:="local Function panelUnload()"
	$callback.comment:="This callback is called when the current panel will be changed by another one."
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	$callback:=New object:C1471
	$callback.title:="duplicateRecord"
	$callback.syntax:="local Function duplicateRecord()"
	$callback.comment:="This callback is called to create a duplication of the current item."
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	$callback:=New object:C1471
	$callback.title:="beforeDelete"
	$callback.syntax:="local Function beforeDelete()"
	$callback.comment:="This callback is executed before the deletion of the current item."
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	
	$callback:=New object:C1471
	$callback.title:="isDeletable"
	$callback.syntax:="local Function isDeletable()->$isDeletable : Boolean\r\r$isDeletable:=False"
	$callback.comment:="This callback must return false to inactivate the deletion mode for the current item."
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	
	$callback:=New object:C1471
	$callback.title:="isModifiable"
	$callback.syntax:="local Function isModifiable()->$isModifiable : Boolean\r\r$isModifiable:=False"
	$callback.comment:="This callback must return false to inactivate the edition mode for the current item."
	This:C1470.callbacks.push(OB Copy:C1225($callback; ck shared:K85:29))
	
	This:C1470.callbacks:=This:C1470.callbacks.orderBy("title")
	
	
	
	
	
	