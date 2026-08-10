Class extends Entity


local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.name)
	
	
Function event validateSave($event : Object)->$result : Object
	var $n : Text
	var $dup : 4D:C1709.EntitySelection
	
	$result:=Null:C1517
	$n:=cs:C1710.sfw_string.me.trimSpace(String:C10(This:C1470.name))
	If ($n="")
		$result:=New object:C1471("errCode"; 1; "message"; "Area name is mandatory."; "seriousError"; False:C215)
		return 
	End if 
	$dup:=ds:C1482.StepArea.query("name = :1 and UUID # :2"; $n; This:C1470.UUID)
	If ($dup.length>0)
		$result:=New object:C1471("errCode"; 2; "message"; "An area with this name already exists."; "seriousError"; False:C215)
	End if 
	
	
Function event saving($event : Object)
	var $n : Text
	
	$n:=cs:C1710.sfw_string.me.trimSpace(String:C10(This:C1470.name))
	This:C1470.name:=$n
	
